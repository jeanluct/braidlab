function Nthreads = getAvailableThreadNumber
%%GETAVAILABLETHREADNUMBER
%
% Determines number of threads available, e.g., for use in C++ code.
%
% - First tries to honor global BRAIDLAB_threads.
% - If it is invalid/not available, tries to set number of threads to number
% of available cores.
% - If number of cores cannot be detected, defaults to one thread.
%
% The number of threads is a persistent variable, i.e., it is computed only
% once per MATLAB session. To re-compute the number of threads, run
% >> clear getAvailableThreadNumber

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
global BRAIDLAB_threads
persistent ComputedThreads

if ~isempty(ComputedThreads)
  debugmsg(sprintf(['Previously set ComputedThreads=%d.' ...
                    ' Run ''clear getAvailableThreadNumber'' ',...
                    ' to recompute'],ComputedThreads),2);
else
  if ~(isempty(BRAIDLAB_threads) || BRAIDLAB_threads <= 0)
    % use the global variable to set the number of threads
    ComputedThreads = ceil(BRAIDLAB_threads);
    debugmsg(sprintf(['getAvailableThreadNumber: Number of threads set by ' ...
                      'BRAIDLAB_threads to: %d.'],ComputedThreads));
  else
    % try to autodetect the optimal number of threads (== number of cores)
    try
      import java.lang.Runtime;
      r=Runtime.getRuntime;
      ComputedThreads=r.availableProcessors;

      debugmsg(sprintf(['Number of threads auto-set to %d using ' ...
                        'java.lang.Runtime.'], ComputedThreads));
      % 'feature' fails - auto set number of threads to 1
    catch
      ComputedThreads = 1;
      warning('BRAIDLAB:util:getAvailableThreadNumber:autosetthreadsfails', ...
              ['Number of processor cores cannot be detected. Number of ' ...
               'threads set to 1.'])
    end
  end
end

Nthreads = ComputedThreads;
