function eq = cfequal(cf1,cf2)
%CFEQUAL   Test equality of two braids in left or right canonical form.
%   CFEQUAL(CF1,CF2) returns true if the two structures CF1 and CF2 (as
%   output by CANFORM) are equal, otherwise false.  The two must be in
%   the same canonical form (left or right).
%
%   See also CANFORM, CFLENGTH, CFWORD.

if ~strcmp(cf1.type,cf2.type)
  error('BRAIDLAB:cfequal:typemismatch', ...
	'The two braids must be in the same type of canonical form.')
end

if cf1.delta ~= cf2.delta | cf1.n ~= cf2.n
  eq = false;
  return
end

fac1 = cell2mat(cf1.factors);
fac2 = cell2mat(cf2.factors);

if length(fac1) ~= length(fac2), eq = false; return; end

if any(fac1 - fac2), eq = false; return; end

eq = true;
