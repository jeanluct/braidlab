function textnumber = vpi2english(N)
% vpi2english: converts a vpi integer into the readable (American) English equivalent as text
% usage: textnumber = vpi2english(N)
%
% Uses the large number names given in these links:
%
% http://en.wikipedia.org/wiki/Names_of_large_numbers
% http://www.unc.edu/~rowlett/units/large.html
% http://www.thealmightyguru.com/Pointless/BigNumbers.html
% 
% N may be almost any vpi number (sorry, but
% no larger than 10^306-1)
% 
% Example:
%  N = vpi(17)^6
% N =
%    24137569
%
%  vpi2english(N)
% ans =
%  twenty four million, one hundred thirty seven thousand, five hundred sixty nine
%
% See also: vpi2base, vpi2dec
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 2/11/09

if nargin~=1
  error('No argument provided')
end

if isempty(N)
  % empty propagates empty
  textnumber = [];
elseif numel(N) > 1
  % an array
  error('Sorry. I''ll only convert a scalar vpi to English text')
end

if order(N) > 305
  error('I''m sorry. Too many digits for me to describe.')
end

% was the number zero?
if iszero(N)
  textnumber = 'zero';
  return
end

% convert the numeric part of N into base 1000 "digits"
base1000 = vpi2base(N,1000);
nbase = length(base1000);

tillions = {'', 'thousand', 'million', 'billion', 'trillion', ...
  'quadrillion', 'quintillion', 'sextillion', 'septillion', ...
  'octillion', 'nonillion', 'decillion', 'undecillion', ...
  'duodecillion', 'tredecillion', 'quattuordecillion', ...
  'quindecillion', 'sexdecillion', 'septendecillion', ...
  'octodecillion', 'novemdecillion', 'vigintillion', ...
  'unvigintillion', 'duovigintillion', 'trevigintillion', ...
  'quattuorvigintillion', 'quinvigintillion', 'sexvigintillion', ...
  'septenvigintillion', 'octovigintillion', 'novemvigintillion', ...
  'trigintillion', 'untrigintillion', 'duotrigintillion', ...
  'tretrigintillion', 'quattuortrigintillion', 'quintrigintillion', ...
  'sextrigintillion', 'septentrigintillion', 'octotrigintillion', ...
  'novemtrigintillion', 'quadragintillion', 'unquadragintillion', ...
  'duoquadragintillion', 'trequadragintillion', 'quattuorquadragintillion', ...
  'quinquadragintillion', 'sexquadragintillion', 'septenquadragintillion', ...
  'octoquadragintillion', 'novemquadragintillion', 'quinquagintillion', ...
  'unquinquagintillion', 'duoquinquagintillion', 'trequinquagintillion', ...
  'quattuorquinquagintillion','quinquinquagintillion','sexquinquagintillion', ...
  'septenquinquagintillion','octoquinquagintillion','novemquinquagintillion', ...
  'sexagintillion', 'unsexagintillion', 'duosexagintillion', ...
  'tresexagintillion', 'quattuorsexagintillion', 'quinsexagintillion', ...
  'sexsexagintillion', 'septensexagintillion', 'octosexagintillion', ...
  'novemsexagintillion', 'septuagintillion', 'unseptuagintillion', ...
  'duoseptuagintillion', 'treseptuagintillion', 'quattuorseptuagintillion', ...
  'quinseptuagintillion', 'sexseptuagintillion', 'septenseptuagintillion', ...
  'octoseptuagintillion', 'novemseptuagintillion', 'octogintillion', ...
  'unoctogintillion', 'duooctogintillion', 'treoctogintillion', ...
  'quattuoroctogintillion', 'quinoctogintillion', 'sexoctogintillion', ...
  'septoctogintillion', 'octooctogintillion', 'novemoctogintillion', ...
  'nonagintillion', 'unnonagintillion', 'duononagintillion', ...
  'trenonagintillion', 'quattuornonagintillion', 'quinnonagintillion', ...
  'sexnonagintillion', 'septennonagintillion', 'octononagintillion', ...
  'novemnonagintillion', 'centillion'};

digitnames = {'one', 'two', 'three', 'four', 'five', ...
  'six', 'seven', 'eight', 'nine', 'ten', 'eleven',  ...
  'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', ...
  'seventeen', 'eighteen', 'nineteen'};

tensnames = {'twenty', 'thirty', 'forty', 'fifty', 'sixty', ...
  'seventy', 'eighty', 'ninety'};

for i = 1:nbase
  % get a block of 3 digits, then convert them
  % to base 10 single digits
  digits1000 = base1000(i);
  digits100 = rem(digits1000,100);
  digits10 = dec2base(digits1000,10)-'0';
  if isempty(digits10)
    digits10 = [0 0 0];
  elseif length(digits10) == 1
    digits10 = [0 0 digits10]; %#ok
  elseif length(digits10) == 2
    digits10 = [0 digits10]; %#ok
  end
  
  if digits1000 == 0
    % this piece was zero
    text3 = '';
  else
    % at least 1, but not more than 999
    if digits1000 < 20
      text3 = digitnames{digits1000};
    else
      % was the piece at least 100?
      if digits1000 >= 100
        text3 = [digitnames{digits10(1)},' hundred']; %#ok
      else
        text3 = '';
      end
      
      % how about the next pair of digits?
      if digits100 == 0
        % a no-op
      elseif digits10(2) < 2
        if ~isempty(text3)
          text3 = [text3,' ',digitnames{digits100}]; %#ok
        else
          text3 = digitnames{digits100};
        end
      else
        if isempty(text3)
          text3 = tensnames{digits10(2)-1};
        else
          text3 = [text3,' ',tensnames{digits10(2)-1}]; %#ok
        end
        if digits10(3)>0
          if isempty(text3)
            text3 = digitnames{digits10(3)};
          else
            text3 = [text3,' ',digitnames{digits10(3)}]; %#ok
          end
        end
      end
    end
  end
  
  if ~isempty(text3)
    if i == 1
      textnumber = [text3,' ',tillions{nbase - i + 1}];
    else
      textnumber = [textnumber,', ',text3,' ',tillions{nbase - i + 1}]; %#ok
    end
  end
end

% it was negative
if N.sign<0
  textnumber = ['negative ',textnumber];
end

% ===================
% end mainline
% ===================
% begin subfunctions
% ===================






