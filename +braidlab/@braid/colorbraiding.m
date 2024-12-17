function [varargout] = colorbraiding(XY,t,proj,checkclosure)
%COLORBRAIDING   Find braid generators from trajectories using colored braids.
%   B = COLORBRAIDING(XY,T) takes the inputs XY (the trajectory set) and T
%   (vector of times) and calculates the corresponding braid B via a color
%   braiding method.
%
%   The color braiding method takes pairs of strings and finds the crossings
%   that occur between the two.  This is done for all pairs, and then the
%   crossings for each pair are converted to generators.
%
%   [B,TCR] = COLORBRAIDING(XY,T) also returns the time of crossing (TCR).
%
%   The projection line angle PROJANG can be specified as an optional
%   third argument (default 0).
%
%   When two strands project onto the same point at any time instance, it
%   is not generally possible to robustly determine their identities. In
%   such events, the function issues the error
%   BRAIDLAB:braid:colorbraiding:coincidentprojection
%   identifying the offending pair of strands. To resolve this issue,
%   either change the PROJANG parameter or reduce the value of the braidlab
%   parameter BraidAbsTol using braidlab.prop('BraidAbsTol', VALUE) command.
%
%   COLORBRAIDING is a protected static method of the BRAID class.  It
%   is also used by the DATABRAID subclass.
%
%   ** Implementation: ** By default, the function invokes a C++
%   implementation of the algorithm from file cross2gen_helper.cpp. To use a
%   slower, MATLAB implementation, set a global MATLAB variable
%   BRAIDLAB_braid_nomex to true. A comparison between MATLAB and C++
%   versions of the algorithm can be run by executing
%   braidlab/devel/test_colorbraid.m
%
%   When MATLAB version is used, code issues the warning
%   BRAIDLAB:braid:colorbraiding:matlab
%
%   The C++ version of the code additionally tries to run in a
%   multi-threaded mode, using as many threads as available to Matlab. If
%   you want to manually set the number of threads used, set a global MATLAB
%   variable BRAIDLAB_threads to a positive integer.
%
%   See also BRAID, BRAID.BRAID, DATABRAID, DATABRAID.DATABRAID, BRAIDLAB.PROP

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
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
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

import braidlab.util.debugmsg
import braidlab.util.getAvailableThreadNumber

% set to true to use Matlab instead of C++ version of the algorithm
global BRAIDLAB_braid_nomex;
useMatlabVersion = any(BRAIDLAB_braid_nomex);

if any(isnan(XY) | isinf(XY))
  error('BRAIDLAB:braid:colorbraiding:badarg',...
        'Data contains NaNs or Infs.')
end

validateattributes(t,{'numeric'},...
                   {'real','finite','vector','increasing','nonnan'},...
                   'BRAIDLAB.braid.colorbraiding','t',2 );

validateattributes(XY,{'numeric'},...
                   {'real','finite','nonnan','nrows',numel(t)},...
                   'BRAIDLAB.braid.colorbraiding','XY',1 );

validateattributes(proj,{'numeric'},...
                   {'real','finite','scalar','nonnan','nonempty'},...
                   'BRAIDLAB.braid.colorbraiding','proj',3 );

debugmsg(['colorbraiding: Initialize parameters for crossing analysis'],2);
tic
n = size(XY,3); % number of punctures

if nargin < 3
  % Default projection line is X axis.
  proj = 0;
end

delta = braidlab.prop('BraidAbsTol');

% Rotate coordinates according to angle proj.  Note that since the
% projection line is supposed to be rotated counterclockwise by proj, we
% rotate the data clockwise by proj.
if proj ~= 0, XY = rotate_data_clockwise(XY,proj); end

% Sort the initial conditions from left to right according to their initial
% X coord; IDX contains the indices of the sort.
[~,idx] = sortrows(squeeze(XY(1,:,:)).');
% Sort all the trajectories trajectories according to IDX:
XY = XY(:,:,idx);

if checkclosure
  % Check if the final points are close enough to the initial points (setwise).
  % Otherwise this could be an error with the user's data.
  % Suggest user call 'closure(XY)' first.

  % Use optimal assignment to match the ends.
  % This piece of code is basically pasted from closure.m.
  XY0 = squeeze(XY(1,:,:));
  XY1 = sortrows(squeeze(XY(end,:,:))')';
  % Create matrix of distances.
  D = zeros(n,n);
  for i = 1:n
    for j = 1:n
      D(i,j) = norm(XY1(:,i)-XY0(:,j));
    end
  end
  % Solve the optimal assignment problem.
  perm = braidlab.util.assignmentoptimal(D);

  if any(sqrt(sum((XY0(:,perm) - XY1).^2,1)) > delta)
    warning('BRAIDLAB:braid:colorbraiding:notclosed',...
            ['The trajectories do not form a closed braid.  ' ...
             'Consider calling ''closure'' on the data first.']);
  end
end

debugmsg(sprintf('colorbraiding: initialization took %f msec',toc*1000),2);

% Convert the physical braid to the list of braid generators (gen).
% tcr - times of generator occurrence

try % trapping to ensure proper identification of strands

  try % trapping to switch between MEX and Matlab versions
    assert(~useMatlabVersion, 'BRAIDLAB:NOMEX', ['Matlab version ' ...
                        'forced']);

    debugmsg('Using MEX algorithm',2)

    %% C++ version of the algorithm
    Nthreads = getAvailableThreadNumber(); % defined at the end
    [gen,tcr] = cross2gen_helper(XY,t,delta,Nthreads);

  catch me
    if isempty( regexpi(me.identifier, 'BRAIDLAB:NOMEX') )
      rethrow(me);
    else
    debugmsg('Using MATLAB algorithm',2)
      %% MATLAB version of the algorithm
      [gen,tcr,~] = cross2gen(XY,t,delta);
    end
  end

catch me

  % Identify particles causing the error using IDX vector
  % and re-throw the error with appropriate reporting
  switch(me.identifier)
    case 'BRAIDLAB:braid:colorbraiding:coincidentparticles'

      % strtok splits the [ ind, ind ] part of the string
      % and text explanation of what happened
      localPair = eval(strtok(me.message,'|'));
      sortedPair = idx(localPair);

      error(me.identifier, ...
            ['Paths of particles %d and %d intersect.  The braid cannot' ...
             ' be formed.'],sortedPair(1),sortedPair(2));

    case 'BRAIDLAB:braid:colorbraiding:coincidentprojection'

      % strtok splits the [ ind, ind ] part of the string
      % and text explanation of what happened
      localPair = eval(strtok(me.message,'|'));
      sortedPair = idx(localPair);

      error(me.identifier, ...
            ['Paths of particles %d and %d have a coincident projection.' ...
             '  Try changing the projection angle.'], ...
            sortedPair(1),sortedPair(2));
    otherwise
      rethrow(me)
  end
end

varargout{1} = braidlab.braid(gen,n);
if nargout > 1, varargout{2} = tcr; end
