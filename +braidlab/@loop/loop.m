%LOOP   Class for representing topological loops in Dynnikov coordinates.
%   A LOOP object represents an equivalence class (under isotopy) of simple
%   closed loops on a disk with N punctures.  The representative loop is
%   encoded in Dynnikov coordinates.  We use the shorthand "loop" to refer
%   to the entire equivalence class.  The loops represented may be
%   multiloops (with disjoint, nonintersecting components), and each
%   component is essential (not contractible to the punctures or the
%   boundary).
%
%   The class LOOP has only one data member:
%
%    'coords'   vector of Dynnikov coordinates [a,b] of length 2N-4.
%
%   In addition, LOOP has the dependent properties
%
%    'a'        the 'a' vector of Dynnikov coordinates, of length N-2
%    'b'        the 'b' vector of Dynnikov coordinates, of length N-2
%
%   METHODS('LOOP') shows a list of methods.
%
%   References:
%
%   I. A. Dynnikov, "On a Yang-Baxter map and the Dehornoy ordering,"
%   Russian Mathematical Surveys 57 (2002), 592-594.
%
%   J.-O. Moussafir, "On computing the entropy of braids," Functional
%   Analysis and Other Mathematics 1 (2006), 37-46.
%
%   T. Hall & S. Yurttas, "On the topological entropy of families of
%   braids," Topology and its Applications 156 (2009), 1554-1564.
%
%   J.-L. Thiffeault, "Braids of entangled particle trajectories," Chaos
%   20 (2010), 017516.
%
%   See also LOOP.LOOP (constructor), BRAID.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2024  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <mbudisic@gmail.com>
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
% LICENSE>

