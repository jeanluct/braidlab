function S = single(INT)
% vpi/single: conversion from a vpi object to a single.
% usage: S = single(INT);
% 
% arguments: (input)
%  INT - a vpi object
%
% arguments: (output)
%  S  - the single precision representation of the
%       integer stored in INT.
% 
% Example:
%  m = vpi(1234567);
%  single(m)
%  ans = 
%     1234567
%
%
%  See also: double, vpi
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if numel(INT) == 1
  % start at the higherst non-zero power,
  % in case of leading zeros.
  n = find(INT.digits,1,'last');
  S = INT.digits(n);
  if n > 1
    stop = 10;
    for i = (n-1):-1:1
      % just Horner's rule here. No problem
      % with subtractive cancellation since
      % all the terms are positive.
      if (i+stop) > n
        S = 10*S + INT.digits(i);
      else
        S = S*10^i;
        break
      end
    end
  end
  
  % is it a negative integer?
  if INT.sign<0
    S = -S;
  end
  
  % make the result a single
  S = single(S);
  
else
  % an array
  S = zeros(size(INT));
  for i = 1:numel(INT)
    S(i) = single(INT(i));
  end
end
  
  
  