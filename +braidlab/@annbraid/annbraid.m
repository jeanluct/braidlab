%ANNBRAID   Class for representing braids on the annulus.
%   An ANNBRAID object holds a braid defined on an annular domain.
%
%   In addition to the data members of the BRAID class, the class ANNBRAID
%   has the dependent property
%
%    'nann'     the number of annular strings, not counting the basepoint
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
    %   BC = ANNBRAID(B) copies the object B of type ANNBRAID or BRAID to
    %   the ANNBRAID object BC.  An annbraid is created from a
    %   braid by adding a basepoint puncture.
    %
    %   B = ANNBRAID('Random',NANN,K) returns a random braid of NANN strings
    %   with K crossings (generators).  The K generators are chosen
    %   uniformly in [-NANN:-1 1:NANN].
    %
    %   This is a method for the ANNBRAID class.
    %   See also ANNBRAID, BRAID.

      if nargin > 0
        if isa(varargin{1},'braidlab.braid')
          % Create an annbraid from a braid by appending a basepoint.
          varargin{2} = varargin{1}.n+1;
          varargin{1} = varargin{1}.word;
        elseif max(size(size(varargin{1}))) == 3
          % Create braid from data.
          error('Creating an annbraid from data is not implemented yet.')
        elseif ischar(varargin{1})
          switch lower(varargin{1})
           case 'random'
            % Pass an extra string to the constructor, representing the
            % basepoint.
            varargin{2} = varargin{2}+1;
           otherwise
            error('BRAIDLAB:annbraid:annbraid', ...
                  'String argument ''%s'' not supported for annbraid.', ...
                  varargin{1})
          end
        else
          % Numerical first argument.
          % Pass an extra string to the constructor, representing the basepoint.
          if nargin > 1
            varargin{2} = varargin{2}+1;
          elseif isempty(varargin{1})
            % Empty first argument with no second argument creates
            % trivial braid, as if there were no arguments.
            varargin{2} = 2;
          end
        end
      else
        % Create a trivial braid with one string and one basepoint.
        varargin{1} = [];
        varargin{2} = 2;
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
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      if isa(b2,'braidlab.annbraid')
        % If b2 is also an annular braid, the product is simple concatenation.
        varargout{1} = braidlab.annbraid(mtimes@braidlab.braid(b1,b2));
      elseif isa(b2,'braidlab.braid')
        % If b2 is a braid, return a plain braidlab.braid.
        varargout{1} = mtimes@braidlab.braid(b1.braid,b2);
      elseif isa(b2,'braidlab.loop')
        if b2.basepoint < b1.n
          error('BRAIDLAB:annbraid:mtimes', ...
                'Annular braid can only act on a loop with a basepoint.')
        end
        [varargout{1:nargout}] = mtimes@braidlab.braid(b1.braid,b2);
      end
    end

    function bm = mpower(b,m)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      bm = braidlab.annbraid(mpower@braidlab.braid(b,m));
    end

    function bi = inv(b)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      bi = braidlab.annbraid(inv@braidlab.braid(b));
    end

    function p = perm(obj)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      p = perm@braidlab.braid(obj.braid);

      if p(end) ~= length(p)
        error('BRAIDLAB:annbraid:badperm', ...
              'Basepoint should not move.')
      end
      % Drop the last entry: ignore basepoint in the permutation.
      p(end) = [];
    end

    function wr = writhe(obj)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      % Convert the annbraid to a braid first, to include the basepoint.
      wr = writhe@braidlab.braid(obj.braid);
    end

    function str = char(b)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      str = char@braidlab.braid(b);
      % Append an asterisk: same notation as for basepoint.
      str = [str '*'];
    end

    function p = alexpoly(b,varargin)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      p = alexpoly@braidlab.braid(b.braid,varargin{:});
    end

    function m = burau(b,varargin)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      m = burau@braidlab.braid(b.braid,varargin{:});
    end

    function c = compact(b)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      % Note here we do *not* convert to a braidlab.braid first.
      c = braidlab.annbraid(compact@braidlab.braid(b));
    end

    function [c,bE] = complexity(b,varargin)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      [c,bE] = complexity@braidlab.braid(b.braid,varargin{:});
    end

    function [varargout] = conjtest(b1,b2)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      varargout{1:nargout} = conjtest@braidlab.braid(b1.braid,b2.braid);
    end

    function [varargout] = cycle(b,varargin)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      varargout{1:nargout} = cycle@braidlab.braid(b.braid,varargin{:});
    end

    function [varargout] = entropy(b,varargin)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      varargout{1:nargout} = entropy@braidlab.braid(b.braid,varargin{:});
    end

    function l = loopcoords(b,varargin)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      l = loopcoords@braidlab.braid(b.braid,varargin{:});
    end

    function plot(b,varargin)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      % This isn't a great way to plot.  Would be better to highlight the
      % boundary puncture with a different color.
      plot@braidlab.braid(b.braid,varargin{:});
    end

    function l = reducing(b,varargin)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      % Maybe should convert to a curve with a basepoint.
      l = reducing@braidlab.braid(b.braid,varargin{:});
    end

    function [varargout] = tntype(b)
      ; %#ok<NOSEM>
      % Do not put comments above the first line of code, so the help
      % message from braid superclass is displayed.

      varargout{1:nargout} = tntype@braidlab.braid(b.braid);
    end

  end % methods block


  % Some operations are not appropriate for annbraids, since they break
  % chronology.  Hide these, though they can still be called and will
  % return an error message.
  methods (Hidden)
    function tensor(~)
      error('BRAIDLAB:databraid:tensor:undefined',...
            'This operation is not yet implemented for databraids.')
    end

    function subbraid(~)
      error('BRAIDLAB:databraid:subbraid:undefined',...
            'This operation is not yet implemented for databraids.')
    end
  end % methods block

end % annbraid classdef
