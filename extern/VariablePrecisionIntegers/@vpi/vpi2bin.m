function B = vpi2bin(INT)
% vpi/vpi2bin: Converts a vpi number to binary (highest order bit first)
% usage: B = vpi2bin(INT)
% 
% arguments: (input)
%  INT - a vpi scalar. Sign will be ignored.
% 
% arguments: (output)
%  B - character string representation of the
%      binary number, consistent with dec2bin.
%      The highest order bits will be first in
%      this representation.
%
%      The character string can be converted
%      to a boolean vector simply by either of
%      several artifices. Either of these is
%      good:
%
%      Bool = (B == '1');
%
%        ... or ...
%
%      Bool = B - 48;
%
% Example:
%  D = vpi(17)^17;
%  vpi2bin(D)
% ans =
%   1011001101100001000011110010110100011101100100001101110000100100010001
%
% Example:
%  D = vpi(2)^75 - 1;
%  vpi2bin(D)
%  ans =
%   111111111111111111111111111111111111111111111111111111111111111111111111111
%
%
%  See also: bin2vpi, dec2bin, bin2dec
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

% error check
if nargin~=1
  error('vpi2bin takes only one argument')
end

% we know the input must be a vpi object, since
% this is the only way to have gotten to this
% point in the code.
if any(INT(:)<0)
  error('vpi2bin only works on non-negative vpi integers')
end

% just use vpi2base
B = char(vpi2base(INT,2)+48);




