function test_entropy(n,tol)

% Try new method of finding entropy, directly from the linearized action matrix.

import braidlab.*

if nargin < 1, n = 15; end
if nargin < 2, tol = 1e-8; end

b = compact(braid('psi',n));

r = psiroots(n);
eex = log(max(abs(r)));

fprintf('Old method:\n')

tic
tol = 1e-9;
e1 = entropy(b,tol);
toc
fprintf('diff1=%.3e\n',abs(e1-eex))

fprintf('New method:\n')

tic
e2 = entropy2(b,tol);
toc

fprintf('diff2=%.3e\n',abs(e2-eex))

%================================================================
function [varargout] = entropy2(b,tol,maxit,nconvreq)
%ENTROPY   Topological entropy of a braid.

if nargin < 2, tol = 1e-6; end

% Get defaults for maxit and nconvreq from cycle.
if nargin < 3, maxit = []; end
if nargin < 4, nconvreq = []; end

[M,period] = cycle(b,maxit,nconvreq);

method = 'eigs';

switch method
 case 'charpoly'
  % Use characteristic polynomial: very slow
  varargout{1} = log(sort(abs(roots(charpoly(M))),'descend'));
  varargout{1} = varargout{1}(1) / period;

 case 'eigs'
  opts.isreal = true;
  opts.tol = tol;

  varargout{1} = log(abs(eigs(M,1,'LM',opts))) / period;

 case 'eig'
  varargout{1} = log(sort(abs(eig(full(M))),'descend'));
  varargout{1} = varargout{1}(1) / period;

end
