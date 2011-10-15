%BRAID   Class for representing braids.
%   A BRAID object holds a braid represented in terms of Artin generators.
%
%   The class BRAID has the following data members:
%
%    'word'     vector of signed integers (int32) giving the Artin generators.
%    'n'        number of strings in the braid.
%
%   METHODS(BRAID) shows a list of methods.
%
%   See also BRAID.BRAID (constructor), CFBRAID.

classdef braid
  properties
    n = 1            % number of strings
    word = int32([]) % braid word in Artin generators
  end

  methods

    function br = braid(b,nn)
    %BRAID   Construct the a braid object.
    %   B = BRAID(W) creates a braid object B from a vector of generators W.
    %   B = BRAID(W,N) specifies the number of strings N of the braid group,
    %   which is otherwise guessed from the maximal elements of W.
    %
    %   The braid group generators are represented as a list of integers I
    %   satisfying -N < I < N.  The usual group operations (multiplication,
    %   inverse, powers) can be performed on braids.
    %
    %   B = BRAID(XY) constucts a braid from a trajectory dataset XY.
    %   The data format is XY(1:NSTEPS,1:2,1:N), where NSTEPS is the number
    %   of time steps and N is the number of particles.
    %
    %   BC = BRAID(B) copies the object B of type BRAID or CFBRAID to the BRAID
    %   object BC.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, CFBRAID.

      % Allow default empty braid: return trivial braid with one string.
      if nargin == 0, return; end
      if isa(b,'braidlab.braid')
	br.n     = b.n;
	br.word  = b.word;
      elseif isa(b,'braidlab.cfbraid')
        D = braidlab.halftwist(b.n);
        br = D^b.delta * braidlab.braid(cell2mat(b.factors),b.n);
      elseif max(size(size(b))) == 3
	if nargin > 1
	  error
	end
	% The input is an array of data.
	br = color_braiding(b,1:size(b,1));
      else
	% Store word as row vector.
	if size(b,1) > size(b,2)
	  b = b.';
	end
	br.word = b;
	if nargin < 2
	  br.n = max(abs(b))+1;
	else
	  br.n = nn;
	end
      end
    end

    function obj = set.n(obj,value)
      if value < 1
	error('BRAIDLAB:braid:setn','Need at least one string.')
      end
      if ~isempty(obj.word)
        if value < max(abs(obj.word))+1
	  error('BRAIDLAB:braid:setn',...
		'Too few strings for generators.')
	end
      end
      obj.n = value;
    end

    % Make sure it's an int32, internally.
    function obj = set.word(obj,value)
      obj.word = int32(value);
      % Raise n if necessary, and convert to double (eventually make int32?).
      obj.n = double(max(obj.n,max(abs(obj.word))+1));
    end

    function ee = eq(b1,b2)
    %EQ   Test braids for equality.
    %   EQ(B1,B2) or B1==B2 returns TRUE if the two braids B1 and B2 are
    %   equal.  The algorithm uses Dynnikov coordinates (action on loops) to
    %   determine braid equalitty.
    %
    %   Reference: P. Dehornoy, "Efficient solutions to the braid isotopy
    %   problem," Discrete Applied Mathematics 156 (2008), 3091-3112.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.LEXEQ, LOOP, LOOPCOORDS.
      ee = b1.n == b2.n;
      % Check if the loop coordinates are the same.
      % This can fail if the braids are too long, since the coordinates
      % overflow.  Check for that.
      if ee, ee = all(loopcoords(b1) == loopcoords(b2)); end
    end

    function ee = lexeq(b1,b2)
    %LEXEQ   Test braids for lexicographical equality.
    %   LEXEQ(B1,B2) return TRUE if the words representing B1 and B2 in
    %   terms of braid generators are equal, generator by generator.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.EQ, LOOP, LOOPCOORDS.
      ee = b1.n == b2.n & length(b1) == length(b2);
      if ee, ee = all(b1.word == b2.word); end
    end

    function ee = ne(b1,b2)
    %NE   Test braids for inequality.
    %   NE(B1,B2) or B1~=B2 returns ~EQ(B1,B2).
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.EQ.
      ee = ~(b1 == b2);
    end

    function ee = istrivial(b)
    %ISTRIVIAL   Returns true if braid is the trivial braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.EQ.
      if isempty(b.word), ee = true; return; end
      ee = all(loopcoords(b) == loopcoords(braidlab.braid([],b.n)));
    end

    function ee = ispure(obj)
    %ISPURE   Returns true if braid is a pure braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.PERM.
      ee = all(obj.perm == 1:obj.n);
    end

    function b12 = mtimes(b1,b2)
    %MTIMES   Multiply two braids together.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.INV, BRAID.MTIMES.
      if isa(b2,'braidlab.braid')
	b12 = braidlab.braid([b1.word b2.word],max(b1.n,b2.n));
      else
	% Action of braid on a loop.
	%
	% Have to define this here, rather than in the loop class, since the
        % braid goes on the left, and Matlab determines which overloaded
        % function to call by looking at the first argument.
	if b1.n > b2.n
	  error('BRAIDLAB:braid:mtimes', ...
		'Generator values too large for the loop.')
	end
	b12 = braidlab.loop(loopsigma(b1.word,b2.coords));
      end
    end

    function bm = mpower(b,m)
    %MPOWER   Raise a braid to some positive or negative power.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.INV, BRAID.MPOWER.
      bm = braidlab.braid([],b.n);
      if m > 0
	bm.word = repmat(b.word,[1 m]);
      else
	bm.word = repmat(b.inv.word,[1 -m]);
      end
    end

    function bi = inv(b)
    %INV   Inverse of a braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.MTIMES, BRAID.MPOWER.
      bi = braidlab.braid(-b.word(end:-1:1),b.n);
    end

    function p = perm(obj)
    %PERM   Permutation corresponding to a braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.ISPURE.
      p = 1:obj.n;
      for i = 1:length(obj.word)
	s = abs(obj.word(i));
	p([s s+1]) = p([s+1 s]);
      end
    end

    function wr = writhe(obj)
    %WRITHE   Writhe of a braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID.
      wr = sum(sign(obj.word));
    end

    function str = char(b)
    %CHAR   Convert braid to string.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.DISP.
      if isempty(b.word)
	str = 'e';
      else
	str = num2str(b.word);
      end
      str = ['< ' str ' >'];
    end

    function disp(b)
    %DISP   Display a braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.CHAR.
       c = char(b);
       if iscell(c)
	 disp(['     ' c{:}])
       else
	 disp(c)
       end
    end

    function l = length(b)
    %LENGTH   Length of a braid.
    %   L = LENGTH(B) returns the number of generators in the current
    %   internal representation of a braid.  Calling COMPACT(B) can reduce
    %   this length, often dramatically when B is created from data.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, COMPACT.
      l = length(b.word);
    end

  end % methods block

  % Static methods defined in separate files.
  % Need to execute 'clear classes' to register changes here.
  methods (Static = true)
    [b,tc] = crosstimes(XY,t)
  end % static methods

end % braid classdef
