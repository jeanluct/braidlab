function [varargout] = tntype(b)
%TNTYPE   Thurston-Nielsen type of a braid.
%   T = TNTYPE(B) returns the Thurston-Nielsen type of a braid B.  The braid
%   is regarded as labeling an isotopy class on the punctured disk.  The
%   type T can take the values 'finite-order', 'reducible', or
%   'pseudo-Anosov', following the Thurston-Nielsen classification theorem.
%
%   [T,ENTR] = TNTYPE(B) also returns the entropy ENTR of the braid.
%
%   TNTYPE uses Toby Hall's implementation of the Bestvina-Handel algorithm.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY.

if b.n >= 3
  [TN,entr] = tntype_helper(b.word,b.n);
else
  TN = 'finite-order';
  entr = 0;
end

if any(strcmp(TN,{'reducible1','reducible2'}))
  varargout{1} = 'reducible';
else
  varargout{1} = TN;
end

% Optionally also return entropy, since we get it for free as well.
if nargout > 1, varargout{2} = entr; end