classdef loop < matlab.mixin.CustomDisplay
  properties
    coords = [0 -1]; % Dynnikov coordinates
    basepoint = 0;   % Puncture that serves as a basepoint (0=none)
  end
  properties (Dependent = true)
    a                % 'a' Dynnikov coord vector
    b                % 'b' Dynnikov coord vector
  end

  methods

    function l = loop(varargin)
    %LOOP   Construct a loop object.
    %   L = LOOP(D) creates a loop object L from a vector of Dynnikov
    %   coordinates D.  D must have 2*N-4 elements, where N is the number of
    %   punctures.  Here, loop means a "topological loop", or more precisely
    %   an equivalence class of simple closed multicurves under isotopy.
    %   An empty matrix D results in an error.
    %
    %   L = LOOP(D), where D is a matrix with 2*N-4 columns, creates a
    %   scalar loop object containing a vector of loops, with loop.coords =
    %   D.
    %
    %   Note that the coordinates of the loop are of the same type as the
    %   array used in its construction (usually double by default).  For
    %   example, to construct a loop of 64-bit integers, use LOOP(int64(D)).
    %
    %   L = LOOP(N) where N is an integer (N>2) creates a loop object L with
    %   N punctures.  The loop L is a (nonoriented) generating set for the
    %   fundamental group of the sphere with N-1 punctures, with the Nth
    %   puncture serving as the basepoint.  This sort of object is
    %   convenient when looking for growth of loops under braid action.
    %
    %   L = LOOP(N,M) where N and M are integers creates a loop object L
    %   with M identical loops.  This can be used to pre-allocate memory for
    %   a large number of loops.
    %
    %   L = LOOP(N,'BasePoint') or LOOP(N,M,'BasePoint') adds a basepoint
    %   puncture so the resulting loop has N+1 punctures (N>1).  The loop L
    %   is a (nonoriented) generating set for the fundamental group of the
    %   sphere with N punctures, with the extra puncture serving as the
    %   basepoint.  This sort of object is convenient when looking for
    %   growth of loops under braid action, or for testing for braid
    %   equality.
    %
    %   L = LOOP(...,'BasePoint',B) specifies the basepoint to be puncture
    %   B, with 0 <= B <= N.  B=0 means no basepoint.
    %
    %   L = LOOP('Enum',VMIN,VMAX) returns a loop object containing all
    %   loops with indices bounded from below by the vector VMIN, and from
    %   above by the vector VMAX.  Both VMIN and VMAX are of size 2N-4,
    %   where N is the number of punctures.  There are PROD(VMAX-VMIN+1)
    %   such loops.
    %
    %   L = LOOP('Enum',N,IMIN,IMAX) returns a loop object containing all
    %   loops with N punctures and with entries bounded by the scalars IMIN
    %   and IMAX.  There are (IMAX-IMIN+1)^(2N-4) such loops.
    %
    %   L = LOOP(...,'TYPE') or LOOP(...,@TYPE) creates a loop L with
    %   coordinates of type TYPE.  The default is TYPE=double.  Other useful
    %   values are int32, int64, and vpi (variable precision integers).
    %
    %   This is a method for the LOOP class.
    %
    %   See also LOOP, BRAID, BRAID.LOOPCOORDS, BRAID.EQ.

      % Parse options.
      nobase = true;
      defbp = 0;
      doenum = false;
      htyp = @(x) x;  % By default, htyp does nothing.
      iarg = [];
      for i = 1:length(varargin)
        if ischar(varargin{i})
          if any(strcmpi(varargin{i}, ...
                         {'nobp','nobasepoint','nobase','noboundary'}))
            nobase = true;
            iarg = [iarg i]; %#ok<*AGROW>
          elseif any(strcmpi(varargin{i}, ...
                         {'bp','basepoint','base','boundary','bound'}))
            nobase = false;
            iarg = [iarg i];
            % Is the next argument numeric?
            if i+1 <= nargin
              if isnumeric(varargin{i+1}) && isscalar(varargin{i+1})
                defbp = varargin{i+1};
                iarg = [iarg i+1];
                if defbp == 0
                  nobase = true;
                end
              end
            end
          elseif any(strcmpi(varargin{i},{'enum','enumerate'}))
            doenum = true;
            iarg = [iarg i];
          else
            htyp = str2func(varargin{i});
            iarg = [iarg i];
          end
        elseif isa(varargin{i},'function_handle')
          htyp = varargin{i};
          iarg = [iarg i];
        end
      end
      % Erase the arguments that were parsed.
      % Note that we use () rather than {} here, so the element is removed.
      for i = length(iarg):-1:1
        varargin(iarg(i)) = [];
      end

      if doenum
        % Enumerate loops.
        l.coords = htyp(looplist(varargin{:}));
        return
      end

      if length(varargin) > 2
        error('BRAIDLAB:loop:loop:badarg','Too many arguments.')
      end

      if strcmp(char(htyp),'vpi'), braidlab.util.checkvpi; end

      % Default loop around first two of three punctures.
      if length(varargin) == 0 %#ok<ISMT>
        l.coords = htyp(l.coords);
        if ~nobase
          if ~defbp
            l.basepoint = 3;
          else
            if defbp > 3 || defbp < 1
              error('BRAIDLAB:loop:loop:badbp', ...
                    'Bad basepoint value.')
            end
            l.basepoint = defbp;
          end
        end
        return
      end

      c = varargin{1};

      if isscalar(c) && ~isa(c,'braidlab.loop')
        % Nested generators of the fundamental group of a sphere with c
        % punctures with an extra basepoint puncture on the right.
        if nobase && c < 3
          error('BRAIDLAB:loop:loop:toofewpunc', ...
                'Need at least three punctures.');
        end
        if ~nobase && c < 2
          error('BRAIDLAB:loop:loop:toofewpunc', ...
                'Need at least two punctures in addition to basepoint.');
        end
        if nobase
          n1 = c-2;
        else
          n1 = c-1;
          if ~defbp
            defbp = c+1;
          else
            if defbp > c-1 || defbp < 1
              error('BRAIDLAB:loop:loop:badbp', ...
                    'Bad basepoint value.')
            end
          end
          l.basepoint = defbp;
        end
        m = 1;
        if length(varargin) > 1
          if ~isscalar(varargin{2})
            error('BRAIDLAB:loop:loop:badarg', ...
                  'Second numerical argument must be a scalar.')
          end
          if ~isempty(varargin{2}), m = varargin{2}; end
        end
        l.coords = htyp(zeros(m,2*n1));
        l.coords(:,(n1+1):end) = htyp(-1);
        return
      end

      if isa(c,'braidlab.loop')
        l.coords = htyp(c.coords);
        l.basepoint = c.basepoint;
        return
      end

      if length(varargin) == 1
        % Create from an array with an even number of columns.
        if ndims(c) > 2 %#ok<ISMAT>
          error('BRAIDLAB:loop:loop:badarg', ...
                'Array of coordinates must have 1 or 2 dimensions.')
        end
        if isempty(c)
          error('BRAIDLAB:loop:loop:emptycoord', ...
                'Loop coordinate array cannot be empty.')
        end
        if isvector(c)
          c = c(:).';   % Store coordinates as row vector.
        end
        if mod(size(c,2),2)
          error('BRAIDLAB:loop:loop:oddlength', ...
                'Loop coordinate array must have even number of columns.')
        end
        l.coords = htyp(c);
        if ~nobase
          if ~defbp
            defbp = l.totaln;
          else
            if defbp > l.totaln || defbp < 1
              error('BRAIDLAB:loop:loop:badbp', ...
                    'Bad basepoint value.')
            end
          end
          l.basepoint = defbp;
        end
      else
        error('BRAIDLAB:loop:loop:badarg','Too many arguments.')
      end
    end % function loop

    function value = get.a(obj)
      % Note that this has undesirable behavior on an array of loops.
      value = obj.coords(:,1:size(obj.coords,2)/2);
      assert(~any(isoverflowed(value)), ...
             'BRAIDLAB:loop:loop:overflow',...
             'Dynnikov "a" coordinate has overflowed.');
    end

    function value = get.b(obj)
      % Note that this has undesirable behavior on an array of loops.
      value = obj.coords(:,size(obj.coords,2)/2+1:end);
      assert(~any(isoverflowed(value)), ...
             'BRAIDLAB:loop:loop:overflow',...
             'Dynnikov "b" coordinate has overflowed.');
    end

    function [a,b] = ab(obj)
    %AB   Return the A and B vectors of Dynnikov coordinates.
    %   [A,B] = AB(L) returns the A and B Dynnikov coordinate vectors of
    %   a loop L.
    %
    %   This is a method for the LOOP class.
    %   See also LOOP.

      % Note that this has undesirable behavior on an array of loops.
      a = obj.a;
      b = obj.b;
    end

    function value = l2norm(obj)
    %L2NORM   2-norm of Dynnikov coordinate vector.
    %   L2 = L2NORM(L) returns the norm of vector of
    %   Dynnikov coordinates, L.coords.
    %
    %   If L contains a set of loops, L2 is a column vector.
    %
    %   This is a method for the LOOP class.
    %   See also LOOP.

      value = sqrt( sum( obj.coords.^2, 2 ) );
    end

    function value = n(obj)
    %N   Number of punctures of a loop, without the base point.
    %   N(L) returns the number of punctures for a loop, not including the
    %   base point, if any.  Use TOTALN if you want to include the
    %   basepoint.
    %
    %   This is a method for the LOOP class.
    %   See also LOOP, LOOP.TOTALN.

    % Note that this used to be a derived property.  However, now that
    % we support arrays of loops, there is an undesirable behavior:
    % when calling obj.n with n a derived property, the function get.n
    % is called for each object.  Thus, what is returned is a
    % comma-separated list of the same value n.  Better to define n as a
    % function, then.

      % Length of coords is 2n-4, where n is the number of punctures.
      value = size(obj(1).coords,2)/2 + 2;
      if obj.basepoint, value = value - 1; end
    end

    function value = totaln(obj)
    %TOTALN   Total number of punctures, including base point if any.
    %
    %   This is a method for the LOOP class.
    %   See also LOOP, LOOP.N.

      % Length of coords is 2n-4, where n is the number of punctures.
      value = size(obj(1).coords,2)/2 + 2;
    end

    function ee = eq(l1,l2)
    %EQ   Test loops for equality.
    %
    %   This is a method for the LOOP class.
    %   See also LOOP, BRAID.EQ.
      ee = [l1.n] == [l2.n] && [l1.basepoint] == [l2.basepoint];
      if ee, ee = all([l1.coords] == [l2.coords],2); end
    end

    function ee = ne(l1,l2)
    %NE   Test loops for inequality.
    %
    %   This is a method for the LOOP class.
    %   See also LOOP, LOOP.EQ.
      ee = ~(l1 == l2);
    end

    function Nc = components(obj)
    %COMPONENTS   Number of connected components of a loop.
    %   NC = COMPONENTS(L) returns the number of connected components NC of
    %   a loop L.
    %
    %   This is a method for the LOOP class.
    %   See also LOOP, LOOP.GETGRAPH.

      [~,Lp] = obj.getgraph;
      [~,Nc] = laplaceToComponents(Lp);
    end

    function L = vertcat(varargin)
    %VERTCAT   Vertical concatenation of loops.
    %   [L1; L2] creates a loop object whose coordinates are formed by
    %   [L1.coords; L2.coords].  It is only allowed when all loop objects
    %   have the same number of punctures, and when their coordinate
    %   datatypes match.
    %
    %   This is a method for the LOOP class.
    %   See also LOOP.

      % check that all inputs are loops
      assert( all(cellfun( @(x)isa(x,'braidlab.loop'), varargin )),...
             'BRAIDLAB:loop:vertcat:nonloops',...
             ['Only braidlab/loops can be stacked'] );

      % all loops have to have the same basepoint
      basepoints = cellfun( @(x)x.basepoint, varargin );
      assert( all(basepoints(:) == basepoints(1)),...
             'BRAIDLAB:loop:vertcat:mixedbasepoints',...
             ['Only loops with matching '...
                   'basepoints can be stacked'] );

      try

        % The line below does as follows:
        % cellfun - extracts coords matrices into a cell array
        % cell2mat - converts the cell array into a matrix of
        % coordinates
        % braidlab.loop - creates a new loop
        L = braidlab.loop( cell2mat( ...
            cellfun( @(x)x.coords, varargin(:), ...
                     'uniformoutput',false ) ...
            ), 'basepoint', varargin{1}.basepoint );

      catch me
        switch me.identifier
          case 'MATLAB:cell2mat:MixedDataTypes',
            error('BRAIDLAB:loop:vertcat:mixeddatatypes',...
                  ['Only loops of the matching data type'...
                   ' can be stacked']);
          case 'MATLAB:catenate:dimensionMismatch',
            error('BRAIDLAB:loop:vertcat:mixedpuncturecount',...
                  ['Only loops with matching number '...
                   'of punctures can be stacked']);
          otherwise
            rethrow(me)
        end
      end
    end

    % Currently, concatenation other than vertical is not allowed
    function varargout = horzcat(varargin)
      error('BRAIDLAB:loop:noarrays',...
            'Only vertical concatenation of loops is allowed.')
    end

    function varargout = cat(varargin)
      error('BRAIDLAB:loop:noarrays',...
            'Only vertical concatenation of loops is allowed.')
    end


  end % methods block


  methods (Access = protected)

    function displayScalarObject(obj)
      displayNonScalarObject(obj)
    end

    function displayNonScalarObject(obj)
      for j = 1:size(obj,1)
        wc = display_row(obj(j,:));
        disp(char(wc))
        if j ~= size(obj,1)
          fprintf('\n')  % skip line between elements.
        end
      end
    end

  end % methods block

  methods (Access = private)

  end

end % loop classdef
