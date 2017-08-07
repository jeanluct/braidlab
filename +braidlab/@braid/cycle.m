function [varargout] = cycle(b,varargin)
%CYCLE   Limit cycle of effective linear action of a braid.
%   M = CYCLE(B) finds a limit cycle for the effective linear action of B.
%   The sparse matrix M is is the product of the matrices in the limit
%   cycle.
%
%   CYCLE(B,L) uses the initial loop L (default loop(B.n,'BasePoint')) for
%   the iteration.
%
%   CYCLE(B,...,MAXIT,NCONVREQ) also specifies the maximum number of
%   iterations MAXIT (default 1000) and the number of required consecutive
%   convergences for the cycle NCONVREQ (default 5).  Either argument can be
%   replaced by [] to use its default value.
%
%   CYCLE(B,'Plot',...) makes a plot showing the convergence to the
%   matrix entries to the limit cycle.
%
%   [M,PERIOD,IT] = CYCLE(B,...) also returns the period of the cycle and
%   the number of iterations IT that were required to achieve convergence.
%
%   MI = CYCLE(B,...,'Iterates') or CYCLE(B,...,'Iter') returns a cell array
%   MI with PERIOD elements, each containing the matrix of an iterate from
%   the limit cycle.  The matrix M above is MI{PERIOD}*...*MI{1}.
%
%   The matrix M represents the asymptotic behavior of the braid action on
%   an initial loop.  In particular, its largest eigenvalue (in absolute
%   value), to the power 1/PERIOD, corresponds to the dilatation of the
%   braid if it contains at least one pseudo-Anosov component.
%
%   Example: the braid [1 2] leads to a period-3 cycle:
%
%   >> b = braid([1 2]); [M,period] = cycle(b); full(M), period
%
%   ans =
%
%        1     0     0     0
%        0     1     0     0
%        1    -1     0     0
%       -1     3     1     1
%
%   period =
%
%        3
%
%   With 'Iterates', we find the individual matrices that make up the
%   period-3 cycle:
%
%   >> MI = cycle(b,'Iterates')
%
%   MI =
%
%       [4x4 double]    [4x4 double]    [4x4 double]
%
%   The product of the three matrices gives M:
%
%   >> full(MI{3}*MI{2}*MI{1})
%
%   ans =
%
%        1     0     0     0
%        0     1     0     0
%        1    -1     0     0
%       -1     3     1     1
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP, BRAID.MTIMES.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2017  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <marko@clarkson.edu>
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

global BRAIDLAB_debuglvl

import braidlab.*
import braidlab.util.debugmsg

% Parse options.
doplot = false;
doiter = false;
iarg = [];
for i = 1:length(varargin)
  if ischar(varargin{i})
    if strcmpi(varargin{i},'plot')
      doplot = true;
      iarg = [iarg i]; %#ok<AGROW>
    elseif any(strcmpi(varargin{i},{'iterates','iter'}))
      doiter = true;
      iarg = [iarg i]; %#ok<AGROW>
    else
      error('BRAIDLAB:braid:cycle:badarg', ...
            'Unknown option ''%s''',varargin{i})
    end
  elseif isa(varargin{i},'braidlab.loop')
    braidlab.util.checkvpi
    % Get the initial loop from arguments.
    l = loop(vpi(varargin{i}.coords),'bp',varargin{i}.basepoint);
    iarg = [iarg i]; %#ok<AGROW>
  end
end
% Erase the arguments that were parsed.
for i = length(iarg):-1:1
  varargin{iarg(i)} = [];
end

% Assign default initial loop if it wasn't specified as an argument.
if ~exist('l','var')
  braidlab.util.checkvpi
  l = loop(b.n,'vpi','bp');  % include a basepoint by default
end

% Turn false convergence warning off by default.
if exist('BRAIDLAB_debuglvl','var')
  if BRAIDLAB_debuglvl >= 1
    warning('on','BRAIDLAB:braid:cycle:falseconv');
  else
    warning('off','BRAIDLAB:braid:cycle:falseconv');
  end
end

