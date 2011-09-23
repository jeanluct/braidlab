%BRAID   Class for representing braids.

% set/get methods
% lexequal
% eq
% makelcf
% better naming convention for vars
% How to handle canonical form?  Separate class?
% Suggestion: always use LCF, make == check also delta.
% The problem with storing the LCF "internally" is that any
% multiplication, etc, will screw it up.  Unless I always re-LCF.

classdef braid
  properties
    repr
    n
    word
    delta
  end

  methods

    function br = braid(b,nn)
      if isa(b,'braidlab.braid')
	br.repr  = b.repr;
	br.n     = b.n;
	br.word  = b.word;
	br.delta = b.delta;
	if nargin > 1
	  error
	end
      else
	br.word = b;
	br.repr = 'word';
	br.delta = 0;
	if nargin < 2
	  br.n = max(abs(b))+1;
	else
	  n = nn;
	end
      end
    end

   % rename this to lexeq once true equality is implemented.
   function ee = eq(b1,b2)
   %EQ   Test braids for equality.
      import braidlab.braid
      b1 = braid(b1);
      b2 = braid(b2);
      ee = b1.n == b2.n & b1.delta == b2.delta & ~any(b1.word ~= b2.word);
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
      str = ['<' str '>'];
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

    function [varargout] = compact(b,t)
      w = b.word;
      cancel = true;
      while cancel
	cancel = false;
        i = find(w(1:end-1) == -w(2:end));
	if ~isempty(i)
	  w([i i+1]) = [];
	  if nargin > 1, t([i i+1]) = []; end
	  cancel = true;
	end
        i = find(w(1:end-2) == -w(3:end) & ...
		 abs(abs(w(2:end-1))-abs(w(1:end-2))) > 1);
	if ~isempty(i)
	  w([i i+2]) = [];
	  if nargin > 1, t([i i+2]) = []; end
	  cancel = true;
	end
        i = find(w(1:end-3) == -w(4:end) & ...
		 abs(abs(w(2:end-2))-abs(w(1:end-3))) > 1 & ...
		 abs(abs(w(3:end-1))-abs(w(1:end-3))) > 1);
	if ~isempty(i)
	  w([i i+3]) = [];
	  if nargin > 1, t([i i+3]) = []; end
	  cancel = true;
	end
      end
      b.word = w;
      varargout{1} = b;
      if nargout > 1, varargout{2} = t; end
    end

  end
end
