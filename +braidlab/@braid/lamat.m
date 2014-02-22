function M = lamat(b,maxit,nconvreq)
%LAMAT   Final matrix of cyclic effective linear action of a braid.
%   P = LAMAT(B) returns the last sparse matrix M in the limit cycle
%   obtained from LACYCLE(B).
%
%   This matrix is representative of the asymptotic behavior of the braid
%   action on loops.  In particular, its largest eigenvalue corresponds to
%   the dilatation of braid.
%
%   P = LAMAT(B,MAXIT,NCONVREQ) passes MAXIT and NCONVREQ to BRAID.LACYCLE.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP, BRAID.LACYCLE, BRAID.LAMAT.

% Get defaults for maxit and nconvreq from lacycle.
if nargin < 2, maxit = []; end
if nargin < 3, nconvreq = []; end

pn = lacycle(b,maxit,nconvreq);

% Get matrix from the last iterate.
M = linact(b,pn(end,:));
