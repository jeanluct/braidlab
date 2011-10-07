%LOOP   Class for representing loops in Dynnikov coordinates.
%   L = LOOP(D) creates a loop object L from a vector of Dynnikov
%   coordinates D.
%
%   References:
%
%   I. A. Dynnikov, "On a Yang-Baxter map and the Dehornoy ordering,"
%   Russian Mathematical Surveys 57 (2002), 592-594.
%
%   J.-O. Moussafir, "On Computing the Entropy of Braids," Functional
%   Analysis and Other Mathematics 1 (2006), 37-46.
%
%   T. Hall & S. Yurttas, "On the topological entropy of families of
%   braids," Topology and its Applications 156 (2009), 1554-1564.
%
%   J.-L. Thiffeault, "Braids of entangled particle trajectories," Chaos
%   20 (2010), 017516.
%
%   See also BRAID.

classdef loop
  properties
    coords = [0 1];  % Dynnikov coordinates
  end
  properties (Dependent = true)
    n                % number of strands
    a                % "a" Dynnikov coord vector
    b                % "b" Dynnikov coord vector
  end

  methods

    function l = loop(c)
      % Default loop around first two of three punctures.
      if nargin == 0, return; end
      if isa(c,'braidlab.loop')
	l.coords = c.coords;
	return
      end
      if mod(length(c),2) == 1
	error('BRAIDLAB:loop:loop', ...
	      'Coordinate vector must have even number of elements.')
      end
      l.coords = c;
    end

    % Use this to add a puncture?
    %function obj = set.n(obj,value)
    %end

    function value = get.n(obj)
      % Length of coords is 2n-4, where n is the number of punctures.
      value = length(obj.coords)/2 + 2;
    end

    function value = get.a(obj)
      value = obj.coords(1:length(obj.coords)/2);
    end

    function value = get.b(obj)
      value = obj.coords(length(obj.coords)/2+1:end);
    end

    function [a,b] = ab(obj)
      a = obj.a; b = obj.b;
    end

    %function obj = set.coords(obj,value)
    %end

    function ee = eq(l1,l2)
    %EQ   Test loops for equality.
      ee = l1.n == l2.n;
      if ee, ee = ~any(l1.coords ~= l2.coords); end
    end

    function ee = ne(l1,l2)
      ee = ~(l1 == l2);
    end

    % Conversion to a vector.
    function c = double(obj)
      c = obj.coords;
    end
 
    function str = char(obj)
      str = ['(( ' num2str(obj.coords) ' ))'];
    end

    function disp(obj)
       c = char(obj);
       if iscell(c)
	 disp(['     ' c{:}])
       else
	 disp(c)
       end
    end

    function l = length(obj)
    %LENGTH   The number of intersections of a loop with the real axis.
    %   I = LENGTH(L) computes the minimum number of intersections of a
    %   loop L with the real axis.
    %
      [a,b] = obj.ab;

      % The number of intersections before/after the first and last punctures.
      % See Hall & Yurttas (2009).
      cumb = [0 cumsum(b,2)];
      b0 = -max(abs(a) + max(b,0) + cumb(1:end-1));
      bn1 = -b0 - sum(b);

      % The number of intersections with the real axis.
      l = sum(abs(b)) + sum(abs(a(2:end)-a(1:end-1))) ...
	  + abs(a(1)) + abs(a(end)) + abs(b0) + abs(bn1);
    end

  end % methods block

end % loop classdef
