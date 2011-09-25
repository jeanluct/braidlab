%BRAID   Class for representing braids.

% set/get methods
% lexeq
% eq
% makelcf
% better naming convention for vars
% How to handle canonical form?  Separate class?
% Suggestion: always use LCF, make == check also delta.
% The problem with storing the LCF "internally" is that any
% multiplication, etc, will screw it up.  Unless I always re-LCF.

classdef braid
  properties
    n
    word
  end

  methods

    function br = braid(b,nn)
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

   % rename this to lexeq once true equality is implemented.
   function ee = eq(b1,b2)
   %EQ   Test braids for lexicographical equality.
      ee = b1.n == b2.n & length(b1) == length(b2);
      if ee, ee = ~any(b1.word ~= b2.word); end
    end

    function ee = ne(b1,b2)
      ee = ~(b1 == b2);
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
