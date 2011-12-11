function lik = trf_likelihood(d,beta,gammas)
% TRF likelihood
% returns the likelihood of d, given TRF model of (beta,
% gammas) i.e:

%
%
egamma = mnormalize(gammas,2);
lik = 0;
n = length(d);
for i = 1:n
  t = d{i};
  lik = lik + t.cnt * (beta(t.id,:) * egamma(i,:)');
end
