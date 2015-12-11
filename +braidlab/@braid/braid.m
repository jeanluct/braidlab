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
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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

    function br = braid(b,varargin)
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
    %   B = BRAID('Random',N,K) returns a random braid of N strings with K
    %   crossings (generators).  The K generators are chosen uniformly in
    %   [-(N-1):-1 1:N-1].
    %
    %   B = BRAID('Normal',N,K) returns a random braid of N strings with K
    %   crossings (generators).  The indices of the generators are chosen
    %   from the binomial distribution with p=1/2 over [1:N-1] and the sign
    %   is chosen uniformly at random.
    %
    %   B = BRAID('HalfTwist',N) or BRAID('Delta',N) returns the word D in
    %   Artin generators representing the positive half-twist (Delta) for
    %   the braid group with N strings.
    %
    %   B = BRAID('FullTwist',N) or BRAID('Delta2',N) returns the square
    %   of the half-twist braid.
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

      %% Convert annular braid to a braid
      if isa(b,'braidlab.annbraid')
        % This is a bit of a kludge.  annbraid needs a custom conversion
        % to braid.  b.braid calls the right function (annbraid.braid),
        % but braid(b) doesn't.  That's ok, let's just do it here.
        % This needs to go here because b is then also a braid.
        br = b.braid;
        return % annbraid converted to braid
      end

      %% Copy of the braid
      if isa(b,'braidlab.braid')
        br.word = b.word;
        br.n = b.n;
        return % copy of input braid
      end

      %% Convert braid from left-canonical form to a "regular" braid
      if isa(b,'braidlab.cfbraid')
        D = braidlab.braid('halftwist',b.n);
        br = D^b.delta * braidlab.braid(cell2mat(b.factors),b.n);
        return % cfbraid converted to braid
      end

      %% Get a named braid
      if ischar(b)
        [W,N] = braidlab.braid.named_braids( b, varargin{:});
        br = braidlab.braid(W,N);
        return % named braid
      end

      %% Vector (or a single) generator
      if isvector(b) || isscalar(b) || isempty(b)

        % store the word
        br.word = b(:).';
        br.n = max(abs(br.word))+1; % minimal number of strands

        if numel(varargin) == 1
          % if valid index and larger than default
          try
            validateattributes( varargin{1}, {'numeric'},...
                                {'scalar','>=',br.n,'finite',...
                                'real','integer'} );
          catch me
            m = MException('BRAIDLAB:braid:braid:badarg',...
                           'Invalid number of strands.');
            throw(m.addCause(me));
          end

          br.n = int32(varargin{1});
        end % numel(varargin)

        return;
      end % isvector(b)

      %% trajectory data is either a cell or a 2d or 3d matrix
      if iscell(b) || (isnumeric(b) && ndims(b) <= 3)
        try
          dbr = braidlab.databraid(b, varargin{:},'CheckClosure',true);
        catch me
          m = MException('BRAIDLAB:braid:braid:badcurves',...
                         'Braid from trajectories failed.');
          throw(m.addCause(me));
        end
        br = dbr.braid; % strip crossing times
        return ; % converted databraid
      end

      %% if nothing works, fail
      error('BRAIDLAB:braid:braid:badarg', ...
            'Improper input into braid constructor');

    end % function braid

      function obj = set.n(obj,value)
        if isempty(value), return; end
        validateattributes( value, {'numeric'}, {'positive','scalar','integer'} );
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
        else
          value = double(max(max(abs(obj.word))+1,obj.privaten));
        end
      end

      % Make sure it's an int32, internally.
      function obj = set.word(obj,word)
        if isempty(word)
          % Make sure the empty word is 0 by 0.
          obj.word = int32([]);
        else
          try
            validateattributes( word, {'numeric'}, ...
                                {'vector','nonzero','finite','nonnan',...
                                'real','integer'});
            % needed b/c of a bug in validateattributes
            assert( all(word ~= 0), 'One of the generators is zero' );
            obj.word = int32(word);
          catch me
            m = MException('BRAIDLAB:braid:setword:badarg',...
                           ['Generators have to be nonzero, non-NaN and ' ...
                            'finite.']);
            throw(m.addCause(me));
          end
        end
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

      function bm = mpower(b,m)
      %MPOWER   Raise a braid to some positive or negative power.
      %   C = B^N, where B is a braid and N is a positive integer, returns the
      %   Nth power of the braid B, C = B*B*...*B (N times).
      %
      %   For negative N, the inverse of B is multiplied |N| times.
      %
      %   This is a method for the BRAID class.
      %   See also BRAID, BRAID.INV, BRAID.MTIMES.
        bm = braidlab.braid([], b.n);
        switch( sign(m) )
          case 1
            bm.word = repmat(b.word,[1 m]);
          case -1
            bm.word = repmat(b.inv.word,[1 -m]);
          otherwise
            []; % do nothing
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
        c = hist(b.word,i);
        i(highestIndex+1) = [];
        c(highestIndex+1) = [];
      end

  end % methods block


  methods (Access = protected)

    function displayScalarObject(b)
      c = sprintf('[n = %d]  ',b.n); % print # strands
      c = [c, char(b)]; % print generators
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

  % static methods
  methods (Static)

    function [W,N] = named_braids( name, varargin )
    %NAMED_BRAIDS Selector of named braids
    % First argument is a string selecting the name
    %

      try
        switch lower(name)
          case {'halftwist','delta'}
            [W,N] = braidlab.braid.named_braid_halftwist(varargin{:});
          case {'fulltwist','delta2'} % just double-up halftwist
            [W,N] = braidlab.braid.named_braid_halftwist(varargin{:});
            W = [W W];
          case {'hironakakin','hironaka-kin','hk'}
            [W, N] = braidlab.braid.named_braid_hk( varargin{:} );
          case {'venzkepsi','psi'}
            [W, N] = braidlab.braid.named_braid_venzke( varargin{:} );
          case {'rand','random'}
            [W,N] = braidlab.braid.named_braid_random( varargin{:} );
          case {'normal','binomal','norm','binom'}
            [W,N] = braidlab.braid.named_braid_binom( varargin{:} );
          otherwise
            [W, N] = braidlab.braid.knot2braid( name, varargin{:} );
        end % switch
      catch me
        m = MException('BRAIDLAB:braid:named_braids:badarg',...
                       'Named braid %s received incorrect arguments', name );
        throw(m.addCause(me));
      end
      W = int32(W);
    end % named_braids

    %
    % Static methods defined in separate files.
    %
    % These methods do not need a braid object as a first argument.
    %
    % Need to execute 'clear classes' to register changes here.
    %


    [W, N] = named_braid_venzke(varargin) % Venzke braid word
    [W, N] = named_braid_hk(varargin) % Hironaka-Kin braid word
    [W, N] = named_braid_halftwist(varargin) % halftwist braid word
    [W, N] = named_braid_random(varargin) % uniformly random braid word
    [W, N] = named_braid_binom(varargin) % binomial random braid word

    [W, N] = knot2braid(varargin) % braid words corresponding to knots

  end

  % The subclass databraid has access to colorbraiding.
  methods (Static = true, Access = {?braidlab.databraid})
    [varargout] = colorbraiding(XY,t,proj,checkclosure)
  end % methods block

end % braid classdef
