function [gamma,xi,rho,lambda] = vbem(d,beta,alpha,mu,delta,sig,Learn)
% vbem.m
% update our variational parameters for LDA+MRF, no guassian noise channel
%%%%%%%%%%

Nd = length(d.segLabels); % number of regions
K = Learn.Num_Topics; % Number of topics

F = Learn.Num_Neighbors; 
m = Learn.Dict_Size; %number of features
neigh = d.adj; % a Nd x Nd binary matrix indicating the neighboors
               % for each region

rho = ones(Nd, K)/K; % Nd by K

% convergence criteria
tau = 1e-2;
pre_xi = xi;
pre_rho = rho;

inside = zeros(L,K);
lhs = zeros(L,K);
E = sum(min([sum(neigh,1) ; repmat(F,1,Nd)]))/2;

dfeat = d.feat2; % Nd x m 

%% UPDATE
gamma = alpha + sum(exp(rho),1);
lambda = exp(E*sig); %exp(E)*sig;
for j=1:Learn.V_Max_Iterations
    fprintf(1,'\t vb em iteration %d/%d..\n',j,Learn.V_Max_Iterations);
    for n = 1:Nd  % Looping over each region    
        x_n =dfeat(n,:)'; % mx1    
        for k = 1:K
            % pick random E neighbors
            ngbh = find(d.adj(n,:));
            if numel(ngbh) > 5
                ngbh = ngbh(randperm(numel(ngbh))); % permute
                ngbh = ngbh(1:F); % pick first E nbghs
            end
            rho(n,k) = exp(psi(gamma(k)) - psi(sum(gamma)) + sum(pre_rho(ngbh,k))*sig);
        end % end k                
    end % end n        
    %% normalize xi
    keyboard;
    origrho = rho;
    %    rho = exp(rho); % if done in log
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
