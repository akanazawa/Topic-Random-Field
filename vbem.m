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
L = size(data{1}.vq, 2); % length of code book
neigh = d.adj; % a Nd x Nd binary matrix indicating the neighboors
               % for each region

totalEdges = sum(min([sum(neigh,1) ; repmat(E,1,Nd)]))/2;

%% Initialize
gamma = alpha + sum(exp(rho),1);
lambda = exp(totalEdges*sig); 
rho = ones(Nd, K)/K; % Nd by K

%% convergence criteria
tau = 1e-2;
pre_xi = xi;
pre_rho = rho;

inside = zeros(L,K);
lhs = zeros(L,K);

dfeat = d.vq; % Nd x L

for j=1:Learn.V_Max_Iterations
    fprintf(1,'\tvb em iteration %d/%d..\n',j,Learn.V_Max_Iterations);
    for n = 1:Nd 
        x_n =dfeat(n,:)'; % Lx1    
        for k = 1:K
            ngbh = getNeighbors(d, n, E);
            rho(n,k) = beta(n,k)*exp(psi(gamma(k)) - psi(sum(gamma)) + sum(pre_rho(ngbh,k)*sig));
        end % end k                
    end % end n        
    %% normalize rho
    keyboard;
    origrho = rho;
    rho = rho./(repmat(sum(rho,2),1,k));                
    if (numel(find(isnan(rho))) > 0)
        fprintf(' in vbem rho is nan\n');
        keyboard
    end
    gamma = alpha + sum(rho,1);

    if (j>1) && converged(rho, pre_rho, tau) && ...
            converged(gamma, pre_gamma, tau)
        break;
    end
    pre_rho = rho;
    pre_gamma = gamma;
end
