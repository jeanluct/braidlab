function [varargout] = conjtest(b1,b2)
%CONJTEST   Conjugacy test for braids.
%   ISCONJ = CONJTEST(B1,B2) returns true if B1 and B2 are conjugate
%   braids, that is, if there exists a braid C such that
%
%     B1 = C B2 C^-1
%
%   [ISCONJ,C] = CONJTEST(B1,B2) also returns the conjugating braid C.
%
%   B1 and B2 must be CFBRAID objects.
%
%   See also CFBRAID.

if nargout > 2
  error('BRAIDLAB:cfbraid:conjtest:nargout','Too many output arguments.');
end

if ~isa(b1,'braidlab.cfbraid') | ~isa(b2,'braidlab.cfbraid')
  error('BRAIDLAB:cfbraid:conjtest:badargs', ...
        'Function takes two CFBRAIDS as arguments.');
end

if istrivial(b1) | istrivial(b2)
  error('BRAIDLAB:cfbraid:conjtest:empty','Empty braid word.');
end

if b1.n ~= b2.n
  varargout{1} = false;
  if nargout > 1, varargout{2} = []; end
  return
end

% TODO: The braids are aleady in canonical form, but that's recomputed in
% the helper. Rewrite so the helper function accepts a struct.

[isconj,C] = conjtest_helper(b1.braid.word,b2.braid.word,b1.n);

varargout{1} = isconj;
if nargout > 1
  c = braidlab.cfbraid;
  c.delta = C.delta;
  c.factors = C.factors;
  c.n = b1.n;
  varargout{2} = c;
end
