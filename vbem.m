function [gamma,xi,rho,lambda] = vbem(d,beta,alpha,mu,delta,sig,Learn)
% vbem.m
% update our variational parameters

Nd = size(d,1); % number of regions

gamma = zeros(1,k);
xi = zeros(Nd,k);
rho = zeros(Nd,k);
lambda = 1;

pxi = 
prho = 
for j = 1:Learn.V_Max_Iterations
  % vb-estep
  gamma = 
  xi = 
  rho = 
  lambda = 
  % converge?
  if (j > 1) && converged(pxi,xio,1.0e-2) && converged(pro,rho,1.0e-2)
    break;
  end
  pxi = xi;
  prho = rho;
end


