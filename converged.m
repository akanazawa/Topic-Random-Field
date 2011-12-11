function b = converged(u,udash,threshhold)
% converged(u,udash,threshhold)
% Returns 1 if u and udash are not different by the ratio threshhold
% (default 0.001).
% Mon May 17 20:01:31 JST 2004 dmochiha@slt

% threshold
if (nargin < 3)
    threshhold = 1.0e-3;
end
% main
if (diff_vec(u, udash) < threshhold)
    b = true;
else
    b = false;
end

end

function p = diff_vec(u,v)
% p = diff_vec(u,v)
% Returns a difference ratio of v, w.r.t. u.
% $Id: diff_vec.m,v 1.2 2004/11/12 12:45:01 dmochiha Exp $
p = norm(u - v) / norm(u);

end
