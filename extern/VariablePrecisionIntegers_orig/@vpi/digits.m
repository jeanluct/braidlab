function result = digits(N,digitvec)
% digits: extracts the digits or specifies the digits of a vpi number
% usage: digitvec = digits(N)
% usage: N = digits(N,digitvec)
%
% When called with one argument, a scalar vpi
% number, digits will extract the digits of 
% the supplied vpi number, returning them as a
% numeric (double) vector.
%
% When called with two arguments, digits will
% overwrite the digits of the existing vpi
% number (N) and return a new vpi number with
% the specified digits. The sign of N will be
% unchanged.
%
% arguments: (input)
%  N - a scalar vpi number
%
%  digitvec - a numeric integer vector, composed
%      only of the integers in the interval [0,9].
%  
%
% Example:
%  N = vpi(17)^3
%  digits(N)
%
%  ans =
%     4     9     1     3
%
%
%  digits(N,[1 2 3 4 5])
%
%  ans =
%     12345
%
%  See also: vpi, leadingdigit, trailingdigit, ispalindrome
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 4/22/09

if (nargin < 1) || (nargin > 2)
  error('digits requires either one or two arguments')
end

% which of the three posible cases is this?
if nargin == 1
  % we have ruled out the two argument form
  
  % Is N a vpi number?
  if isa(N,'vpi')
    if numel(N) == 0
      result = [];
    elseif numel(N) > 1
      error('N must be a scalar vpi number')
    else
      % return the digit vector itself.
      result = fliplr(N.digits);
    end
  else
    % the input must be a numeric vector
    if isempty(N) || ~isvector(N) || ...
        ~isnumeric(N) || ~all(ismember(N,0:9))
      error('digitvec must be positive numeric integer vector, of single digit integers')
    end
    
    % construct a scalar vpi
    result = vpi(0);
    
    % and stuff the digit vector
    result.digits = fliplr(reshape(N,1,[]));
    
  end
  
else
  % this is the two argument form.
  
  % N must be a scalar vpi number.
  if ~isa(N,'vpi') || numel(N) > 1
    error('In the two argument form for digits, N must be scalar vpi')
  end
  
  % digitvec must be a numeric vector composed
  % of positive integer (single) digit elements
  if isempty(digitvec) || ~isvector(digitvec) || ...
      ~isnumeric(digitvec) || ~all(ismember(digitvec,0:9))
    error('digitvec must be positive numeric integer vector, of single digit integers')
  end
  
  % the sign bit will not change here
  result = N;
  % don't forget to flip the digit sequence,
  % since vpi stores the digits in reverse
  % order, units digit first.
  result.digits = fliplr(reshape(digitvec,1,[]));
  
end


