function int = loopinter(u)
%LOOPINTER   The number of intersections of a loop with the real axis.
%   I = LOOPINTER(U) computes the minimum number of intersections of a loop
%   (encoded in Dynnikov coordinates) with the real axis.  (See Moussafir
%   (2006), Proposition 4.4.)  U is either a row-vector, or a matrix of
%   row-vectors, in which case the function acts vectorially on each row.

n = size(u,2)/2 + 2;
a = u(:,1:n-2); b = u(:,(n-1):end);
cumb = [zeros(size(u,1),1) cumsum(b,2)];
% The number of intersections before/after the first and last punctures.
% See Hall & Yurttas (2009).
b0 = -max(abs(a) + max(b,0) + cumb(:,1:end-1),[],2); bn = -b0 - sum(b,2);
int = sum(abs(b),2) + sum(abs(a(:,2:end)-a(:,1:end-1)),2) ...
      + abs(a(:,1)) + abs(a(:,end)) + abs(b0) + abs(bn);
