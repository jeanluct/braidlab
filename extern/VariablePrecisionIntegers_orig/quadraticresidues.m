function residuelist = quadraticresidues(N)
% quadraticresidues: returns a list of the possible quadratic residues of the integer N
% usage: residuelist = quadraticresidues(N)
%
% arguments: (input)
%   N - a scalar integer or vpi number
%       N may NOT exceed 2^25 in magnitude
% 
% arguments: (output)
%  residuelist - numeric vector of all possible
%       quadratic residues, modulo N. The list
%       will be sorted in increasing order.
%
% A quadratic residue, defined by:
%
% http://en.wikipedia.org/wiki/Quadratic_residue
% http://mathworld.wolfram.com/QuadraticResidue.html
%
% is an integer q such that q == mod(x^2,N), for SOME
% integer x. In general, for a prime number N, there
% will be ceil((N+1)/2) quadratic residues.
%
% For example, when N = 5, there are 3 distinct
% possible quadratic residues, [0 1 4].
%
% quadraticresidues(5)
%  ans =
%       0  1  4
%
% See also: mod, rem, power, factor
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 2/9/09


if nargin~=1
  error('Must have exactly one argument')
end

% can be no larger than 2^25
if abs(N) > (2^25)
  error('N may be no larger than 2^25')
end

% since it is known to be less than 2^25
if isa(N,'vpi')
  N = double(N);
end
  
residuelist = unique(mod((0:(abs(N)/2)).^2,N));




