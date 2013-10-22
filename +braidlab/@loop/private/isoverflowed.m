function out = isoverflowed(v)
% If argument is an integer, test it against the overflow boundaries for its
% class.

% for integers, we have an upper and a lower boundary - test against each
if isinteger(v)
  myMax = intmax(class(v));
  myMin = intmin(class(v));
  out = any( v >= myMax) || any(v <= myMin );

elseif isfloat(v)
  % for doubles there is just a max, so test the absolute value against it
  myMax = realmax(class(v));
  out = any( abs(v) >= myMax );
else
  out = false;
end
