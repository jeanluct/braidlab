function res = comparemagnitudes(mp1,mp2)
% true if abs(mp1) >= abs(mp2)
%
%
%  See also: ge, le, gt, lt
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09


% find the index of the last (highest order)
% non-zero digit
n1 = order(mp1) + 1;
n2 = order(mp2) + 1;

if n1 > n2
  % n1 has more decimal digits than mp1
  res = true;
elseif n1 < n2
  % mp1 has fewer decimal digits than mp2
  res = false;
else
  % the two numbers have the same
  % number of decimal digits, so we
  % need to do a deeper comparison.
  
  % Work backwards, comparing the last
  % digit first.
  res = true;
  for k = n1:-1:1
    d1 = mp1.digits(k) - mp2.digits(k);
    if d1 > 0
      break
    elseif d1 < 0
      res = false;
      break
    end
  end
end