function prediction = isprime(N,ntests,method)
% vpi/isprime: uses Miller-Rabin method to check if a number is prime
% usage: prediction = isprime(N)
% usage: prediction = isprime(N,ntests)
% usage: prediction = isprime(N,ntests,method)
%
% Numbers less than 2^32 are converted to double, then
% use the built-in isprime test.
%
% arguments: (input)
%  N - a vpi integer or an array thereof, to be tested
%      for primality
%
%  ntests - (OPTIONAL) scalar positive numeric integer.
%      ntests defines the number of successive tests
%      for various randomly chosen witnesses when N is
%      larger than 341550071728321. Smaller numbers than
%      this use a fixed set of up to 7 witnesses for the
%      Miller-Rabin test that ensures a correct
%      determination of primality for any number less
%      than that value.
%
%      If ntests is actually a vector or array of integers,
%      then the elements of ntests will be used for the
%      witnesses themselves.
%
%      DEFAULT: ntests = 2
%
%  method - (OPTIONAL) 'm' or 'f', denotes the test used.
%
%      method == 'm' --> uses the Miller-Rabin test (This
%        is best, and should almost always be the test
%        used.)
%
%      method == 'f' --> Fermat test, using Fermat's
%        little theorem. This test has been left in only
%        for comparison purposes, as carmichael numbers
%        will cause it to fail.
%
%      DEFAULT: method = 'm'
%
% arguments: (output)
%  predictions - logical result, of the same shape as
%      N, when more than one number is tested for primality.
%
%      True if all of the witnesses predicted N to be
%      prime. If any of the predictions indicated N
%      to be composite, then N is definitely composite.
%
%
% Example:
%  isprime(vpi('10000000000037'))
% ans =
%      1
%
%  isprime(vpi(2:10))
% ans =
%      1     1     0     1     0     1     0     0     0
%
%  See also: isprime
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 3.0
%  Release date: 3/7/09

if (nargin<1) || (nargin>3)
  error('vpi/isprime allows only 1, 2, or 3 arguments')
end

% Is this a scalar or an array?
if isempty(N)
  % empty propagates
  prediction = [];
  return
elseif numel(N) > 1
  % an array
  prediction = true(size(N));
  for i = 1:numel(N)
    if nargin == 1
      prediction(i) = isprime(N(i));
    else
      prediction(i) = isprime(N(i),ntests);
    end
  end
