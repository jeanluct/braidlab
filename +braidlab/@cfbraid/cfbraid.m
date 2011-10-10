%CFBRAID   Class for representing braids in left canonical form.
%   The object CFBRAID holds the left canonical form (LCF) W = D^M F of a
%   braid word W.  Here D is the positive half-twist, M is a signed integer,
%   and F is a sequence of positive factors written in Artin generators.
%
%   The class CFBRAID has the data members
%
%    'delta'    the power M of Delta;
%    'factors'  cell array of positive factors F;
%    'n'        order of braid group (number of strands).
%
%   Reference: J. S. Birman and T. E. Brendle, "Braids: A Survey," in
%   Handbook of Knot Theory, pp. 78-82.
%
%   See also BRAID.

classdef cfbraid
  properties
    delta = 0
    factors = cell(0)
    n = 1
  end

  methods

    function br = cfbraid(b,nn)
    %CFBRAID   Construct the left canonical form of a braid word.
    %   B = CFBRAID(W) constructs the left canonical form of a braid word W
    %   expressed as a list of Artin generators.  W can also be a BRAID or
    %   CFBRAID object.  If W is a list, CFBRAID(W,N) can be used to specify
    %   the order N of the braid group, which is otherwise guessed from W.
    %
    %   See also BRAID.
      if nargin == 0, return; end
      if isa(b,'braidlab.cfbraid')
	br.n = b.n;
	br.factors = b.factors;
	br.delta = b.delta;
	if nargin > 1
	  error('BRAIDLAB:cfbraid:cfbraid:badarg', ...
		'Cannot specify n if creating from a cfbraid.')
	end
	return
      elseif isa(b,'braidlab.braid')
	br.n = b.n;
	w = b.word;
	if nargin > 1
	  error('BRAIDLAB:cfbraid:cfbraid:badarg', ...
		'Cannot specify n if creating from a braid.')
	end
      else
	if nargin < 2
	  br.n = max(abs(b))+1;
	else
	  br.n = nn;
	  if br.n < max(abs(b))+1
	    error('BRAIDLAB:cfbraid:cfbraid:badgen', ...
		  'A generator is out of range.');
	  end
	end
	w = b;
      end
      cf = cfbraid_helper(int32(w),br.n,0);
      br.delta = cf.delta;
      br.factors = cf.factors;
    end

   function ee = eq(b1,b2)
   %EQ   Test for equality of braids.
      fac1 = cell2mat(b1.factors);
      fac2 = cell2mat(b2.factors);
      ee = b1.n == b2.n & b1.delta == b2.delta & all(fac1 == fac2);
    end

    function ee = ne(b1,b2)
      ee = ~(b1 == b2);
    end

    function ee = isempty(b)
      ee = isempty(b.factors) & b.delta == 0;
    end

    function str = char(b)
      if b.delta == 0 & isempty(b.factors)
	str = '< e >';
	return
      end
      str = '';
      if b.delta ~= 0
	str = [str sprintf('D^%d',b.delta)];
      end
      if ~isempty(b.factors)
	for i = 1:length(b.factors)
	  if i == 1 & b.delta == 0
	    str = [str num2str(b.factors{i})];
	  else
	    str = [str ' . ' num2str(b.factors{i})];
	  end
	end
      end
      str = ['< ' str ' >'];
    end

    function disp(b)
       c = char(b);
       if iscell(c)
	 disp(['     ' c{:}])
       else
	 disp(c)
       end
    end

    function l = length(b)
    %LENGTH   Word length of left canonical form of a braid word.
    %   L = LENGTH(B) returns the word length of a braid B expressed in
    %   Artin generators, where B is in left canonical form.
    %
    %   See also CFBRAID.
      if b.delta == 0 & isempty(b.factors), l = 0; return; end
      Dl = b.n*(b.n-1)/2;  % The lengh of the half-twist Delta.
      l = abs(b.delta)*Dl + length(cell2mat(b.factors));
    end

    function w = braid(b)
    %BRAID   Convert left canonical form of a braid to word form.
    %   W = BRAID(B) returns the word representation of a braid B in
    %   terms of braid generators, where B is in left canonical form.
    %   Here W is an object of type BRAID.
    %
    %   See also CFBRAID, BRAID.
      D = braidlab.halftwist(b.n);
      w = cell2mat(b.factors);
      if b.delta < 0
	k = -b.delta;
	D = -D(end:-1:1);
      else
	k = b.delta;
      end
      w = braidlab.braid([repmat(D,[1 k]) w],b.n);
    end

  end

end
