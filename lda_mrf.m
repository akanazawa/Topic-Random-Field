function [alpha,sig,beta,mu,del] = lda_mrf(data, Learn)
%%%%%%%%%%
% lda_mrf.m
% Learn parameters for LDA+MRF, no gaussian noise channel
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


gammas = zeros(D, K);

lams = 0;
lik = 0;
pre_alpha = alpha;
pre_beta = beta;

pre_sig = sig;

tic;
for j = 1:Learn.Max_Iterations
  fprintf(1,'iteration %d/%d..\n',j,Learn.Max_Iterations);
  % reset
  beta = zeros(L,K);
  sig = 0;

  %% E vb-estep
  for d = 1:D
    [gamma,rho,lambda] = vbem(data{d},pre_beta,pre_alpha,pre_sig,Learn);
    gammas(d,:) = gamma;
    Nd = length(data{d}.segLabels); % number of regions    
    dfeat = data{d}.feat2; % Nd x m 
    % iteratively do M-step as we go
    for n=1:Nd        
        dataAtN =dfeat(n,:)'; % mx1
        for l=1:L
            for k=1:K
                ngbh = find(data{d}.adj(n,:));
                if numel(ngbh) > 5
                    ngbh = ngbh(randperm(numel(ngbh))); % permute
                    ngbh = ngbh(1:E); % pick first E nbghs
                end
                sig = sig + sum(rho(n,k)*rho(ngbh, k));
            end
        end        
        beta = beta + xiRho;
    end
    lams = lams + 1/lambda;    
    lik = lik + trf_lik(data{d}, pre_alpha, pre_beta, pre_sig, gamma, rho, lambda, Learn);

  end

  % M-step of alpha and normalize beta and all the otehrs
  alpha = newton_alpha(gammas)
  del = del./(m.*beta);  
  origbeta = beta;
  beta = beta./(repmat(sum(beta,2),1,k))
  if (numel(find(isnan(beta))) > 0)
      fprintf(' in trf beta is nan\n');
      keyboard
  end
  % converge?
  fprintf(1,'likelihood = %g\t',lik);
  % if (j > 1) && converged(beta,pre_beta,1.0e-4) &&
  % converged(mu,pre_mu,1.0e-4) && converged(del,pre_del,1.0e-4) &&
  % converged(sig,pre_sig,1.0e-4)
  if (j > 1) && converged(lik, pre_lik, 1.0e-5);
    fprintf(1,'\nconverged at iteration %d.\n', j);
    return;
  end
  pre_lik = lik;
  lik = 0;
  % ETA
  elapsed = toc;
  fprintf(1,'ETA:%s (%d sec/step)\r',rtime(elapsed * (Learn.Max_Iterations / j  - 1)),round(elapsed / j));
end
fprintf(1,'\n');

end

% alpha = normalize(fliplr(sort(rand(1,K))));
% beta = ones(L,K)/L;
% sig = 1;
% gamma here is kx1
% rho = ones(Nd, K)/K; % Nd by K

% if LDA:
% dig = digamma(ldagamma);
% digsum = digamma(sum(ldagamma));
% likelihood=gammaln(sum(a))-sum(gammaln(a)) + sum((a-1).*(dig-digsum)) ...
%     - gammaln(sum(ldagamma))+sum(gammaln(ldagamma)) ...
% 	- sum((ldagamma-1).*(dig-digsum)) - sum(sum(ldaphi.*log(ldaphi))) ...
% 	+ (dig-digsum)'*sum(ldaphi,2) + sum(sum(ldaphi.*log(b(:,d))));
% di is Ndxm here
function [likelihood] = trf_lik(data, alpha, beta, mu, del, sig, ... 
                 gam, xi, rho, lambda, Learn)
  m = size(data,2); %number of features
  K = Learn.Num_Topics;
  L = Learn.Num_Prototypes;
  Nd = length(data.segLabels); % number of regions    
  d = data.feat2; % Nd x m   
  
  digamma = psi(gam);
  digamma_sum = psi(sum(gam));
  line1 = gammaln(sum(alpha)) - sum(gammaln(alpha)) ...
      + sum((alpha-1).*(digamma - digamma_sum));
  line2 = (digamma-digamma_sum)*sum(rho)'; %need to add neighbor
                                          %terms
  line3 = rho.*log(beta); % need to take the word count
  line5 = -gammaln(sum(gam)) + sum(gammaln(gam)) ...
           - sum( (gam-1).*(digamma - digamma_sum));
  line6 = - sum(sum(rho.*log(rho)));
  likelihood =  line1 + line2 + line3 + line5 + line6; 
end
