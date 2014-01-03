%DATABRAID   Class for representing braids created from data.
%   A DATABRAID object holds a braid created from data.  Unlike the BRAID
%   class, a DATABRAID remembers the times at which particles crossed.
%
%   In addition to the data members of the BRAID class, the class DATABRAID
%   has the following data members:
%
%    'tcross'   vector of interpolated crossing times
%
%   A DATABRAID has access to all the methods of BRAID, except COMPACT,
%   since compacting the generators makes the crossing times undefined.
%
%   METHODS('DATABRAID') shows a list of methods.
%
%   See also DATABRAID.DATABRAID (constructor).

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
    %   This is a method for the DATABRAID class.
    %   See also DATABRAID, BRAID, BRAID.BRAID.
      if nargin < 1
          error('BRAIDLAD:databraid:badarg','Not enough input arguments.')
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

  end % methods block

end % databraid classdef
