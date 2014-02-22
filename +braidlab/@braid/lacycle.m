function [varargout] = lacycle(b,maxit,nconvreq)
%LACYCLE   Find limit cycle of effective linear action of a braid.
%   PN = LACYCLE(B) finds a limit cycle for the effective linear action
%   of B on the starting loop loop(B.n).  The output matrix PN has
%   dimension [PERIOD 5*B.n].  It contains the signs of the pos/neg
%   operators in the piecewise-linear action given by BRAID.MTIMES.
%
%   LACYCLE(B,MAXIT,NCONVREQ) also specifies the maximum number of
%   iterations MAXIT (default 1000) and the number of required consecutive
%   convergences for the cycle NCONVREQ (default 5).
%
%   [PN,IT] = LACYCLE(...) also returns the number of iterations IT that
%   were required to achieve convergence.
%
%   To reconstruct the matrix for iterate J of the limit cycle, use
%   BRAID.LINACT:
%
%   Example: the braid [1 2] leads to a period-3 cycle:
%
%   >> b = braid([1 2]); pn = lacycle(b)
%
%   pn =
%       -1     1     1     1     0    -1     0     0     0     1
%        0     1     1     1     0    -1     0    -1     0     1
%       -1     1     0     0     0    -1     0    -1     0     1
%
%   Matrix corresponding to the first iterate:
%
%   >> full(linact(b,pn(1,:)))
%
%   ans =
%
%        0     0    -1     0
%        0     1     0     0
%        1    -1    -1     0
%        0     1     1     1
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP, BRAID.MTIMES, BRAID.LINACT.

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


import braidlab.*

% Turn false convergence warning off, unless explicitly set to on.
w = warning('query','BRAIDLAB:braid:lacycle:falseconv');
if ~strcmpi(w.state,'on')
  warning('off','BRAIDLAB:braid:lacycle:falseconv');
end

% Maximum number of iterations.
if nargin < 2, maxit = 1000; end
% Number of consecutive full periods we require to declare convergence.
if nargin < 3, nconvreq = 5; end

l = loop(b.n,'vpi');

nconv = 0;
pnl = [];

for it = 1:maxit
  [l,pn] = b*l;
  pnl = [pnl ; pn];
  if nconv == 0
    % Check if we appear to have reached a limit cycle.
    for p = 1:it-1
      if all(pnl(end,:) == pnl(end-p,:))
        period = p;
        nconv = 1;
        break;
      end
    end
  else
    % Are we still in the same limit cycle?
    if all(pnl(end,:) == pnl(end-period,:))
      nconv = nconv + 1;
      if ~mod(nconv,period)
        debugmsg(sprintf('Converged for %d period(s)...',nconv/period),2)
      end
      if nconv >= nconvreq*period
        debugmsg(sprintf('Converged after %d iterations with period %d.', ...
                         it,period),1)
        break
      end
    else
      warning('BRAIDLAB:braid:lacycle:falseconv', ...
              'False convergence after %d time(s)!\n',nconv)
      nconv = 0;
    end
  end
end

if it == maxit
  varargout{1} = [];
  warning('BRAIDLAB:braid:lacycle:noconv', ...
          ['Failed to achieve convergence after %d iterations.' ...
           '  Try to increase MAXIT.'],it)
else
  % Plot pn signs.
  %imagesc(pnl.'), colormap bone
  %xlabel('iteration'), ylabel('pos / neg')

  % Save the cycle.
  varargout{1} = pnl(end-period+1:end,:);
end

if nargout > 1, varargout{2} = it; end
