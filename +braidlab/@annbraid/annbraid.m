%ANNBRAID   Class for representing braids on the annulus.
%   A ANNBRAID object holds a braid defined on an annular domain.
%
%   In addition to the data members of the BRAID class, the class ANNBRAID
%   has the following data member (property):
%
%    '???'   ???
%
%   METHODS('ANNBRAID') shows a list of methods.
%
%   See also ANNBRAID.ANNBRAID (constructor).

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

classdef annbraid < braidlab.braid
  properties
  end
  properties (Dependent)
    nann                % number of annular strings (without basepoint)
  end

  methods

    function obj = annbraid(varargin)
    %ANNBRAID   Construct an annbraid object.
    %   B = ANNBRAID(W) constucts an annular braid B from a word W.
    %
    %   B = ANNBRAID(W,NANN) constucts an annular braid from a word W with
    %   NANN strings.  The 'basepoint' string is *not* included in those
    %   NANN strings, so generator values can be between -NANN and NANN.
    %
    %   Note that B.N will return NANN+1, which includes the basepoint
    %   string.
    %
    %   This is a method for the ANNBRAID class.
    %   See also ANNBRAID, BRAID.
      if nargin > 0
        if isa(varargin{1},'braidlab.braid')
        elseif max(size(size(varargin{1}))) == 3
          % Create braid from data.
          error('Not implemented yet.')
        else
          % Numerical first argument.
          % Pass an extra string to the constructor, representing the basepoint.
          if nargin > 1
            varargin{2} = varargin{2}+1;
          end
        end
      end
      obj = obj@braidlab.braid(varargin{:});
    end

    % The annular strings are the strings without the basepoint.
    % Would be better to override n, but I don't think we can do that.
    function value = get.nann(obj)
      value = obj.n-1;
    end
    function obj = set.nann(obj,value)
      obj.n = value+1;
    end

    function b = braid(ab)
    %BRAID   Convert an ANNBRAID to a regular BRAID.
    %   C = BRAID(B) converts the annular braid B to a regular braid object
    %   C by transforming each generator.
    %
    %   This is a method for the ANNBRAID class.
    %   See also BRAID.BRAID.
      b = convert_to_braid(ab);
    end

    function [varargout] = mtimes(b1,b2)
    %MTIMES   Multiply two annbraids together or act on a loop with an annbraid.

      if isa(b2,'braidlab.annbraid')
        % If b2 is also an annular braid, the product is simple concatenation.
        varargout{1} = braidlab.annbraid(mtimes@braidlab.braid(b1,b2));
      elseif isa(b2,'braidlab.loop')
        if b2.basepoint < b1.n
          error('BRAIDLAB:annbraid:mtimes', ...
                'Annular braid can only act on a loop with a basepoint.')
        end
        [varargout{1:nargout}] = mtimes@braidlab.braid(b1.braid,b2);
      end
    end

    function bm = mpower(b,m)
    %MPOWER   Raise an annbraid to some positive or negative power.
    %
    %   This is a method for the ANNBRAID class.
    %   See also ANNBRAID, ANNBRAID.MTIMES, ANNBRAID.INV.
      bm = braidlab.annbraid(mpower@braidlab.braid(b,m));
    end

    function bi = inv(b)
    %INV   Inverse of an annbraid.
    %
    %   This is a method for the ANNBRAID class.
    %   See also ANNBRAID, ANNBRAID.MTIMES, ANNBRAID.MPOWER.
      bi = braidlab.annbraid(inv@braidlab.braid(b));
    end

    function p = perm(obj)
    %PERM   Permutation corresponding to an annbraid.
    %
    %   This is a method for the ANNBRAID class.
    %   See also ANNBRAID, ANNBRAID.ISPURE.

      p = perm@braidlab.braid(obj.braid);

      if p(end) ~= length(p)
        error('BRAIDLAB:annbraid:badperm', ...
              'Basepoint should not move.')
      end
      % Drop the last entry: ignore basepoint in the permutation.
      p(end) = [];
    end

    function wr = writhe(obj)
    %WRITHE   Writhe of an annbraid.
    %
    %   This is a method for the ANNBRAID class.
    %   See also ANNBRAID.

      % Convert the annbraid to a braid first, to include the basepoint.
      wr = writhe@braidlab.braid(obj.braid);
    end

    function str = char(b)
    %CHAR   Convert annbraid to string.
    %
    %   This is a method for the ANNBRAID class.
    %   See also ANNBRAID, ANNBRAID.DISP.

      str = char@braidlab.braid(b);
      % Append an asterisk: same notation as for basepoint.
      str = [str '*'];
    end

  end % methods block

end % annbraid classdef
