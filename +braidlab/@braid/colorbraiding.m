function [varargout] = colorbraiding(XY,t,proj)
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
%   See also BRAID, BRAID.BRAID, DATABRAID, DATABRAID.DATABRAID.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
%                        Michael Allshouse <mallshouse@chaos.utexas.edu>
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

% set to true to use Matlab instead of C++ version of the algorithm
global BRAIDLAB_braid_nomex
useMatlabVersion = (exist('BRAIDLAB_braid_nomex','var') && ...
                    ~isempty(BRAIDLAB_braid_nomex) && ...
                    all(BRAIDLAB_braid_nomex));

if any(isnan(XY) | isinf(XY))
  error('BRAIDLAB:braid:colorbraiding:badarg',...
        'Data contains NaNs or Infs.')
end

debugmsg(['colorbraiding Part 1: Initialize parameters for crossing' ...
          ' analysis']);
tic
n = size(XY,3); % number of punctures

if nargin < 3
  % Default projection line is X axis.
  proj = 0;
end

% Rotate coordinates according to angle proj.  Note that since the
% projection line is supposed to be rotated counterclockwise by proj, we
% rotate the data clockwise by proj.
if proj ~= 0, XY = rotate_data_clockwise(XY,proj); end

% Sort the initial conditions from left to right according to their initial
% X coord; IDX contains the indices of the sort.
[~,idx] = sortrows(squeeze(XY(1,:,:)).');
% Sort all the trajectories trajectories according to IDX:
XYtraj = XY(:,:,idx);

debugmsg(sprintf('colorbraiding Part 1: took %f msec',toc*1000));

% Convert the physical braid to the list of braid generators (gen).
% tcr - times of generator occurrence

try % trapping to ensure proper identification of strands
  
  try % trapping to switch between MEX and Matlab versions
    assert(~useMatlabVersion, 'BRAIDLAB:noMEX', 'Matlab version forced');

    %% C++ version of the algorithm
    Nthreads = getAvailableThreadNumber(); % defined at the end
    [gen,tcr] = cross2gen_helper(XYtraj,t,Nthreads);

  catch me
    if ~strcmpi(me.identifier, 'BRAIDLAB:NOMEX')
      rethrow(me);
    else
      %% MATLAB version of the algorithm
      [gen,tcr,~] = cross2gen(XYtraj,t);
    end
  end

catch me
  
  % Identify particles causing the error using IDX vector
  % and re-throw the error with appropriate reporting
  switch(me.identifier)
    case 'BRAIDLAB:braid:colorbraiding:coincidentparticles'
      
      localPair = eval(me.message);
      sortedPair = idx(localPair);

      error(me.identifier, ...
            ['Paths of particles %d and %d intersect.  The braid cannot' ...
             ' be formed.'],sortedPair(1),sortedPair(2));

    case 'BRAIDLAB:braid:colorbraiding:coincidentprojection'

      localPair = eval(me.message);
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

% =========================================================================
function XYr = rotate_data_clockwise(XY,proj)

XYr = zeros(size(XY));
XYr(:,1,:) =  cos(proj)*XY(:,1,:) + sin(proj)*XY(:,2,:);
XYr(:,2,:) = -sin(proj)*XY(:,1,:) + cos(proj)*XY(:,2,:);


% =========================================================================
function Nthreads = getAvailableThreadNumber
%%GETAVAILABLETHREADNUMBER
%
% Determines number of threads used in C++ code.
%
% - First tries to honor global BRAIDLAB_threads.
% - If it is invalid/not available, tries to set number of threads to number
% of available cores.
% - If number of cores cannot be detected, defaults to one thread.

import braidlab.util.debugmsg
global BRAIDLAB_threads

if ~(isempty(BRAIDLAB_threads) || BRAIDLAB_threads <= 0)
  % use the global variable to set the number of threads
  Nthreads = ceil(BRAIDLAB_threads);
  debugmsg(sprintf(['colorbraiding: Number of threads set by ' ... 
                    'BRAIDLAB_threads to: %d.'],Nthreads));
else
  % try to autodetect the optimal number of threads (== number of cores)
  try
    import java.lang.Runtime;
    r=Runtime.getRuntime;
    Nthreads=r.availableProcessors;

    debugmsg(sprintf(['Number of threads auto-set to %d using ' ...
                      'java.lang.Runtime.'], Nthreads));
    % 'feature' fails - auto set number of threads to 1
  catch
    Nthreads = 1;
    warning('BRAIDLAB:braid:colorbraiding:autosetthreadsfails', ...
            ['Number of processor cores cannot be detected. Number of ' ...
             'threads set to 1.'])
  end
end