% Maximum number of iterations.
if length(varargin) < 1 || isempty(varargin{1})
  maxit = 1000;
else
  maxit = varargin{1};
end
% Number of consecutive full periods we require to declare convergence.
if length(varargin) < 2 || isempty(varargin{2})
  nconvreq = 5;
else
  nconvreq = varargin{2};
end

% Partitions of n with the largest LCM.  See issue #52.
% Mathematica: Table[Max[LCM @@ # & /@ IntegerPartitions[n]], {n, 70}]
maxperiods = [1, 2, 3, 4, 6, 6, 12, 15, 20, 30, 30, 60, 60, 84, 105, 140, ...
              210, 210, 420, 420, 420, 420, 840, 840, 1260, 1260, 1540, ...
              2310, 2520, 4620, 4620, 5460, 5460, 9240, 9240, 13860, 13860, ...
              16380, 16380, 27720, 30030, 32760, 60060, 60060, 60060, ...
              60060, 120120, 120120, 180180, 180180, 180180, 180180, 360360, ...
              360360, 360360, 360360, 471240, 510510, 556920, 1021020, ...
              1021020, 1141140, 1141140, 2042040, 2042040, 3063060, 3063060, ...
              3423420, 3423420, 6126120];

% The longest period we can detect, based on the convergence requirement and
% the maximum number of iterations.
maxperiod = floor(maxit/nconvreq);

issuewarning = false;
if b.n <= length(maxperiods)
  maxperiod = min(maxperiod,maxperiods(b.n));
  if maxperiod < maxperiods(b.n), issuewarning = true; end
end

if b.n > length(maxperiods) || issuewarning
  warning('BRAIDLAB:braid:cycle:longcycle', ...
          ['The cycle could be longer than can be detected with ' ...
           'MAXIT=%d and NCONVREQ=%d.'],maxit,nconvreq)
end

Ml = [];
nconvperiod = zeros(1,maxperiod);
converged = false;

for it = 1:maxit
  [l,M] = b*l; %#ok<RHSFN>
  Ml = [Ml ; full(M(:).')]; %#ok<AGROW>

  % Check if we appear to have reached a limit cycle.
  %
  % We need to check all periods since we can have "false convergences"
  % where we appear to converge to, say, a fixed point for a few iterates.
  % See issue #52.
  for p = 1:min(maxperiod,it-1)
    if all(Ml(end,:) == Ml(end-p,:))
      nconvperiod(p) = nconvperiod(p) + 1;
      if ~mod(nconvperiod(p),p)
        debugmsg(sprintf('Converged for %d period(s) with period %d...', ...
                         nconvperiod(p)/p,p),2)
      end
      if nconvperiod(p) >= nconvreq*p
        debugmsg(sprintf('Converged after %d iterations with period %d.', ...
                         it,p),1)
        converged = true;
        break
      end
    elseif nconvperiod(p)
      warning('BRAIDLAB:braid:cycle:falseconv', ...
              'False convergence of period %d after %d time(s)!\n', ...
              nconvperiod(p),p)
      nconvperiod(p) = 0;
    end
  end

  if converged, break; end

end

if doplot
  % Plot Ml.
  imagesc(Ml.'), colormap bone
  xlabel('iteration'), ylabel('effective linear action')
end

if it == maxit
  error('BRAIDLAB:braid:cycle:noconv', ...
        ['Failed to achieve convergence after %d iterations.' ...
         '  Try to increase MAXIT.'],it)
end

nn = sqrt(size(Ml,2));
if floor(nn) ~= nn
  error('BRAIDLAB:braid:cycle:badsize','Bad column size for iterates.');
end

% Reconstruct matrices of the linear action.
M = cell(1,p);
for i = 1:p
  M{i} = sparse(reshape(Ml(end-p+i,:),[nn nn]));
end

if ~doiter
  % Take their product.
  MM = M{1};
  for i = 2:p
    MM = M{i} * MM;
  end
  M = MM;
end

if ~doplot || nargout > 0, varargout{1} = M; end
if nargout > 1, varargout{2} = p; end
if nargout > 2, varargout{3} = it; end
