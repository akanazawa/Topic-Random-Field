function [alpha,sig,beta,mu,delta] = trf(data, Learn)
% TRF based on LDA, standard model.
% Copyright (c) 2004 Daichi Mochihashi, all rights reserved.
% 
% Modified by Angjoo Kanazawa/Austin Myers/Abhishek Sharma
%
% Look at the config file for the default parameter settings and their size

D = length(data);

m = size(data{1},2);
k = Learn.Num_Topics;
l = Learn.Num_Prototypes;
% initialize parameters
alpha = normalize(fliplr(sort(rand(1,k))));
beta = ones(l,k)/l;
sig = 1;
mu = ones(l,k,m);
del = ones(l,k);

gammas = zeros(D);
xis = zeros(l,k);
rhos = zeros(D,k);
lambdas = zeros(D,1);


lik = 0;
pre_lik = lik;

tic;

for j = 1:Learn.Max_Iterations
  fprintf(1,'iteration %d/%d..\t',j,Learn.Max_Iterations);

  %% vb-estep
  %  betas = zeros(l,k);

  for d = 1:D
    [gamma,xi_n,rho,lambda] = vbem(data{d},beta,alpha,mu,delta,sig,Learn);
    gammas(d,:) = gamma;
    Nd = size(data{d},1);
    tmp = zeros(l,k);
    %    beta = beta + xi'rho;
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
  lik = trf_lik(data{d},beta,gammas);

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
  fprintf(1,'ETA:%s (%d sec/step)\r', ...
	  rtime(elapsed * (emmax / j  - 1)),round(elapsed / j));
end
fprintf(1,'\n');


