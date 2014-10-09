function D = double(INT)
% vpi/double: conversion from a vpi object to a double.
% usage: D = double(INT);
% 
% arguments: (input)
%  INT - a vpi object
%
% arguments: (output)
%  D  - the double precision representation of the
%       integer stored in INT.
% 
% Example:
%  m = vpi(1234567);
%  double(m)
%  ans = 
%     1234567
%
%
%  See also: single, vpi
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if numel(INT) == 1
  % start at the highest non-zero power,
  % in case of leading zeros.
  n = find(INT.digits,1,'last');
  D = INT.digits(n);
  if n > 1
    stop = 18;
    for i = (n-1):-1:1
      % just Horner's rule here. No problem
      % with subtractive cancellation since
      % all the terms are positive.
      if (i+stop) > n
        D = 10*D + INT.digits(i);
      else
        D = D*10^i;
        break
      end
    end
  end
  if isempty(D)
    D = 0;
  end
  
  % is it a negative integer?
  if INT.sign<0
    D = -D;
  end
  
else
  % an array
  D = zeros(size(INT));
  for i = 1:numel(INT)
    D(i) = double(INT(i));
  end
end


