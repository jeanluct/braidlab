function [W,N] = named_braid_halftwist(varargin)
%NAMED_BRAID_HALFTWIST(N) Generate the braid word for a half-twist on N-strands.

parser = inputParser;
parser.addRequired('n', @(x)validateattributes(x, {'numeric'},...
                                               {'integer','>=',5}) );
parser.parse(varargin{:});
N = parser.Results.n;

% W has size br.n*(br.n-1)/2. Could preallocate if speed important.
W = [];
for i = 1:N,
  W = [W N-1:-1:i]; %#ok<AGROW>
end
