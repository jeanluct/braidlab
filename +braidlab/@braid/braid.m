%BRAID   Class for representing braids.

% set/get methods
% better naming convention for vars

classdef braid
  properties
    n
    word
  end

  methods

    function br = braid(b,nn)
      if nargin ==0
	% Allow empty braid: return identity with order 1.
	br.n = 1;
	br.word = [];
	return
      end
      if isa(b,'braidlab.braid')
	br.n     = b.n;
	br.word  = b.word;
	if nargin > 1
	  error
	end
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

    function ee = eq(b1,b2)
    %EQ   Test braids for equality.
      ee = b1.n == b2.n;
      % Check if the loop coordinates are the same.
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
