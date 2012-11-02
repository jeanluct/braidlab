function result = ispalindrome(N)
% ispalindrome: test if the number N (vpi or numeric, or a digit string as a vector) is a palindrome
% usage: result = ispalindrome(N)
% 
% When N is a scalar (vpi or numeric), ispalindrome
% tests if the number is itself a palindrome. When 
% 
% When N is a vector, ispalindrome tests that the
% sequence it represents is a palindromic sequence.
%
%   http://en.wikipedia.org/wiki/Palindrome
%   http://en.wikipedia.org/wiki/Lychrel_number
%
% Arguments: (input)
%  N - may be a scalar vpi or numeric integer,
%      or ANY vector.
%
% Arguments: (output)
%  result - (boolean) true or false, depending upon
%      whether the number or sequence represents a 
%      palindrome.
%
%
% Example:
%  ispalindrome(3234)
% ans =
%      0
%
%  ispalindrome(vpi('122222212222221'))
% ans =
%      1
%
%  ispalindrome('abcdefghihgfedcba')
% ans =
%      1
%
%  ispalindrome([3 4 5 1 1 3 4 5])
% ans =
%      0
%
%
%  See also: digits
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 4/22/09

% test the input
if nargin ~= 1
  error('ispalindrome acceppts only one argument')
end

if isempty(N)
  % empty propagates to empty
  result = [];
elseif numel(N) > 1
  % N must then be a vector. test if the vector
  % itself is a palindromic one.
  if ~isvector(N)
    error('N may not be an array')
  end
  
  % N must have been a vector
  N = N(:);
  result = all(flipud(N(:)) == N);
else
  % N was a scalar
  
  % is it a vpi number?
  if isa(N,'vpi')
    d = digits(N);
    result = all(fliplr(d) == d);
  else
    % N is a scalar, but not a vpi scalar
    
    % N must be numeric
    if ~isnumeric(N) || (N ~= round(N))
      error('N must be integer')
    end
    
    % extract the digits
    N = abs(N);
    d = dec2base(N,10);
    result = all(fliplr(d) == d);;
    
  end
  
end






