function [gamma,xi,rho,lambda] = vbem(d,beta,alpha,mu,delta,sig,Learn)
% vbem.m
% update our variational parameters
%%%%%%%%%%

Nd = length(d.segLabels); % number of regions
K = Learn.Num_Topics; % Number of topics
L = Learn.Num_Prototypes; % Number of prototypes
F = Learn.Num_Neighbors; 
m = size(d.feat2,2); %number of features
neigh = d.adj; % a Nd x Nd binary matrix indicating the neighboors
               % for each region

xi = ones(Nd,L)/L;% xi = repmat((1:l)/l,Nd,1); % Nd by L
rho = ones(Nd, K)/K; % Nd by K

E = sum(min([sum(neigh,1) ; repmat(F,1,Nd)]))/2;

dfeat = d.feat2; % Nd x m 

%% UPDATE
gamma = alpha + sum(rho,1);
lambda = exp(E*sig); %exp(E)*sig;
for j=1:Learn.V_Max_Iterations
    for n = 1:Nd  % Looping over each region    
        x_n =dfeat(n,:)'; % mx1    
        for l = 1:L
            for k = 1:K
                lhs = beta(l,k)*((2*pi*delta(l,k))^(-m/2));
                xi(n,l) = xi(n,l)*(lhs*exp(-(x_n-squeeze(mu(l,k,:)))'*(x_n-squeeze(mu(l,k,:)))/(2*delta(l,k))))^rho(n,k);
            end % end k
        end % end l
        origxi = xi;
        xi = xi./(repmat(sum(xi,2),1,l));        
        if (numel(find(isnan(xi))) > 0 || numel(find(isinf(xi))) > 0)
            fprintf(' in vbem xi is nan or inf\n');
            keyboard
        end

        for k = 1:K
            % pick random E neighbors
            ngbh = find(d.adj(n,:));
            if numel(ngbh) > 5
                %  ngbh = ngbh(randperm(numel(ngbh))); % permute
                ngbh = ngbh(1:F); % pick first E nbghs
            end
            rho(n,k) = exp(psi(gamma(k)) - psi(sum(gamma)) + ...
                           sum(rho(ngbh,k))*sig);
            for l = 1:L
                lhs = beta(l,k)*((2*pi*delta(l,k))^(-m/2));            
                rho(n,k) = rho(n,k)*(lhs*exp(-(x_n-squeeze(mu(l,k,:)))'*(x_n-squeeze(mu(l,k,:)))/(2*delta(l,k))))^xi(n,l);
            end % end l
        end % end k                
    end % end n        
    %% normalize rho and xi
    origrho = rho;
    rho = rho./(repmat(sum(rho,2),1,k));                
    if (numel(find(isnan(rho))) > 0)
        fprintf(' in vbem rho is nan\n');
        keyboard
    end
    gamma = alpha + sum(rho,1);
    if (j>1) && converged (xi, pre_xi, 1.0e-2) &&...
            converged(rho, pre_rho, 1.0e-2) && ...
            converged(gamma, pre_gamma, 1.0e-2)
        break;
    end
    pre_rho = rho;
    pre_xi = xi;
    pre_gamma = gamma;
end
