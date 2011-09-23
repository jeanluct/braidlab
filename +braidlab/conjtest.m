function [varargout] = conjtest(w1,w2,n)
%CONJTEST   Conjugacy test for braids.
%   CONJ = CONJTEST(W1,W2,N) returns true if W1 and W2 are conjugate
%   braids, that is, if there exists a braid C such that
%
%     W1 = C W2 C^-1
%
%   N is the order of the braid group, which is deduced if omitted.
%   [CONJ,C] = CONJTEST(W1,W2,N) also returns the conjugating braid C.
%
%   W1 and/or W2 can also be specified as braid structs.

import braidlab.cfword

if nargout > 2
  error('BRAIDLAB:conjtest:nargout','Too many output arguments.');
end

if nargin < 2
  error('BRAIDLAB:conjtest:nargin','Not enough input arguments.');
end

if nargin > 3
  error('BRAIDLAB:conjtest:nargin','Too many input arguments.');
end

if isstruct(w1)
  if nargin > 2
    error('BRAIDLAB:conjtest:badorder', ...
	  'Cannot specify N on the command line if a braid struct is used.');
  end
  n = w1.n;
  w1 = cfword(w1);
end

if isstruct(w2)
  if nargin > 2
    error('BRAIDLAB:conjtest:badorder', ...
	  'Cannot specify N on the command line if a braid struct is used.');
  end
  if exist('n','var') == 1
    % w1 is also a braid struct.  They must have the same order.
    if n ~= w2.n
      error('BRAIDLAB:conjtest:badorder','Braid order mismatch.');
    end
  else
    n = w2.n;
  end
  w2 = cfword(w2);
end

if nargin < 3 & exist('n','var') ~= 1
  n = max(max(abs(w1))+1,max(abs(w2))+1);
else
  % Check that this is compatible with w1.
  if n < max(abs(w1))+1
    error('BRAIDLAB:conjtest:badorder','Order of W1 too large.');
  end
  if n < max(abs(w2))+1
    error('BRAIDLAB:conjtest:badorder','Order of W2 too large.');
  end
end


if isempty(w1) | isempty(w2)
  error('BRAIDLAB:conjtest:empty','Empty braid word.');
end

% TODO: Check if the braids are already in canonical form?  Seems a shame
% to recompute it.  Then the helper function shoud accept a struct.

[conj,C] = conjtest_helper(w1,w2,n);

varargout{1} = conj;
if nargout > 1
  varargout{2} = C;
end
