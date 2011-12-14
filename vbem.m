function [gamma,rho,lambda] = vbem(d,beta,alpha,sig,Learn)
% vbem.m
% update our variational parameters for LDA+MRF, no guassian noise
% channel: 
% INPUT - d: data, with field adj (Nd x Nd) and d.vq (Nd x L)
%       - alpha, beta, sig: parameters from M step
% OUTPUT - best variational parameters:
%          gamma - K x 1
%          rho - Nd x K
%          lamdba - scalar
%
% Angjoo Kanazawa 12/13/2011
%%%%%%%%%%

%% Learning Settings
Nd = length(d.segLabels); % number of regions
K = Learn.Num_Topics; % Number of topics
E = Learn.Num_Neighbors; 
neigh = d.adj; % a Nd x Nd binary matrix indicating the neighboors
               % for each region

totalEdges = sum(min([sum(neigh,1) ; repmat(E,1,Nd)]))/2;

%% Initialize
rho = ones(Nd, K)/K; % Nd by K
gamma = alpha + sum(exp(rho),1);
lambda = exp(totalEdges*sig); 

%% convergence criteria
tau = 1e-2;
pre_rho = rho;

d_vq = d.vq; % Nd x 1˘

for j=1:Learn.V_Max_Iterations
    %    fprintf(1,'vb em itr %d/%d..',j,Learn.V_Max_Iterations);
    fprintf('.');
    for n = 1:Nd
        ngbh = getNeighbors(d, n, E);
        rho(n,:) = beta(:, d_vq(n))'.*exp(psi(gamma) - psi(sum(gamma)) + sum(pre_rho(ngbh,:)*sig));
    end
    %% normalize rho
    rho = rho./(repmat(sum(rho,2),1,K));                
    if (numel(find(isnan(rho))) > 0)
        fprintf(' in vbem rho is nan\n');        keyboard
    end
    gamma = alpha + sum(rho,1);

    if (j>1) && converged(rho, pre_rho, tau) && converged(gamma, pre_gamma, tau)
        break;
    end
    pre_rho = rho;

    pre_gamma = gamma;
end
fprintf('|');
