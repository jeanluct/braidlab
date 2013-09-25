function [varargout] = conjtest(b1,b2)
%CONJTEST   Conjugacy test for braids.
%   ISCONJ = CONJTEST(B1,B2) returns true if B1 and B2 are conjugate
%   braids, that is, if there exists a braid C such that
%
%     B1 = C B2 C^-1
%
%   [ISCONJ,C] = CONJTEST(B1,B2) also returns the conjugating braid C.
%
%   See also CFBRAID.

[isconj,C] = conjtest(braidlab.cfbraid(b1),braidlab.cfbraid(b2));

varargout{1} = isconj;
if nargout > 1
  varargout{2} = braidlab.braid(C);
end
