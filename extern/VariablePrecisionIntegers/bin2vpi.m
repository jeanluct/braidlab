function INT = bin2vpi(B)
% bin2vpi: converts a binary representation of an integer into vpi (decimal) form
% usage: INT = bin2vpi(B)
%
% arguments: (input)
%  N - boolean vector or character string, contains
%      the digits of a binary number, either as a
%      numeric vector
%
% arguments: (output)
%  INT - the vpi form of the integer represented by N
%
%
% Example:
%  bin2vpi('1010101')
%  ans =
%      85
%
%
%  bin2vpi([1 0 1 0 1 0 1])
%  ans =
%      85
%
%
%  See also: base2dec, dec2base, vpi2base, base2vpi, vpi2bin
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/24/09


% insure that B is a vector
if (nargin~=1) || isempty(B) || ~isvector(B)
  error('B must be a boolean or character vector')
end

% is B boolean or character?
if ischar(B)
  % verify that B contains only '0' or '1' characters
  if ~all(ismember(B,'01'))
    error('If B is character, it must be built from only ''0'' and ''1'' characters')
  end
  
  % convert to boolean
  B = (B=='1');
elseif isnumeric(B)
  if ~all(ismember(B,[0 1]))
    error('If B is numeric, it must be built from only 0 and 1 elements')
  end
else
  error('B must be a boolean vector or a character vector')
end

% flip the vector, so we will start
% with the lowest order bits and work up.
B = fliplr(B(:)');

% initialize INT at zero. we will add in any other powers
% as necessary.
INT = vpi(0);
% some other useful numbers
two = vpi(2);
blocksize = 50;

% dec2bin wants a character string
Bchar = '01';
b2d = @(block) bin2dec(Bchar(fliplr(block)+1));

bs2 = two.^blocksize;
offset = vpi(1);
while ~isempty(B)
  if length(B) <= blocksize
    % shorten the last block down to fit 
    blocksize = length(B);
  end
  % nibbling off one chunk at a time of B
  block = B(1:blocksize);
  block = b2d(block);
  INT = INT + block*offset;
  
  B(1:blocksize) = [];
  offset = offset*bs2;
end




