function INT = mtimes(INT1,INT2)
% vpi/mtimes: Matrix multiplication of two vpi objects, or a product of a numeric var to an vpi
% usage: INT = INT1*INT2;
% usage: INT = mtimes(INT1,INT2);
% 
% arguments:
%  INT,INT1,INT2 - vpi numbers, arrays, or numeric variables
%
% 
%  See also: times
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if nargin ~= 2
  error('2 arguments required. mtimes is a dyadic operator.')
end

nint1 = numel(INT1);
nint2 = numel(INT2);
if (nint1 == 1) || (nint2 == 1)
  % scalar inputs or scalar expansion,
  % implement as just a call to times
  INT = INT1.*INT2;
elseif (nint1*nint2) == 0
  % empty will propagate
  INT = [];
else
  % an array multiplication
  S1 = size(INT1);
  S2 = size(INT2);
  
  % do not allow multiplication of arrays
  % in higher dimensions to be consistent
  % with standard matlab syntax.
  if (length(S1) > 2) || (length(S2) > 2)
    error('Matrix multiplication of multidimensional arrays is not supported')
  end
  
  % Do the arrays conform in size?
  if S1(2) ~= S2(1)
    error('The arrays do not conform in size for matrix multiplication')
  end
  
  % preallocate the result as zeros
  INT = repmat(vpi(0),S1(1),S2(2));
  % just loops now
  for i = 1:S1(1)
    for j = 1:S2(2)
      for k = 1:S1(2)
        INT(i,j) = INT(i,j) + INT1(i,k).*INT2(k,j);
      end
    end
  end
end




