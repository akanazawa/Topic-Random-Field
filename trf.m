function [alpha,sig,beta,mu,delta] = trf(data, Learn)
%%%%%%%%%%
% trf.m
% Learn parameters for TRF and save
% INPUT:
%    - data: cell array of data in format:
%          data{1}:
%                img: [240x320x3 uint8]
%             labels: [240x320 double]
%              segs2: [240x320 double]
%              feat2: [115x119 double]
%          segLabels: [115x1 double]
%                adj: [115x115 logical]
%
%    - Learn: parameters specificed in config.m
%
% based on LDA code by Daichi Mochihashi.
%
% Modified by Angjoo Kanazawa/Austin Myers/Abhishek Sharma
%


D = length(data);
m = size(data{1}.feat2,2); %number of features
k = Learn.Num_Topics;
l = Learn.Num_Prototypes;

% initialize parameters
alpha = normalize(fliplr(sort(rand(1,k))));
beta = ones(l,k)/l;
sig = 1;
mu = ones(l,k,m);
del = ones(l,k);

gammas = zeros(D, k);
xis = zeros(l,k);
rhos = zeros(D,k);
lambdas = zeros(D,1);
lik = 0;
pre_lik = lik;

tic;
for j = 1:Learn.Max_Iterations
  fprintf(1,'iteration %d/%d..\n',j,Learn.Max_Iterations);

  %% vb-estep
  for d = 1:D
    [gamma,xi_n,rho,lambda] = vbem(data{d},beta,alpha,mu,del,sig,Learn);
    keyboard
    gammas(d,:) = gamma;
    Nd = length(data{d}.segLabels); % number of regions
    tmp = zeros(l,k);
    % iteratively do vb-mstep
    for n=1:Nd        
        dd = data{d};
        dataAtN =dd(n,:);
        xiRho = xi(n,:)'*rho(n,:);
        for l=1:L
            for k=1:K
                mu(l,k,:) = mu(l,k,:) + dataAtN*xiRho(l,k);
                del(l,k) = del(l,k) + xiRho(l,k)*(dataAtN-mu(l,k,:))'* ...
                    (dataAtN-mu(l,k,:));
                %                sig = sig + 1/numEdges * log 
            end
        end        
        beta = beta + xi(n,:)'*rho(n,:); % (1xl)' * (1xk)
    end
    %    beta = beta + xi'*rho; %(1 x l)' * (1 x k) = l x k
    lambdas(d) = lambda;    
  end

  % M-step of alpha and normalize beta
  alpha = newton_alpha(gammas);
  beta = mnormalize(beta, 1);
  
  % converge?
  %  lik = trf_lik(data{d},beta,gammas);
  % if the parameters stop changes: ah, sig, beta, mu, delta

  fprintf(1,'likelihood = %g\t',lik);
  if (j > 1) && converged(lik,plik,1.0e-4)
    if (j < 5)
      fprintf(1,'\n');
      [alpha,beta] = lda(d,k,emmax,demmax); % try again!
      return;
    end
    fprintf(1,'\nconverged.\n');
    return;
  end
  plik = lik;
  % ETA
  elapsed = toc;
  fprintf(1,'ETA:%s (%d sec/step)\r',rtime(elapsed * (Learn.Max_Iterations / j  - 1)),round(elapsed / j));
end
fprintf(1,'\n');


