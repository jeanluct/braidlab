function INT = base2vpi(B,base)
% bin2vpi: converts an integer in an arbitrary base into vpi (decimal) form
% usage: INT = base2vpi(B,base)
%
% arguments: (input)
%  B - Digits as a numeric vector in a base 
%      specified by base. The highest order
%      digit comes first in this representation.
%
%      The elements of B must be non-negative
%      integers, strictly less than base.
%
%  base - scalar, integer, positive numeric
%      2 <= base <= 2^26
%
% arguments: (output)
%  INT - the vpi form of the integer represented by B
%
%
% Example:
%  base2vpi(1:9,10)
%  ans =
%      123456789
%
%
%  See also: base2dec, dec2base, vpi2base, bin2vpi, vpi2bin
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/24/09

if (nargin~=2)
  error('Two arguments are required')
end

% insure that B is a numeric vector
if isempty(B)
  INT = vpi(0);
  return
elseif ~isvector(B) || any(B<0) || any(B>=base) || any(B~=round(B))
  error('B must contain numeric, nonegative integer elements < base')
end

% just use Horner's method for the conversion
INT = vpi(B(1));
vbase = vpi(base);
for i = 2:length(B)
  INT = INT*vbase + B(i);
end


