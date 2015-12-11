function [W, N] = named_braid_binom(varargin)
%NAMED_BRAID_RANDOM(N,K) Generate a random braid on N strands and K
%generators, uniformly chosen.
%

parser = inputParser;
positiveNumber = @(x)validateattributes(x, {'numeric'}, {'positive','integer','scalar'});
parser.addRequired('n',positiveNumber);
parser.addRequired('k',positiveNumber);
parser.parse(varargin{:});
params = parser.Results;
n = params.n;
k = params.k;

W = (-1).^randi(2,1,k) .* (1+binornd( n-2, 1/2, 1,k ));
N = n;