else
  % scalar N
  
  % error checks, defaults

  % make sure that N is a vpi, and positive
  N = abs(vpi(N));
  
  % is it finite?
  if ~isfinite(N)
    error('VPI:ISPRIME:finite','N must be a finite number')
  end
  
  % simple cases. check to see if N is an even number, > 1
  if isunit(N)
    % 1 is not prime by definition.
    prediction = false;
    return
  elseif isequal(N,2)
    % 2 is prime
    prediction = true;
    return
  elseif comparemagnitudes(vpi(2^32),N)
    % small enough that isprime will suffice
    prediction = isprime(double(N));
    return
  elseif (mod(N.digits(1),2) == 0) || ...
      (mod(N.digits(1),5) == 0) || ...
      (mod(sum(N.digits),3) == 0)
    
    % multiple of 2 or 3 or 5
    prediction = false;
    return
  end

  % default for ntests is 2
  if (nargin<2) || isempty(ntests)
    ntests = 2;
  end
  if numel(ntests)>1
    % ntests was actually a vpi array of witnesses
    witnesses = ntests;
    ntests = numel(ntests);
    % make sure that witnesses was a vpi array
    witnesses = abs(vpi(witnesses));
  elseif (length(ntests)~=1) || ~isnumeric(ntests) || ...
      (ntests <= 0) || (ntests ~= round(ntests))
    error('ntests must be scalar, numeric, positive integer')
  else
    witnesses = [];
  end
  
  % default for method is Miller-Rabin ('m')
  if (nargin < 3) || isempty(method)
    method = 'm';
  elseif ~ischar(method) || ~ismember(method,{'m','f'})
    error('method must be character, either ''m'' or ''f''')
  end
  
  % loop over the witnesses.
  switch method
    case 'm'
      % Miller-Rabin test
      
      % pick candidate witnesses, if they were
      % not already supplied.
      if isempty(witnesses)
        if (N < 341550071728321)
          % N is already known to be at least 2^32. But
          % if it is no larger than this value, then we
          % can absolutely assure a correct determination
          % for the following set of witnesses. See
          % http://www.research.att.com/~njas/sequences/A014233
          witnesses = [2 3 5 7 11 13 17];
          ntests = numel(witnesses);
        else
          % pick random integer(s) between 2 and N-1
          % randint generates random integers in [0,L]
          witnesses = randint(N-3,[ntests,1]) + 2;
        end
      end
      
      % determine s and d, such that 2^s*d + 1 = N.
      % We already know that n is odd, so just divide N-1
      % by 2 until we get an odd number.
      d = (N - 1)/2;
      s = 1;
      while iseven(d)
        s = s + 1;
        d = d / 2;
      end
      
      Nm1 = N-1;
      prediction = true;
      notdone = true;
      i = 1;
      while notdone && (i <= ntests)
        a = witnesses(i);
        
        % x = mod(a^d,N)
        x = powermod(a,d,N);
        
        % if x is 1 or -1 at this point, then
        % we are done, with a prime prediction
        % for this specific witness.
        if (s == 1) && (x ~= 1) && (x ~= Nm1)
          % a is a witness that N is composite
          prediction = false;
          notdone = false;
        elseif (x == 1) || (x == Nm1)
          % stop the loop, return true for the
          % prediction. a might be a strong liar
          % though. Don't even start the loop on r,
          % but continue the while loop to check
          % the other witnesses too.
        else
          % we cannot make a prediction of primality
          % for this witness yet. Start squaring x,
          % modulo N on each pass through this loop.
          for r = 1:(s-1)
            x = mod(x.*x,N);
            
            % if x is ever 1 or -1 in this loop, then
            % we can stop this internal loop.
            if x == 1
              % predict composite. Stop the outer
              % loop over the witnesses too. We are
              % absolutely known to be done here.
              notdone = false;
              prediction = false;
              break
              
            elseif x == Nm1
              % predict prime, however, a may be
              % a strong liar here, so we need to
              % continue looking and checking the
              % rest of the witnesses.
              break
              
            end % if x == 1
            
            % is this the end of the loop on r, without
            % ever having gotten a 1 or -1?
            if r == (s-1)
              % if we drop down to this point without having
              % broken from the loop on r, then a is a witness
              % for N as a composite number.
              prediction = false;
              notdone = false;
            end

          end % for r = 1:(s-1)
          
        end % if (x == 1) or (x == Nm1)
        
        % increment the loop counter in the while loop
        i = i + 1;
        
      end % while notdone && (i <= ntests)    
      
    case 'f'
      % Fermat test
      
      % pick candidate witnesses, if they were
      % not already supplied.
      if isempty(witnesses)
        % pick random integer(s) between 2 and N-1
        % randint generates random integers in [0,L]
        witnesses = randint(N-3,[ntests,1]) + 2;
      end
      
      Nm1 = N-1;
      predictions = true(1,ntests);
      notdone = true;
      i = 1;
      while notdone && (i <= ntests)  
        w = witnesses(i);
        
        % use Fermat's little theorem
        % if N is truly prime, then mod(w^(N-1),N) == 1
        predictions(i) = (1 == powermod(w,Nm1,N));
        
        % if any of these tests predict composite,
        % then we are done.
        if ~predictions(i)
          notdone = false;
        else
          i = i + 1;
        end
      end
      
      % did any of the primality tests predict composite?
      prediction = all(predictions);

  end
end



