function result = exp(x)
% vpi/exp: Integer part of exp(x), i.e, fix(exp(x)), where x is a vpi number
% usage: result = exp(x)
%
%
% arguments: (input)
%  x - a vpi scalar integer. x may be no larger
%      than 2,200,000. (Sorry. I had to put some
%      limit on this. As it is, that large of a
%      number will take some time to compute.)
%
%
% arguments: (output)
%  result - The largest non-negative vpi integer
%      such that result <= exp(x)
%
%
% Example:
%  x = vpi('250')
%
%  result = exp(x)
%  ans =
%     374645461450267326034995481220292014580883075428131591922892131074864875
%     4622741231829765091624032687183730723
%
%
%  See also: power, sqrt
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/31/09


if isempty(x)
  % empty propagates
  L = [];
elseif numel(x) == 1
  % scalar x
  
  % error check
  if x > 2.2e6
    error('Exponent overflow. x is limited to a maximum of 2.25E6')
  end
  
  % is x small enough to do it exactly?
  if x < 0
    % just call it zero and be done with it.
    result = vpi(0);
    return
  elseif x <= 36
    % relatively small stuff
    result = vpi(floor(exp(double(x))));
    return
  end
  
  % too big to use a double.
  
  % We will need e == exp(1). Have we brought in
  % Edigits before?
  persistent Edigits  %#ok
  if isempty(Edigits)
    % no
    load('Edigits')
  end
  
  % How long will the result be? How many
  % decimal digits?
  ndec = ceil(double(x)/log(10));
  % This ensures that we carry an extra
  % few digits to make sure we get that
  % last digit correct.
  sparedigits = max(8,ceil(ndec/100));
  
  % Get the first (ndec + sparedigits) of exp(1)
  E1 = vpi(Edigits(1:(ndec + sparedigits)));
  
  % get a long binary expansion for x.
  xbin = fliplr(vpi2bin(x)) == '1';
  
  % initializer result
  if xbin(1)
    result = E1;
    unitflag = true;
  else
    result = vpi(1);
    unitflag = false;
  end
  
  % now build up the exponential by squaring
  % e = exp(1), keeping as many digits as we need.
  for i = 2:length(xbin)
    % squaring
    if i > 2
      E2 = E2*E2;
    else
      E2 = E1*E1;
    end
    
    % truncate the lowest order digits in the square
    E2.digits(1:(ndec + sparedigits - 1)) = [];
    
    % did this power enter into the binary
    % expansion of x?
    if xbin(i)
      % yes, so multiply it into result
      result = result * E2;
      
      if unitflag
        % This multiply introduced some extraneous
        % digits trim them off now.
        result.digits(1:(ndec + sparedigits - 1)) = [];
      else
        unitflag = true;
      end
    end
  end
  
  % when all is done, we have a large decimal
  % expansion of exp(x). But there are extra
  % digits on the very end. How many?
  %
  %   (ndec + sparedigits - 1)
  %
  % truncate all of these extraneous digits now.
  nr = length(result.digits);
  result.digits(1:(nr - ndec)) = [];
  
else
  % an array in x
  result = zeros(size(x));
  for i = 1:numel(x)
    result(i) = exp(x(i));
  end
end


