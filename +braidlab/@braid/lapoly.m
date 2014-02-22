function p = lapoly(b,x,maxit,nconvreq)
%LAPOLY   Characteristic polynomial of effective linear action of a braid.
%   P = LAPOLY(B) returns the characteristic polynomial P of the last matrix
%   in the limit cycle obtained from LACYCLE(B).  The polynomial is in
%   standard Matlab form as a vector of coefficients, with the highest
%   power listed first.
%
%   This polynomial is representative of the asymptotic behavior of the
%   braid action on loops.  In particular, its largest eigenvalue
%   corresponds to the dilatation of braid.
%
%   P = LAPOLY(B,X) returns P as a polynomial in the symbolic
%   variable X = sym('x').
%
%   P = LAPOLY(B,X,MAXIT,NCONVREQ) passes MAXIT and NCONVREQ to
%   BRAID.LACYCLE.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP, BRAID.LACYCLE, BRAID.LAMAT.

if nargin < 2, x = []; end

% Get defaults for maxit and nconvreq from lacycle.
if nargin < 3, maxit = []; end
if nargin < 4, nconvreq = []; end

p = charpoly(lamat(b,maxit,nconvreq),x);
