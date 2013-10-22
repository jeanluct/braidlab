function S = sign(INT)
% vpi/sign: sign of a vpi object or array
% usage: S = sign(INT);
% 
% This replicates the operation of the sign
% function when applied to a VPI object.
%
% arguments:
%  INT - a vpi object, or array of vpi numbers
%
%  S   - Takes the sign of INT. One of
%        {-1, 0, +1} will be returned.
%        S will be a double.
%
% Example:
%  sign(vpi(-5))
%  ans = 
%     -1
%
%  sign(vpi(0))
%  ans = 
%     0
%
% Example: (Applied to a vpi array)
%  A = vpi(magic(4) - 8);
%  sign(A)
%
% ans =
%      1    -1    -1     1
%     -1     1     1     0
%      1    -1    -1     1
%     -1     1     1    -1
%
%  See also: abs
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if isempty(INT)
  S = [];
elseif numel(INT) == 1
  % three possible results
  if all(~INT.digits)
    S = 0;
  elseif INT.sign>0
    S = 1;
  else
    S = -1;
  end
else
  % an array. cellfun trick, extracting
  % the signs of all at once
  S = zeros(size(INT));
  % multiple elements
  for i = 1:numel(INT)
    S(i) = sign(INT(i));
  end
end
