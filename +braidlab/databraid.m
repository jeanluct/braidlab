%DATABRAID   Class for representing braids created from data.
%   A DATABRAID object holds a braid created from data.  Unlike the BRAID
%   class, a DATABRAID remembers the times at which particles crossed.
%
%   In addition to the data members of the BRAID class, the class DATABRAID
%   has the following data member (property):
%
%    'tcross'   vector of interpolated crossing times
%
%   A DATABRAID has access to most of the methods of BRAID, though some of
%   them work a bit differently.  See in particular DATABRAID.EQ,
%   DATABRAID.COMPACT, and DATABRAID.MTIMES.  MPOWER and MINV are undefined.
%
%   METHODS('DATABRAID') shows a list of methods.
%
%   See also DATABRAID.DATABRAID (constructor).

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

classdef databraid < braidlab.braid
  properties
    tcross            % vector of interpolated crossing times
  end

  methods

    function br = databraid(XY,secnd,third)
    %DATABRAID   Construct a databraid object.
    %   B = DATABRAID(XY) constucts a databraid from a trajectory dataset XY.
    %   The data format is XY(1:NSTEPS,1:2,1:N), where NSTEPS is the number
    %   of time steps and N is the number of particles.
    %
    %   DATABRAID(XY,T) specifies the times of the datapoints.  T defaults
    %   to 1:NSTEPS.
    %
    %   DATABRAID(XY,T,PROJANG) or DATABRAID(XY,PROJ) uses a projection line
    %   with angle PROJANG (in radians) from the X axis to determine
    %   crossings.  The default is to project onto the X axis (PROJANG = 0).
    %
    %   DATABRAID(BB,T) creates a databraid from a braid BB and crossing
    %   times T.  T defaults to [1:length(BB)].
    %
    %   DATABRAID(W,T) creates a databraid from a list of generators W and
    %   crossing times T.  T defaults to [1:length(BB)].
    %
    %   This is a method for the DATABRAID class.
    %   See also DATABRAID, BRAID, BRAID.BRAID.
      if nargin < 1
	error('BRAIDLAD:databraid:badarg','Not enough input arguments.')
      elseif isa(XY,'braidlab.braid')
	br.word = XY.word;
	br.n = XY.n;
	if nargin > 1
	  br.tcross = secnd;
	else
	  br.tcross = 1:length(br.word);
	end
	return
      elseif ndims(XY) < 3
	br.n = max(size(XY));
	br.word = reshape(XY,[1 br.n]);
	if nargin > 1
	  br.tcross = secnd;
	else
	  br.tcross = 1:length(br.word);
	end
	return
      elseif nargin < 2
	t = 1:size(XY,1);
	proj = 0;
      elseif nargin < 3
	if isscalar(secnd)
	  % The argument secnd is interpreted as a projection line angle.
	  proj = secnd;
	  t = 1:size(XY,1);
	else
	  % The argument secnd is interpreted as a list of times.
	  t = secnd;
	  proj = 0;
	end
      end
      if nargin == 3
	t = secnd;
	proj = third;
      end
      if nargin > 3
	error('BRAIDLAD:databraid:badarg','Too many input arguments.')
      end
      [b,br.tcross] = braidlab.braid.color_braiding(XY,t,proj);
      br.word = b.word;
      br.n = b.n;
    end

    function b = braid(db)
    %BRAID   Convert a DATABRAID to a BRAID.
    %   C = BRAID(B) converts the databraid B to a regular braid object B
    %   by dropping the crossing times.
    %
    %   This is a method for the DATABRAID class.
    %   See also BRAID.BRAID.
      b = braidlab.braid(db.word,db.n);
    end

    function ee = eq(b1,b2)
    %EQ   Test databraids for equality.
    %   EQ(B1,B2) or B1==B2 returns TRUE if the two databraids B1 and B2 are
    %   equal.  Equality of databraids, unlike equality of braids, is
    %   defined lexicographically.  The list of crossing times must also be
    %   identical.
    %
    %   To check if the braids themselves are equal, convert to BRAID
    %   objects before testing: EQ(BRAID(B1),BRAID(B2)).
    %
    %   This is a method for the DATABRAID class.
    %   See also BRAID.EQ, BRAID.LEXEQ.
      ee = (lexeq(braid(b1),braid(b2)) | any(b1.tcross ~= b2.tcross));
    end

    function ee = ne(b1,b2)
    %NE   Test databraids for inequality.
    %   NE(B1,B2) or B1~=B2 returns ~EQ(B1,B2).
    %
    %   This is a method for the BRAID class.
    %   See also DATABRAID.EQ.
      ee = ~(b1 == b2);
    end

    function b12 = mtimes(b1,b2)
    %MTIMES   Multiply two databraids together or act on a loop by a databraid.
    %
    %   C = B1*B2, where B1 and B2 are braid objects, return the product of
    %   the two databraids.  This is only well-defined if the crossing
    %   times of B1 are all earlier than those of B2.
    %
    %   L2 = B*L, where B is a braid and L is a loop object, returns a
    %   new loop L2 given by the action of B on L.
    %
    %   This is a method for the DATABRAID class.
    %   See also BRAID.MTIMES, DATABRAID, LOOP.
      if isa(b2,'braidlab.databraid')
	if b1.tcross(end) > b2.tcross(1)
	  error('BRAIDLAD:databraid:mtimes:notchrono',...
		'First braid must have earlier times than second.')
	end
        b12 = braidlab.databraid(...
	    braidlab.braid([b1.word b2.word],max(b1.n,b2.n)),...
	    [b1.tcross b2.tcross]);
      elseif isa(b2,'braidlab.loop')
        % Action of databraid on a loop.
	b12 = mtimes@braidlab.braid(b1,b2);
      end
    end

    function bs = subbraid(b,s)
      ;
      % Do not put comments above the first line of code, so the help
      % message from braid.subbraid is displayed.

      % Use the optional return argument ii for braid.subbraid, which gives
      % a list of the generators that were kept.
      [bb,ii] = subbraid@braidlab.braid(b,s);
      bs = braidlab.databraid(bb,b.tcross(ii));
    end

    function c = tensor(a,b)
    %TENSOR   Tensor product of two databraids.
    %   C = TENSOR(A,B) returns the tensor product of the databraids A and
    %   B, which is the braid obtained by putting A and B side-by-side, with
    %   A on the left.  The crossing times are sorted chronologically.
    %
    %   This is a method for the DATABRAID class.
    %   See also DATABRAID.
      tcr = sort([a.tcross b.tcross]);
      c = braidlab.databraid(tensor@braidlab.braid(a,b),tcr);
    end

    function c = compact(b)
    %COMPACT   Try to shorten a databraid by cancelling generators.
    %   C = COMPACT(B) attempts to shorten a databraid B by cancelling
    %   adjacent generators, and returns the shortened databraid C.  The
    %   crossing times corresponding to the cancelled generators are
    %   dropped from the TCROSS data member of C.
    %
    %   Note that DATABRAID.COMPACT is less effective than BRAID.COMPACT,
    %   since it preserves the order of generators.  It does this in order
    %   to maintain the ordering of the crossing times.
    %
    %   This is a method for the DATABRAID class.
    %   See also BRAID.COMPACT.
      c = b;

      function [cc,shorter] = canceladj(cc)
        shorter = false;

        i1 = 1:2:length(cc.word)-1;
        ic = find(cc.word(i1) == -cc.word(i1+1));
        if ~isempty(ic) shorter = true; end
        cc.word(i1(ic)) = 0; cc.word(i1(ic)+1) = 0;

        i2 = 2:2:length(cc.word)-1;
        ic = find(cc.word(i2) == -cc.word(i2+1));
        if ~isempty(ic) shorter = true; end
        cc.word(i2(ic)) = 0; cc.word(i2(ic)+1) = 0;

        i0 = find(cc.word ~= 0);
        cc.word = cc.word(i0);
        cc.tcross = cc.tcross(i0);
      end

      % Keep cancelling until nothing changes.
      shorter = true;
      while shorter
        [c,shorter] = canceladj(c);
      end
    end

  end % methods block

  % Some operations are not appropriate for databraids, since they break
  % chronology.  Hide these, though they can still be called and will
  % return an error message.
  methods (Hidden)
    function bm = mpower(b,m)
      error('BRAIDLAD:databraid:mpower:undefined',...
	    'This operation is not defined for databraids.')
    end

    function bi = inv(b)
      error('BRAIDLAD:databraid:inv:undefined',...
	    'This operation is not defined for databraids.')
    end
  end % methods block

end % databraid classdef
