%CFBRAID   Class for representing braids in left canonical form.
%   The object CFBRAID holds the left canonical form (LCF) W = D^M F of a
%   braid word W.  Here D is the positive half-twist, M is a signed integer,
%   and F is a sequence of positive factors written in Artin generators.
%
%   The class CFBRAID has the following data members:
%
%    'delta'    the power of positive-half twists Delta
%    'factors'  cell array of positive factors
%    'n'        number of strings in the braid
%
%   METHODS('CFBRAID') shows a list of methods.
%
%   Reference: J. S. Birman and T. E. Brendle, "Braids: A Survey," in
%   Handbook of Knot Theory (2005), pp. 78-82.
%
%   See also BRAID, CFBRAID.CFBRAID.

% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
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

classdef cfbraid < matlab.mixin.CustomDisplay
  properties
    delta = 0             % the power of positive-half twists Delta
    factors = cell(0)     % cell array of positive factors
    n = 1                 % number of strings in the braid
  end

  methods

    function br = cfbraid(b,nn)
    %CFBRAID   Construct the left canonical form of a braid word.
    %   B = CFBRAID(W) constructs the left canonical form of a braid word W
    %   expressed as a list of Artin generators.  W can also be a BRAID or
    %   CFBRAID object.  If W is a list, CFBRAID(W,N) can be used to specify
    %   the number of strings N of the braid group, which is otherwise
    %   guessed from W.
    %
    %   This is a method for the CFBRAID class.
    %   See also BRAID.
      if nargin == 0, return; end
      if isa(b,'braidlab.cfbraid')
        br.n = b.n;
        br.factors = b.factors;
        br.delta = b.delta;
        if nargin > 1
          error('BRAIDLAB:cfbraid:cfbraid:badarg', ...
                'Cannot specify n if creating from a cfbraid.')
        end
        return
      elseif isa(b,'braidlab.braid')
        br.n = b.n;
        w = b.word;
        if nargin > 1
          error('BRAIDLAB:cfbraid:cfbraid:badarg', ...
                'Cannot specify n if creating from a braid.')
        end
      else
        if nargin < 2
          br.n = max(abs(b))+1;
        else
          br.n = nn;
          if br.n < max(abs(b))+1
            error('BRAIDLAB:cfbraid:cfbraid:badgen', ...
                  'A generator is out of range.');
          end
        end
        w = b;
      end
      cf = cfbraid_helper(int32(w),br.n,0);
      br.delta = cf.delta;
      br.factors = cf.factors;
    end

    function ee = eq(b1,b2)
    %EQ   Test braids for equality.
    %
    %   This is a method for the CFBRAID class.
    %   See also CFBRAID, BRAID, BRAID.EQ, BRAID.LEXEQ.
      fac1 = cell2mat(b1.factors);
      fac2 = cell2mat(b2.factors);
      ee = b1.n == b2.n && b1.delta == b2.delta && length(fac1) == length(fac2);
      if ee, ee = all(fac1 == fac2); end
    end

    function ee = ne(b1,b2)
    %NE   Test braids for inequality.
    %
    %   This is a method for the CFBRAID class.
    %   See also CFBRAID, BRAID, CFBRAID.EQ, BRAID.EQ.
      ee = ~(b1 == b2);
    end

    function ee = istrivial(b)
    %ISTRIVIAL   Return true if braid is the trivial braid.
    %
    %   This is a method for the CFBRAID class.
    %   See also CFBRAID.
      ee = isempty(b.factors) && b.delta == 0;
    end

    function ee = ispositive(obj)
    %ISPOSITIVE   Return true if braid is positive.
    %   ISPOSITIVE(B) returns true if the braid B can be written with only
    %   positive crossings.
    %
    %   This is a method for the CFBRAID class.
    %   See also CFBRAID, BRAID.
      ee = obj.delta >= 0;
    end

    function w = braid(b)
    %BRAID   Convert left canonical form of a braid to word form.
    %   W = BRAID(B) returns the word representation of a braid B in
    %   terms of braid generators, where B is in left canonical form.
    %   Here W is an object of type BRAID.
    %
    %   See also CFBRAID, BRAID.
      D = braidlab.braid('halftwist',b.n);
      w = D^b.delta * braidlab.braid(cell2mat(b.factors),b.n);
    end

    function str = char(b)
    %CHAR   Convert braid to string.
    %
    %   This is a method for the CFBRAID class.
    %   See also CFBRAID.
      if b.delta == 0 && isempty(b.factors)
        str = '< e >';
        return
      end
      str = '';
      if b.delta ~= 0
        str = [str sprintf('D^%d',b.delta)];
      end
      if ~isempty(b.factors)
        for i = 1:length(b.factors)
          if i == 1 && b.delta == 0
            str = [str num2str(b.factors{i})];
          else
            str = [str ' . ' num2str(b.factors{i})];
          end
        end
      end
      str = ['< ' str ' >'];
    end

    function l = length(b)
    %LENGTH   Word length of left canonical form of a braid word.
    %   L = LENGTH(B) returns the word length of a braid B expressed in
    %   Artin generators, where B is in left canonical form.
    %
    %   This is a method for the CFBRAID class.
    %   See also CFBRAID.
      if b.delta == 0 && isempty(b.factors), l = 0; return; end
      Dl = b.n*(b.n-1)/2;  % The lengh of the half-twist Delta.
      l = abs(b.delta)*Dl + length(cell2mat(b.factors));
    end

  end % methods block


  methods (Access = protected)

    function displayScalarObject(b)
       c = char(b);
       sz = get(0, 'CommandWindowSize');
       wc = textwrap({c},sz(1)-4);
       for i = 1:length(wc)
         % Indent rows.
         if i > 1, wc{i} = ['   ' wc{i}]; else, wc{i} = [' ' wc{i}]; end
         % If the format is loose rather than compact, add a line break.
         if strcmp(get(0,'FormatSpacing'),'loose')
           wc{i} = sprintf('%s\n',wc{i});
         end
       end
       disp(strvcat(wc))
    end

  end % methods block

end
