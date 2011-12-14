function [alpha, beta, sig] = lda_mrf(data, Learn, VQ)
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
L = VQ.Num_Vocab; % size of vocabulary
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
  rhos = cell(D, 1);
  lams = zeros(D,1);
  lik = 0;
  %%%%% E step find the best variational parameters %%%%%
  for d = 1:D
    [gamma,rho,lambda] = vbem(data{d},beta,alpha,sig,Learn);
    gammas(d,:) = gamma;
    rhos{d} = rho; % Ndxk 
    lams(d) = lambda;
    lik = lik + lda_mrf_lik(data{d}, alpha, beta, sig, gamma, rho, lambda);
  end
  keyboard
  fprintf('likelihood = %g\t',lik);

  %%%%% M-step of alpha and normalize beta and all the otehrs %%%%%
  totalEdges = 0;
  for d=1:D
      dd = data{d};
      Nd = length(dd.segLabels); % number of regions    
      vq = dd.vq; 
      for n=1:Nd        
          rho = rhos{d};
          ngbh = getNeighbors(dd, n, E);
          totalEdges = totalEdges + numel(ngbh);
          sig = sig + sum(sum(bsxfun(@times, rho(n,:), rho(ngbh, :))));
          beta(:, vq(n)) = beta(:, vq(n)) + rho(n, :)';
      end
  end

  alpha = newton_alpha(gammas)
  sig = 1/totalEdges*log(sig/sum(1./lams));
  % normalize beta 
  origbeta = beta;
  beta = beta./(repmat(sum(beta,2),1,L));
  if (numel(find(isnan(beta))) > 0)
      fprintf(' in trf beta is nan\n');
      keyboard
  end
  if (j > 1) && converged(lik, pre_lik, 1.0e-5);
    fprintf(1,'\nconverged at iteration %d.\n', j);
    return;
  end
  pre_lik = lik;
  % ETA
  elapsed = toc;
  fprintf(1,'ETA:%s (%d sec/step)\r',rtime(elapsed * (Learn.Max_Iterations / j  - 1)),round(elapsed / j));
end

end
%fprintf(1,'\n');

% if LDA:
% dig = digamma(ldagamma);
% digsum = digamma(sum(ldagamma));
% likelihood=gammaln(sum(a))-sum(gammaln(a)) + sum((a-1).*(dig-digsum)) ...
%     - gammaln(sum(ldagamma))+sum(gammaln(ldagamma)) ...
% 	- sum((ldagamma-1).*(dig-digsum)) - sum(sum(ldaphi.*log(ldaphi))) ...
% 	+ (dig-digsum)'*sum(ldaphi,2) + sum(sum(ldaphi.*log(b(:,d))));

% alpha = K by 1
% beta = K by L
% rho = Nd by K
% sig = scalar
% gamma  = K by 1

function [likelihood] = lda_mrf_lik(data, alpha, beta,sig,gam,rho,lambda)
  m = size(data,2); %number of features
  Nd = size(data.feat2, 1); % number of regions    
  d = data.vq; % Nd x 1   
  
  digamma = psi(gam);
  digamma_sum = psi(sum(gam));
  line1 = gammaln(sum(alpha)) - sum(gammaln(alpha)) ...
      + sum((alpha-1).*(digamma - digamma_sum));
  line2 = (digamma-digamma_sum)*sum(rho)'; %need to add neighbor
                                          %terms
  line3 = sum(sum(rho.*log(beta(:, d)')));
  line5 = -gammaln(sum(gam)) + sum(gammaln(gam)) ...
           - sum( (gam-1).*(digamma - digamma_sum));
  line6 = - sum(sum(rho.*log(rho)));
  likelihood =  line1 + line2 + line3 + line5 + line6; 
end

