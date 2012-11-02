function [Root,excess] = sqrt(N)
% vpi/sqrt: Integer part of the square root of the (non-negative) vpi number N
% usage: Root = sqrt(N)
%
%
% arguments: (input)
%  N - a vpi scalar (positive) integer
%      N must be non-negative, or an error will
%      result.
%
%
% arguments: (output)
%  Root - The largest non-negative vpi integer
%      such that Root^2 <= N
%
%  excess - a non-negative vpi number that gives
%      the amount by which Root^2 misses the mark.
%      Thus, we have
%
%      excess = (N - Root^2)
%
%
% Example:
%  N = vpi('12345678901234567890123')
%
%  [R,excess] = sqrt(N)
%  R =
%      111111110611
%
%  excess =
%      24691096802
%
% See that RR^2 <= NN <= (RR+1)^2
%
%  RR^2 <= NN
%  ans =
%       1
%
%  NN <= (RR+1)^2
%  ans =
%       1
%
%  N - (R^2 + excess)
%  ans =
%      0
%
%
% Example:
%  N = vpi('56545789887679780879799889098790980696897897');
%  NN = N^2;
%
%  sqrt(NN) - N
%  ans =
%       0
%
%  See also: power, log, exp
%  
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/26/09

if isempty(N)
  % empty propagates
  Root = [];
elseif numel(N) == 1
  % scalar N
  
  % error check
  if N < 0
    error('N must represent a non-negative integer')
  end
  
  % is N small enough to do it exactly?
  if N <= (2^53 - 1)
    % small
    Root = vpi(floor(sqrt(double(N))));
  else
    % too big
    
    % get a good approximation to the square root
    Norder = order(N);
    offset = max(0,floor(Norder/2) - 9);
    Noffset = N;
    Noffset.digits(1:(2*offset)) = [];
    
    Root = vpi(floor(sqrt(double(Noffset))));
    Root.digits = [zeros(1,offset),Root.digits];
    
    % Iterative improvement to get to the
    % square root, stopping when no more
    % improvement is possible. This will only
    % happen when the integer quantization
    % stops us, and it will be very quickly
    % convergent.
    flag = true;
    while flag
      newRoot = (Root + N/Root)/2;
      if Root == newRoot;
        flag = false;
      end
      Root = newRoot;
    end
  end
  
else
  % an array in N
  Root = repmat(vpi(0),size(N));
  for i = 1:numel(N)
    Root(i) = sqrt(N(i));
  end
end

% did we need to compute the remainder?
if nargout > 1
  excess = N - Root.*Root;
end



