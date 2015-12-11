function [W, N] = named_braid_hk(varargin)
%NAMED_BRAID_HK Generate a Hironaka-Kin braid family.
%
% NAMED_BRAID_HK(M,N)
%
% See:
%   E. Hironaka and E. Kin, "A family of pseudo-Anosov braids with small
%   dilatation," Alg. Geom. Topology 6 (2006), 699-738.

parser = inputParser;
parser.addRequired('m',@isscalar);
parser.addOptional('n',nan,@isscalar);
parser.parse(varargin{:});
params = parser.Results;
m = params.m;
n = params.n;

if isnan(n)
  if m < 5
    error('BRAIDLAB:braid:named_braid_hk:badarg', ...
          'Need at least five strings.')
  end
  if mod(m,2) == 1
    n = (m+1)/2; %#ok<*PROP>
    m = (m-3)/2;
  else
    n = (m+2)/2;
    m = (m-4)/2;
  end
  %
end

N = m+n+1;
W = [1:m m:-1:1 1:N-1];
