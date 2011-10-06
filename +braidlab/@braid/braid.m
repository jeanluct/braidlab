%BRAID   Class for representing braids.
%   B = BRAID(W) creates a braid object B from a vector of generators W.
%   B = BRAID(W,N) specifies the order of the braid group N, which is
%   otherwise guessed from the maximal elements of W.
%
%   B = BRAID(XY) construst a braid from a trajectory dataset XY.
%   The data format is XY(1:NSTEPS,1:2,1:N), where NSTEPS is the number
%   of time steps and N is the number of particles.
%
%   BNEW = BRAID(B) constructs a new braid from the braid B.
%
%   See also CFBRAID.

% set/get methods
% better naming convention for vars

classdef braid
  properties
    n = 1            % number of strands
    word = int32([]) % braid word in Artin generators
  end

  methods

    function br = braid(b,nn)
      % Allow default empty braid: return identity with one strand.
      if nargin == 0, return; end
      if isa(b,'braidlab.braid')
	br.n     = b.n;
	br.word  = b.word;
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
	error('BRAIDLAB:braid:setn','Need at least one strand.')
      end
      if ~isempty(obj.word)
        if value < max(abs(obj.word))+1
	  error('BRAIDLAB:braid:setn',...
		'Too few strands for generators.')
	end
      end
      obj.n = value;
    end

    % Make sure it's an int32, internally.
    function obj = set.word(obj,value)
      obj.word = int32(value);
    end

    function ee = eq(b1,b2)
    %EQ   Test braids for equality.
      ee = b1.n == b2.n;
      % Check if the loop coordinates are the same.
      % This can fail if the braids are too long, since the coordinates
      % overflow.  Check for that.
      if ee, ee = ~any(loopcoords(b1) ~= loopcoords(b2)); end
    end

    function ee = lexeq(b1,b2)
    %LEXEQ   Test braids for lexicographical equality.
      ee = b1.n == b2.n & length(b1) == length(b2);
      if ee, ee = ~any(b1.word ~= b2.word); end
    end

    function ee = ne(b1,b2)
      ee = ~(b1 == b2);
    end

    function ee = isempty(b)
      ee = isempty(b.word);
    end

    function ee = isidentity(b)
      ee = isempty(b.word);
    end

    % Conversion to a vector.
    function c = double(obj)
      c = obj.word;
    end
 
    function b12 = mtimes(b1,b2)
      b12 = braidlab.braid([b1.word b2.word],max(b1.n,b2.n));
    end

    function bm = mpower(b,m)
      bm = braidlab.braid([],b.n);
      if m > 0
	bm.word = repmat(b.word,[1 m]);
      else
	bm.word = repmat(b.inv.word,[1 -m]);
      end
    end

    function bi = inv(b)
      bi = braidlab.braid(-b.word(end:-1:1),b.n);
    end

    function str = char(b)
      if isempty(b.word)
	str = 'e';
      else
	str = num2str(b.word);
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
      l = length(b.word);
    end

  end % methods block

  % Static methods defined in separate files.
  % Need to execute 'clear classes' to register changes here.
  methods (Static = true)
    [b,tc] = crosstimes(XY,t)
  end % static methods

end % braid classdef
