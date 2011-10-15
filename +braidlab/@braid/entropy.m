function entr = entropy(b,tol,maxrep)
%ENTROPY   Topological entropy of a braid.
%   ENTR = ENTROPY(B) returns the 
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.LENGTH, BRAID.INTAXIS.

lenfun = @intaxis; % length function: length or intaxis

if nargin < 2, tol = 1e-6; end
if nargin < 3, maxrep = 100; end

% Use a fundamental group generating set as the initial multiloop.
u = braidlab.loop(b.n);
entr0 = -1;
logL0 = log(lenfun(u));
for i = 1:maxrep
  u = b*u;
  logL = log(lenfun(u));
  entr = logL-logL0;
  % Check if we've congerved to desired tolerance.
  if abs(entr-entr0) < tol, break; end
  entr0 = entr; logL0 = logL;
end
if i == maxrep
  warning('BRAIDLAD:braid:entropy:noconv', ...
	  'Failed to converge to desired tolerance.')
end
