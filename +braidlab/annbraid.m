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

    function obj = annbraid(w,secnd)
    %ANNBRAID   Construct an annbraid object.
    %   B = ANNBRAID(W) constucts an annular braid from a word W.
    %
    %   This is a method for the ANNBRAID class.
    %   See also ANNBRAID, BRAID, ANNBRAID/ANNBRAID.
      if nargin == 0, return; end
      % Pass an extra string to the constructor, representing the basepoint.
      if nargin < 2
        bsecnd = max(abs(w))+2;
      else
        bsecnd = secnd+1;
      end
      obj = obj@braidlab.braid(w,bsecnd);
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
      disp('converting annbraid to braid...')
      b = convert_to_braid(ab);
    end
  end % methods block


  methods (Access = private)

    function b = convert_to_braid(ab)

      n = ab.nann;
      idxn = find(abs(ab.word) == n);
      if isempty(idxn)
        w = ab.word;
      else
        % Sigma_n = n n n-1 n-2 ... 1 -2 -3 ... -n -n
        Sn = [n n:-1:2 1 -(2:n) -n];
        Sni = [n n:-1:2 -1 -(2:n) -n];
        if ab.word(idxn(1)) > 0
          w = [ab.word(1:idxn(1)-1) Sn];
        else
          w = [ab.word(1:idxn(1)-1) Sni];
        end
        for i = 2:length(idxn)
          w = [w ab.word(idxn(i-1)+1:idxn(i)-1)];
          if ab.word(idxn(i)) > 0
            w = [w Sn];
          else
            w = [w Sni];
          end
        end
        w = [w ab.word(idxn(end)+1:end)];
      end
      b = braidlab.braid(w,ab.n);
    end
  end % methods block

end % annbraid classdef
