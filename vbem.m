function [gamma,xi,rho,lambda] = vbem(d,beta,alpha,mu,delta,sig,Learn)
% vbem.m
% update our variational parameters
%%%%%%%%%%

Nd = length(d.segLabels); % number of regions
k = Learn.Num_Topics;
l = Learn.Num_Prototypes;

gamma = zeros(1,k);
xi = zeros(l,k);
rho = zeros(1,k);
lambda = 1;
keyboard
pxi = 0;
prho = 0;
for j = 1:Learn.V_Max_Iterations
  % vb-estep
  gamma = rand(1,k)
  xi = rand(l,k)
  rho = rand(1,k)
  lambda = rand(1);
  % converge?
  if (j > 1) && converged(pxi,xio,1.0e-2) && converged(pro,rho,1.0e-2)
    break;
  end
  pxi = xi;
  prho = rho;
end


