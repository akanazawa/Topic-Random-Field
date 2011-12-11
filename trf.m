function [alpha,sig,beta,mu,del] = trf(data, Learn)
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
K = Learn.Num_Topics;
L = Learn.Num_Prototypes;
E = Learn.Num_Neighbors;
% initialize parameters
alpha = normalize(fliplr(sort(rand(1,K))));
beta = ones(L,K)/L;
sig = 1;
mu = ones(L,K,m);
del = ones(L,K);

gammas = zeros(D, K);
% xis = zeros(L,K);
% rhos = zeros(D,K);
lams = 0;
lik = 0;
pre_alpha = alpha;
pre_beta = beta;
pre_mu = mu;
pre_del = del;
pre_sig = sig;

tic;
for j = 1:Learn.Max_Iterations
  fprintf(1,'iteration %d/%d..\n',j,Learn.Max_Iterations);

  %% vb-estep
  for d = 1:D
    [gamma,xi_n,rho,lambda] = vbem(data{d},beta,alpha,mu,del,sig,Learn);
    gammas(d,:) = gamma;
    Nd = length(data{d}.segLabels); % number of regions    
    % iteratively do vb-mstep
    for n=1:Nd        
        dfeat = data{d}.feat2; % Nd x m 
        dataAtN =dfeat(n,:)'; % mx1
        xiRho = xi_n(n,:)'*rho(n,:);% xi_n=nDxl, rho=nDxk: (1xl)'*(1xk)
        for l=1:L
            for k=1:K
                mu(l,k,:) = squeeze(mu(l,k,:)) + dataAtN*xiRho(l,k);
                del(l,k) = del(l,k) + xiRho(l,k)*(dataAtN-squeeze(mu(l,k,:)))'* ...
                    (dataAtN-squeeze(mu(l,k,:))); % (mx1)^T(mx1) = 1x1
                ngbh = find(data{d}.adj(n,:));
                if numel(ngbh) > 5
                    ngbh = ngbh(randperm(numel(ngbh))); % permute
                    ngbh = ngbh(1:E); % pick first E nbghs
                end
                sig = sum(rho(n,k)*rho(ngbh, k));
            end
        end        
        beta = beta + xiRho;
    end
    lams = lams + 1/lambda;    
  end

    
  % M-step of alpha and normalize beta and all the otehrs
  alpha = newton_alpha(gammas);
  mu = bsxfun(@rdivide, mu, beta);
  del = del./(m.*beta);
  sig = 1/E*log(sig/lams);
  beta = mnormalize(beta, 1);  
  
  % converge?
  %  lik = trf_lik(data{d},beta,gammas);
  % if the parameters stop changes: ah, sig, beta, mu, delta

  %  fprintf(1,'likelihood = %g\t',lik);
  if (j > 1) && converged(alpha,pre_alpha,1.0e-4) && converged(beta,pre_beta,1.0e-4) && converged(mu,pre_mu,1.0e-4) && converged(del,pre_del,1.0e-4) && converged(sig,pre_sig,1.0e-4)
    if (j < 5)
      fprintf(1,'tooearly???\n');
      keyboard
      [alpha,sig,beta,mu,delta] = trf(allData,Learn); % try again!
      return;
    end
    fprintf(1,'\nconverged.\n');
    return;
  end
  pre_alpha = alpha;
  pre_beta = beta;
  pre_mu = mu;
  pre_del = del;
  pre_sig = sig;
  % ETA
  elapsed = toc;
  fprintf(1,'ETA:%s (%d sec/step)\r',rtime(elapsed * (Learn.Max_Iterations / j  - 1)),round(elapsed / j));
end
fprintf(1,'\n');


