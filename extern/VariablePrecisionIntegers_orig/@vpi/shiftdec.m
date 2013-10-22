function N = shiftdec(N,shift)
% shiftdec: digit shift left or right, an efficient multiply or divide by powers of 10
% usage: N = shiftdec(N,shift)
%
% Positive shifts are equivalent to a multiply by
% that power of 10. Negative shifts are divides by
% the equivalent power of 10. Any fractional parts
% are discarded, as would do rdivide.
%
% arguments: (input)
%  N - a vpi number or vector or array of numbers
%
%  shift - a numeric integer scalar, denotes
%      the number of digits to shift by. A
%      shift of 0 is a no-op.
%
% Example:
%  N = vpi(1234567)
%  shiftdec(N,3)
%
%  ans =
%     1234567000
%
%  shiftdec(N,-3)
%
%  ans =
%     1234
%
%  See also: digits, rdivide, quotient, times
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 4/22/09

if (nargin ~= 2)
  error('shiftdec requires exactly two arguments')
end

% shift must be scalar integer, numeric
shift = double(shift);
if isempty(shift) || (numel(shift) ~= 1) || (shift~=round(shift))
  error('shift must be scalar, integer')
end

% ensure that the result is vpi
N = vpi(N);

% shift == 0 is a no-op
if shift > 0
  % positive shifts are multiplies by 10
  for i = 1:numel(N)
    D = digits(N(i));
    D = [D,zeros(1,shift)]; %#ok
    N(i) = digits(N(i),D);
  end
elseif shift < 0
  % positive shifts are divides by 10
  for i = 1:numel(N)
    D = digits(N(i));
    if numel(D) <= -shift
      % N(i) lost all of its digits
      N(i) = digits(N(i),0);
    else
      % truncate a few digits
      D(end + ((1+shift):0)) = [];
      N(i) = digits(N(i),D);
    end
  end
end






