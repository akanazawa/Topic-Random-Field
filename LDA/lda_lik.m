function lik = lda_lik(d,beta,gammas)
% lik = lda_lik(d,beta,gammas)
% returns the likelihood of d, given LDA model of (beta, gammas).
% Fri Oct 22 22:14:48 JST 2004 dmochiha@slt.atr.jp
% $Id: lda_lik.m,v 1.2 2004/10/26 02:24:18 dmochiha Exp $
egamma = mnormalize(gammas,2);%100x20
lik = 0;
n = length(d);
for i = 1:n
  t = d{i};
  lik = lik + t.cnt * ( beta(t.id,:) * egamma(i,:)' );
  %           1x69 * 69x20 * 20x1
  %before log:     
end
