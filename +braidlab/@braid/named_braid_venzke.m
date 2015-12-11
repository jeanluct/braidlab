function [W, n] = named_braid_venzke(varargin)
%GENERATEVENZKE Generate a Venzke braid word W
%
% Input is the number of strands (at least 5).
% See:
%   R. Venzke, "Braid forcing, hyperbolic geometry, and pseudo-Anosov
%   sequences of low entropy," PhD Thesis (2008).

parser = inputParser;
parser.addRequired('n', @(x)validateattributes(x, {'numeric'},...
                                               {'integer','>=',5}) );
parser.parse(varargin{:});
n = parser.Results.n;

% See page 1 of Venzke's thesis.
if n == 6
  W = [5:-1:1 5 4 3 5 4];
  return
end
L = (n-1):-1:1;
if mod(n,2) == 1
  W = [L L -1 -2];
elseif mod(n,4) == 0
  k = n/4;
  W = [repmat(L,1,2*k+1) -1 -2];
elseif mod(n,8) == 2
  k = (n-2)/8;
  W = [repmat(L,1,2*k+1) -1 -2];
elseif mod(n,8) == 6
  k = (n-6)/8;
  W = [repmat(L,1,6*k+5) -1 -2];
end
N = n;
