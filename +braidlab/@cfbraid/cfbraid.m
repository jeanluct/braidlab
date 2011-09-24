%CFBRAID   Class for representing braids in left canonical form.

classdef cfbraid
  properties
    repr
    n
    factors
    delta
  end

  methods

    function br = cfbraid(b,nn)
      if isa(b,'braidlab.cfbraid')
	br.repr = b.repr;
	br.n = b.n;
	br.factors  = b.factors;
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
	  vr.nn = nn;
	end
	w = b;
      end
      br.repr = 'lcf';
      cf = cfbraid_helper(w,br.n,0);
      br.delta = cf.delta;
      br.factors = cf.factors;
    end

   function ee = eq(b1,b2)
   %EQ   Test for equality of braids.
      fac1 = cell2mat(b1.factors);
      fac2 = cell2mat(b2.factors);
      ee = b1.n == b2.n & b1.delta == b2.delta & ~any(fac1 ~= fac2);
    end

    function ee = ne(b1,b2)
      ee = ~(b1 == b2);
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
	  str = [str ' . ' num2str(b.factors{i})];
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
      w = [repmat(D,[1 k]) w];
    end

  end
end
