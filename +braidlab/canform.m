function b = canform(w,varargin)
%CANFORM   Left or right canonical form of a braid word.
%   B = CANFORM(W,FORM) returns the left canonical form (LCF, W = D^M F) or
%   right canonical form (RCF, W = F D^M) of a braid word W expressed in
%   Artin generators.  Here D is the positive half-twist, M is a signed
%   integer, and F is a sequence of positive factors written in Artin
%   generators.  FORM is either 'left' or 'right'.  CANFORM(W,N,FORM)
%   specifies the order N of the braid group, which is otherwise guessed
%   from W.  If FORM is omitted, 'left' is assumed.
%
%   B is returned as a structure with the fields
%
%    'type'     'lcf' or 'rcf' to indicate the type of normal form;
%    'delta'    the power M of Delta;
%    'factors'  cell array of positive factors F.
%    'n'        order of braid group
%
%   Reference: J. S. Birman and T. E. Brendle, "Braids: A Survey," in
%   Handbook of Knot Theory, pp. 78-82.
%
%   See also CFLENGTH, CFEQUAL, CFWORD.

if nargout > 1
  error('BRAIDLAB:canform:nargout','Too many output arguments.');
end

if nargin < 1
  error('BRAIDLAB:canform:nargin','Not enough input arguments.');
end

if nargin > 3
  error('BRAIDLAB:canform:nargin','Too many input arguments.');
end

if isempty(w)
  error('BRAIDLAB:canform:empty','Empty braid word.');
end

for i = 1:(nargin-1)
  if isstr(varargin{i})
    if exist('typ') ~= 1
      typ = varargin{i};
    else
      error('BRAIDLAB:canform:badarg','Too many string arguments.');
    end
  else
    if exist('n') ~= 1
      n = varargin{i};
    else
      error('BRAIDLAB:canform:badarg','Too many numerical arguments.');
    end
  end
end

if exist('n') ~= 1
  n = max(abs(w))+1;
else
  if n < max(abs(w))+1
    error('BRAIDLAB:canform:badgen','A generator is out of range.');
  end
end

if exist('typ') ~= 1, typ = 'left'; end

switch lower(typ)
 case {'left','lcf','l'}
  ityp = 0;
 case {'right','rcf','r'}
  ityp = 1;
 otherwise
  error('BRAIDLAB:canform:badtype','Unknown form type.');
end

b = canform_helper(w,n,ityp);
