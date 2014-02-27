function R = randint(N,samplesize)
% vpi/randint: generate a single random vpi number, uniformly chosen from the interval [1,N]
% usage: R = randint(N); % one integer chosen
% usage: R = randint(N,samplesize); % multiple samples generated
% 
% Generate a random nonegative integer,
% uniformly chosen from the closed interval
% [0,N]. The sampling will be done with
% replacement when multiple samples are
% requested.
%
% Arguments: (input)
%  N - A scalar vpi number - Denotes the
%      upper limit of the sampling interval.
%      N must be a positive integer.
%
%  samplesize - (OPTIONAL) The number of random
%      samples to be generated. When samplesize
%      is a scalar, for consistency with the
%      built-in rand and randn, a square matrix
%      of size (samplesize,samplesize) will be
%      generated.
%
%      When samplesize is a vector of integers, it
%      denotes the size of the array of random
%      integers. prod(samplessize) elements will
%      be generated.
%
%      DEFAULT: samplesize = 1
%
% Arguments: (output)
%  R - The generated random vpi number(s).
%      If more than one is to be generated
%      R will be an array of vpi numbers.
%
% Example:
%  R = randint(vpi('150448480844084984464017484465407404'),3)
%  R
%     61171994599073303615836115077158082
%     52094750781092371506047868158094535
%     130358593266171398412320264988345426
%
%  See also: rand
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 3/7/09

% ensure that INT is a vpi, and positive
if (nargin<1) || (nargin>2)
  error('vpi/randint requires either one or two input argumenta')
end

if N < 1
  error('N must be at least 1')
end

if (nargin<2) || isempty(samplesize)
  samplesize = 1;
end
samplesize = samplesize(:).';
if ~isnumeric(samplesize) || any(samplesize<1)
  error('Samplesize must be positive, integer, numeric')
end
% create a column vector when
% samplesize is a scalar
if numel(samplesize) == 1
  samplesize = [samplesize,samplesize];
end

if N <= (2^53-1)
  % small potatoes
  Nd = double(N) + 1;
  R = vpi(floor(Nd*rand(samplesize)));
  return
end

% the total number of samples to generate
% for large N
ntotal = prod(samplesize);
if ntotal == 1
  R = vpi(0);
else
  R = repmat(vpi(0),samplesize);
end  

N = vpi(N);
ndigits = order(N)+1;

% build a discrete distribution for each
% digit as necessary. Start with only the
% highest order digit, but do the others as
% needed.
digitdistrib = cell(1,ndigits);
for i = 1:ntotal
  % build the i'th sample. Choose the topmost
  % digit randomly from a discrete distribution
  % if the top digit is not the largest possible
  % digit, then the rest of the digits of this
  % number are uniform.
  flag = true;
  j = ndigits;
  Ri = vpi(0);
  while flag && (j > 0)
    
    % get the j'th digit.
    if isempty(digitdistrib{j})
      % we need to create the discrete
      % distribution for the j'th digit
      nextdigits = N.digits(j:-1:max(1,j-17));
      digitdistrib{j} = discretedigitdistribution(nextdigits);
    end
    % sample from the discrete distribution
    [junk,topmostdigitplus1] = histc(rand(1),digitdistrib{j});
    topmostdigit = topmostdigitplus1 - 1;
    
    % stuff this digit into Ri
    Ri.digits(j) = topmostdigit;
    
    % which digit was it?
    if (topmostdigitplus1 < (length(digitdistrib{j}) - 1)) && (j>1)
      % we can just stuff the remainder
      % of the digits. They will be uniform.
      Ri.digits(1:(j-1)) = floor(10*rand(1,j-1));
      flag = false;
    end
    
    % generate more digits indpendently?
    j = j - 1;
  end
  
  k = find(Ri.digits,1,'last');
  if isempty(k)
    Ri.digits = 0;
  elseif k < ndigits
    Ri.digits((k+1):end) = [];
  end
  
  % stuff it into the array of integers
  if ntotal == 1
    R = Ri;
  else
    R(i) = Ri;
  end
end % for i = 1:ntotal


% ====================
% end mainline
% ====================
% begin subfunctions
% ====================
function ddi = discretedigitdistribution(nextdigits)
% generate a discrete distribution for the
% first digit in this digit string from N.
firstdigit = nextdigits(1);
if firstdigit == 0
  % zero was the only option
  ddi = [0 1];
elseif length(nextdigits) == 1
  % there is only one digit to choose from.
  % all are equally likely.
  ddi = cumsum([0,ones(1,nextdigits)]);
  ddi = ddi/ddi(end);
else
  ddi = ones(1,firstdigit+1);
  
  p = 0;
  tenths = 1;
  for j = 2:length(nextdigits)
    tenths = tenths/10;
    p = p + nextdigits(j)*tenths;
  end
  
  ddi(end) = p;
  ddi = cumsum([0,ddi]);
  ddi = ddi/ddi(end);
end










