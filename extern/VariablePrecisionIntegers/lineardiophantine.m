function [x0,y0,xt,yt] = lineardiophantine(A,B,C)
% lineardiophantine: solve the linear Diophantine equation, A*x + B*y = C
% usage: [x0,x0,yt,yt] = lineardiophantine(A,B,C)
%
% http://en.wikipedia.org/wiki/Diophantine_equation
%
% The solution will be written parametrically as
%   x = x0 + xt*t
%   y = y0 + yt*t
% where t is any integer value
%
% Arguments: (input)
%  A,B,C - scalar, integer coefficients of the
%       linear Diophantine equation, A*x + B*y = C

if nargin~=3
  error('Must supply all three of A, B, C as arguments')
end

% special cases?
if C == 0
  % the solution is simple.
  % x = B*t, y = A*t
  x0 = 0;
  xt = B;
  y0 = 0;
  yt = -A;
  return
elseif (A == 0) && (B == 0)
  % No solution exists when both A and B
  % are zero, but C is non-zero
  x0 = [];
  xt = [];
  y0 = [];
  yt = [];
  
  warning('LINEARDIOPHANTINE:nosolution', ...
    'No solution exists, A==B==0, but C~=0')
  
  return
elseif A == 0
  % this reduces to the solutions of
  % B*y = C. B is not zero here.
  if gcd(B,C) == B
    y0 = C/B;
    yt = 0;
    x0 = 0;
    xt = 0;
    return
  else
    % no solution can exist otherwise
    x0 = [];
    xt = [];
    y0 = [];
    yt = [];
    
    warning('LINEARDIOPHANTINE:nosolution',...
      'No solutions exist, A == 0, but C is not divisible by B')
    
    return
  end
elseif B == 0
  % this reduces to the solutions of
  % A*x = C. A is not zero here.
  if gcd(A,C) == A
    y0 = 0;
    yt = 0;
    x0 = C/A;
    xt = 0;
    return
  else
    % no solution can exist otherwise
    x0 = [];
    xt = [];
    y0 = [];
    yt = [];
    
    warning('LINEARDIOPHANTINE:nosolution', ...
      'No solutions exist, B == 0, but C is not divisible by A')
    
    return
  end
end

% The final test is against the gcd(A,B).
% gcd(A,B) must also divide C.
G = gcd(A,B);
R = mod(C,G);
if R ~= 0
  x0 = [];
  xt = [];
  y0 = [];
  yt = [];
  
  warning('LINEARDIOPHANTINE:nosolution', ...
    'No solution can exist. C must be divisible by gcd(A,B).')
  
  return
end

% reduce the problem by dividing out any
% common factors of all three numbers.
A = A/G;
B = B/G;
C = C/G;

% negative C
if C < 0
  C = abs(C);
  A = -A;
  B = -B;
end
% or negative A or B
Asign = sign(A);
Bsign = sign(B);
A = abs(A);
B = abs(B);

% If we make it to here, then the solution
% is given by the extended Euclidean algorithm,
% which solves the problem for C == 1.
xt = B;
yt = -A;

% all we need now is one particular solution.
R1 = vpi(A); % make sure that quotient will run
R2 = B; % we already know that B ~= 0
[x1,x2] = deal(1,0);
[y1,y2] = deal(0,1);

% get the particular solution by iteratively calling quotient.
R = 1;
while (R~=0)
  [Q,R] = quotient(R1,R2);
  if R == 0
    % we are done
    x0 = x2;
    y0 = y2;
  else
    % more to do
    [R1,R2] = deal(R2,R);
    [x1,x2] = deal(x2,x1 - x2*Q);
    [y1,y2] = deal(y2,y1 - y2*Q);
  end
end

% now correct for C~=1
if C ~= 1
  x0 = x0*C;
  y0 = y0*C;
end

if Asign < 0
  x0 = -x0;
  xt = -xt;
end
if Bsign < 0
  y0 = -y0;
  yt = -yt;
end

