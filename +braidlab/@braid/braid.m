%BRAID   Class for representing braids.
%   A BRAID object holds a braid represented in terms of Artin generators.
%
%   The class BRAID has the following data members:
%
%    'word'     vector of signed integers (int32) giving the Artin generators
%    'n'        number of strings in the braid
%
%   METHODS('BRAID') shows a list of methods.
%
%   See also BRAID.BRAID (constructor), CFBRAID.

% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault, Marko Budisic
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
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

classdef braid < matlab.mixin.CustomDisplay
  properties
    word = int32([]) % braid word in Artin generators
  end

  % The number of strings is a dependent property (not stored internally).
  % It is obtained through the get.n method by the max over generators and
  % the private data member obj.privaten.  The reason for this is that the
  % set.n property needs to check that the generators in obj.word are
  % compatible with a new value of n.  But if n is a class data member then
  % it is not allowed to refer to obj.word, because there is no guarantee of
  % the order in which the data members are created.
  %
  % See http://www.mathworks.com/help/matlab/matlab_oop/tips-for-saving-and-loading.html
  properties (Dependent)
    n                % number of strings
  end
  properties (Access=private)
    privaten = 0;
  end

  methods

    function br = braid(b,secnd,third)
    %BRAID   Construct a braid object.
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
    %   B = BRAID(XY,PROJANG) uses a projection line with angle PROJANG (in
    %   radians) from the X axis to determine crossings.  The default is to
    %   project onto the X axis (PROJANG = 0).
    %
    %   BC = BRAID(B) copies the object B of type BRAID or CFBRAID to the BRAID
    %   object BC.
    %
    %   B = BRAID('random',N,K) returns a random braid of N strings with K
    %   crossings (generators).  The K generators are chosen uniformly in
    %   [-(N-1):-1 1:N-1].
    %
    %   B = BRAID('halftwist',N) or BRAID('Delta',N) returns the word D in
    %   Artin generators representing the positive half-twist (Delta) for
    %   the braid group with N strings.
    %
    %   B = BRAID('HironakaKin',M,N) or BRAID('HK',M,N) returns a member of
    %   the Hironaka & Kin family of braids on M+N+1 strings:
    %
    %     sigma(M,N) = s(1) s(2) ... s(M) s(M) ... s(1) s(1) ... s(M+N)
    %
    %   B = BRAID('HironakaKin',N) for N odd returns
    %   BRAID('HironakaKin',(N-3)/2,(N+1)/2), the braid which is thought to
    %   minimize the entropy on the disk with an odd number N of punctures
    %   (N>3).  This is useful for checking the "worst-case scenario" for
    %   computing a positive entropy.  For large N, the entropy of this
    %   braid is bounded from above by log(2+sqrt(3))/((N-1)/2).
    %
    %   B = BRAID('HironakaKin',N) for N even (N>4) returns
    %   BRAID('HironakaKin',(N+2)/2,(N-4)/2), which is pseudo-Anosov but
    %   does not minimize entropy for even N.
    %
    %   B = BRAID('VenzkePsi',N) or BRAID('PSI',N) returns a member of
    %   the Venzke family of psi-braids on N strings (N>4).
    %
    %   B = BRAID(K) returns a braid representative B for the knot K.  The
    %   knot is denoted in standard coding as '0_1', '3_1', '5_2', etc.
    %   Currently knots up to 8 crossings are represented.
    %
    %   References:
    %
    %   E. Hironaka and E. Kin, "A family of pseudo-Anosov braids with small
    %   dilatation," Alg. Geom. Topology 6 (2006), 699-738.
    %
    %   E. Lanneau and J.-L. Thiffeault, "On the minimum dilatation of
    %   braids on punctured discs," Geometriae Dedicata 152 (2011), 165-182.
    %
    %   R. Venzke, "Braid forcing, hyperbolic geometry, and pseudo-Anosov
    %   sequences of low entropy," PhD Thesis (2008).
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, CFBRAID.

      % Allow default empty braid: return trivial braid with one string.
      if nargin == 0, return; end
      if isa(b,'braidlab.braid')
        br.n     = b.n;
        br.word  = b.word;
      elseif isa(b,'braidlab.cfbraid')
        D = braidlab.braid('halftwist',b.n);
        br = D^b.delta * braidlab.braid(cell2mat(b.factors),b.n);
      elseif ischar(b)
        % First argument is a string.
        switch lower(b)
         case {'halftwist','delta'}
          br.n = secnd;
          % D has size br.n*(br.n-1)/2. Could preallocate if speed important.
          D = [];
          for i = 1:br.n-1, D = [D br.n-1:-1:i]; end %#ok<AGROW>
          br.word = D;
         case {'hironakakin','hironaka-kin','hk'}
          m = secnd;
          if nargin < 3
            if m < 5
              error('BRAIDLAB:braid:braid:badarg', ...
                    'Need at least five strings.')
            end
            if mod(m,2) == 1
              n = (m+1)/2; %#ok<*PROP>
              m = (m-3)/2;
            else
              n = (m+2)/2;
              m = (m-4)/2;
            end
          else
            n = third;
          end
          N = m+n+1;
          br.n = N;
          br.word = [1:m m:-1:1 1:N-1];
         case {'venzkepsi','psi'}
          % See page 1 of Venzke's thesis.
          n = secnd;
          if n < 5
            error('BRAIDLAB:braid:braid:badarg','Need at least five strings.')
          end
          br.n = n;
          if n == 6
            br.word = [5:-1:1 5 4 3 5 4];
            return
          end
          L = (n-1):-1:1;
          if mod(n,2) == 1
            br.word = [L L -1 -2];
          elseif mod(n,4) == 0
            k = n/4;
            br.word = [repmat(L,1,2*k+1) -1 -2];
          elseif mod(n,8) == 2
            k = (n-2)/8;
            br.word = [repmat(L,1,2*k+1) -1 -2];
          elseif mod(n,8) == 6
            k = (n-6)/8;
            br.word = [repmat(L,1,6*k+5) -1 -2];
          end
         case {'rand','random'}
          br.n = secnd;
          k = third;
          br.word = (-1).^randi(2,1,k) .* randi(br.n-1,1,k);
         otherwise
          % Maybe the string specifies a knot.
          try
            br = knot2braid(b);
          catch err
            error('BRAIDLAB:braid:braid:badarg','Unrecognized string argument.')
          end
        end
      elseif max(size(size(b))) == 3
        % b is a 3-dim array of data.  secnd contains the projection angle.
        if nargin > 2
          error('BRAIDLAB:braid:braid:badarg','Too many input arguments.')
        elseif nargin < 2
          % Use a zero projection angle.
          secnd = 0;
        end
        br = braidlab.braid.colorbraiding(b,1:size(b,1),secnd);
      else
        if size(b,1) ~= 1 && size(b,2) ~= 1 && ~isempty(b)
          % b is neither a row vector or a column vector.  Hopefully the
          % user means a one-particle dataset.  Perhaps he/she is trying to
          % create several braids at once (which is not currently
          % allowed).  By default, print a warning.
          if size(b,2) == 2
            warning('BRAIDLAB:braid:braid:onetraj', ...
                    [ 'Creating trivial braid from single ' ...
                      'trajectory (did you mean that?).' ])
            br.word = [];
            br.n = 1;
          else
            error('BRAIDLAB:braid:braid:badarg','Bad array size.')
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
            br.n = secnd;
          end
        end
      end
    end % function braid

    function obj = set.n(obj,value)
      if value < 1
        error('BRAIDLAB:braid:setn:badarg','Need at least one string.')
      end
      if ~isempty(obj.word)
        if value < max(abs(obj.word))+1
          error('BRAIDLAB:braid:setn:badarg', ...
                'Too few strings for generators.')
        end
      end
      obj.privaten = double(value);
    end

    function value = get.n(obj)
      if isempty(obj.word)
        value = double(max(1,obj.privaten));
        return
      end
      value = double(max(max(abs(obj.word))+1,obj.privaten));
    end

    % Make sure it's an int32, internally.
    function obj = set.word(obj,value)
      if ~all(value)
        error('BRAIDLAB:braid:setword:badarg','Generators cannot be zero.')
      end
      obj.word = int32(value);
      % Make sure the empty word is 0 by 0.
      if isempty(obj.word), obj.word = int32([]); end
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
      ee = b1.n == b2.n; if ~ee, return; end
      if isempty(b1.word)
        if isempty(b2.word)
          ee = true;
          return
        end
      end
      % Check if the loop coordinates are the same.
      ee = all(loopcoords(b1) == loopcoords(b2));
    end

    function ee = lexeq(b1,b2)
    %LEXEQ   Test braids for lexicographical equality.
    %   LEXEQ(B1,B2) return TRUE if the words representing B1 and B2 in
    %   terms of braid generators are equal, generator by generator.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.EQ, LOOP, LOOPCOORDS.
      ee = b1.n == b2.n && length(b1) == length(b2);
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
    %ISTRIVIAL   Return true if braid is the trivial braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.EQ.
      if isempty(b.word), ee = true; return; end
      ee = all(loopcoords(b) == loopcoords(braidlab.braid([],b.n)));
    end

    function ee = ispure(obj)
    %ISPURE   Return true if braid is a pure braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.PERM.
      ee = all(obj.perm == 1:obj.n);
    end

    function [varargout] = mtimes(b1,b2)
    %MTIMES   Multiply two braids together or act on a loop with a braid.
    %   C = B1*B2, where B1 and B2 are braid objects, return the product of
    %   the two braids.  The product is the group operation in the braid
    %   group (braid concatenation).
    %
    %   L2 = B*L, where B is a braid and L is a loop object, returns a new
    %   loop L2 given by the action of B on L.  L can also be a column
    %   vector of loops.
    %
    %   [L2,M] = B*L also returns the sparse matrix M giving the effective
    %   linear action of the braid B on the loop L.  This means that the
    %   piecewise-linear action B*L is equal to the matrix-vector
    %   multiplication M*L.coords' for this particular loop L.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.INV, BRAID.MPOWER, LOOP.
      if isa(b2,'braidlab.braid')
        % If b2 is also a braid, the product is simple concatenation.
        varargout{1} = braidlab.braid([b1.word b2.word],max(b1.n,b2.n));
      elseif isa(b2,'braidlab.loop')
        % Action of braid on a loop.
        %
        % Have to define this here, rather than in the loop class, since the
        % braid goes on the left, and Matlab determines which overloaded
        % function to call by looking at the first argument.
        if ~isscalar(b2)
          % Can't act on array of loops with a braid.
          % This is very inefficient, and can be done instead with a
          % scalar containing an array of loop coordinates.
          error('BRAIDLAB:braid:mtimes:notscalar', ...
                ['Action of braid on nonscalar loop array not supported.' ...
                 '  Instead use matrix of loop.coords.  ' ...
                 'Try ''help loop.loop''.'])
        end
        if b1.n > b2.n
          error('BRAIDLAB:braid:mtimes:badgen', ...
                'Braid has too many strings for the loop.')
        end
        [varargout{1:nargout}] = loopsigma(b1.word,b2.coords);
        varargout{1} = braidlab.loop(varargout{1});
        if nargout > 1
          % Actually, return the matrix of the linear action instead of pn.
          varargout{2} = linact(b1,varargout{2},size(b2(1).coords,2));
        end
      else
        error('BRAIDLAB:braid:mtimes:badobject', ...
              'Cannot act with a braid on this object.')
      end
    end

    function bm = mpower(b,m)
    %MPOWER   Raise a braid to some positive or negative power.
    %   C = B^N, where B is a braid and N is a positive integer, returns the
    %   Nth power of the braid B, C = B*B*...*B (N times).
    %
    %   For negative N, the inverse of B is multiplied |N| times.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.INV, BRAID.MTIMES.
      bm = braidlab.braid([],b.n);
      if m > 0
        bm.word = repmat(b.word,[1 m]);
      elseif m < 0
        bm.word = repmat(b.inv.word,[1 -m]);
      end
    end

    function bi = inv(b)
    %INV   Inverse of a braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.MTIMES, BRAID.MPOWER.
      bi = braidlab.braid(-fliplr(b.word),b.n);
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

    function l = length(b)
    %LENGTH   Length of a braid.
    %   L = LENGTH(B) returns the number of generators in the current
    %   internal representation of a braid.  Calling COMPACT(B) can reduce
    %   this length, often dramatically when B is created from data.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.COMPACT.
      l = length(b.word);
    end

    function [c,i] = gencount(b)
    %GENCOUNT   Count number of occurrences of each generator in a braid.
    %   [C,I] = GENCOUNT(B) returns a vector C containing the generator
    %   distribution of B, i.e., the number of occurrences of each braid
    %   generator within the braid B.  The vector I contains the
    %   corresponding generator indices.  In other words C(k) counts the
    %   number of times the generator sigma_{I(k)} occurs in the braid.
    %   Plotting I vs. C plots the generator distribution.
    %
    %   sum(C) is equal to length of the braid.
    %
    %   This is a method for the BRAID class.
    %   See also BRAID, BRAID.LENGTH.

      highestIndex = (b.n-1);
      i = double(-highestIndex:highestIndex);
      c = hist( b.word, i );
    end

  end % methods block


  methods (Access = protected)

    function displayScalarObject(b)
      c = char(b);
      sz = get(0, 'CommandWindowSize');
      wc = textwrap({c},sz(1)-4);
      for i = 1:length(wc)
        % Indent rows.
        if i > 1, wc{i} = ['   ' wc{i}]; else wc{i} = [' ' wc{i}]; end
        % If the format is loose rather than compact, add a line break.
        if strcmp(get(0,'FormatSpacing'),'loose')
          wc{i} = sprintf('%s\n',wc{i});
        end
      end
      disp(char(wc))
    end

  end % methods block

  %
  % Static methods defined in separate files.
  %
  % These methods do not need a braid object as a first argument.
  %
  % Need to execute 'clear classes' to register changes here.
  %

  % The subclass databraid has access to colorbraiding.
  methods (Static = true, Access = {?braidlab.databraid})
    [varargout] = colorbraiding(XY,t,proj)
  end % methods block

end % braid classdef
