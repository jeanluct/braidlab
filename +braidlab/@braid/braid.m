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
%   For all these constructors a list of crossing times T may also be
%   appended as a final argument.
%
%   See also CFBRAID.

% set/get methods
% better naming convention for vars

classdef braid
  properties
    n
    word
    t
  end

  methods

    function br = braid(b,nn,t)
      if nargin ==0
	% Allow empty braid: return identity with one strand.
	br.n = 1;
	br.word = [];
	br.t = [];
	return
      end
      if isa(b,'braidlab.braid')
	br.n     = b.n;
	br.word  = b.word;
	if nargin > 1
	  br.t = nn;
	else
	  br.t = [];
	end
      elseif max(size(size(b))) == 3
	% The input is an array of data.
	if nargin < 2
	  nn = 1:size(b,1);
	end
	br = color_braiding(b,nn);
      else
	% Store word as row vector.
	if size(b,1) > size(b,2)
	  b = b.';
	end
	br.word = b;
	if nargin < 2
	  br.n = max(abs(b))+1;
	  br.t = [];
	else
	  if isscalar(nn)
	    if length(b) == 1
	      % Ambiguous.
	      error('BRAIDLAB:braid:braid',...
		    ['Ambiguous scalar as second argument for braid of' ...
		     ' length 1.'])
	    end
	    br.n = nn;
	  else
	    br.n = max(abs(b))+1;
	  end
	  if nargin > 2
	    br.t = t;
	  else
	    br.t = [];
	  end
	end
      end
      % Store time as row vector.
      if size(br.t,1) > size(br.t,2)
	br.t = br.t.';
      end
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
      import braidlab.braid
      b1 = braid(b1);
      b2 = braid(b2);
      b12 = braid([b1.word b2.word]);
    end

    function bb = mpower(b,m)
      b = braidlab.braid(b);
      if m == 0
	bb = braidlab.braid([]);
      elseif m > 0
	bb = b;
	bb.word = repmat(bb.word,[1 m]);
      else
	bb = b.inv;
	bb.word = repmat(bb.word,[1 -m]);
      end
    end

    function bi = inv(b)
      b = braidlab.braid(b);
      bi = braidlab.braid(-b.word(end:-1:1));
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

  end
end
