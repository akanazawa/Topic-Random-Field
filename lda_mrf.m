function [alpha, beta, sig] = lda_mrf(data, Learn)
%%%%%%%%%%
% lda_mrf.m
% Learn parameters for LDA+MRF, no gaussian noise channel
% INPUT:
%    - data: cell array of data with structure:
%          data{1}:
%                img: [240x320x3 uint8]
%             labels: [240x320 double]
%                 vq: [Nd x L]
%              segs2: [240x320 double]
%              feat2: [Nd x 119 double]
%          segLabels: [Nd x 1 double]
%                adj: [Nd x Nd logical]
%
%    - Learn: parameters specificed in config.m
%
% based on LDA code by Daichi Mochihashi (http://chasen.org/~daiti-m/dist/lda/) 
% and Jonathan Huang (http://www.stanford.edu/~jhuang11/#code)
%
% Angjoo Kanazawa 12/13/2011

%% Learning Settings
D = length(data);
K = Learn.Num_Topics;
L = size(data{1}.vq, 2); % length of code book
E = Learn.Num_Neighbors;

%% initialize parameters
alpha = normalize(fliplr(sort(rand(1,K))));
beta = rand(K,L) + .01;
beta = beta ./ repmat(sum(beta, 2), 1, L); % make it probability
sig = 1;

%% likelihood for convergence
lik = 0;

tic;
for j = 1:Learn.Max_Iterations
  fprintf(1,'iteration %d/%d..\n',j,Learn.Max_Iterations);
  % initialize to store computed variational param for each image
  gammas = zeros(D, K);      
  rhos = cell(D);
  lams = zeros(D,1);
  lik = 0;
  %%%%% E step find the best variational parameters %%%%%
  for d = 1:D
    [gamma,rho,lambda] = vbem(data{d},beta,alpha,sig,Learn);
    gammas(d,:) = gamma;
    rhos{d} = rho; % Ndxk 
    lams(d) = lambda;
    lik = lik + getLikelihood(data{d}, alpha, beta, sig, gamma, rho, lambda, Learn);
  end

  %%%%% M-step of alpha and normalize beta and all the otehrs %%%%%
  % being very pedantic, exact to the equation
  totalEdges = 0;
  for d=1:D
      Nd = length(data{d}.segLabels); % number of regions    
      dfeat = data{d}.vq; % Nd x L      
      for n=1:Nd        
          d =dfeat(n,:)'; % Lx1
          rho = rhos{d};
          ngbh = getNeighbors(data{d}, n, E);
          totalEdges = totalEdges + numel(ngbh);
          keyboard
          for k=1:K
              for l=1:L
                  sig = sig + sum(rho(n,k)*rho(ngbh, k));
                  beta(k,l) = beta(k,l) + rhos(n, k)*d(l); 
              end
          end        
      end
  end
  alpha = newton_alpha(gammas)
  sig = 1/totalEdges*log(sig/sum(1/lams));
  % normalize beta 
  origbeta = beta;
  beta = beta./(repmat(sum(beta,2),1,k))
  if (numel(find(isnan(beta))) > 0)
      fprintf(' in trf beta is nan\n');
      keyboard
  end
  % converge?
  fprintf(1,'likelihood = %g\t',lik);
  if (j > 1) && converged(lik, pre_lik, 1.0e-5);
    fprintf(1,'\nconverged at iteration %d.\n', j);
    return;
  end
  pre_lik = lik;
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

