function [varargout] = entropy(b,tol,maxit,nconvreq)
%ENTROPY   Topological entropy of a braid.
%   ENTR = ENTROPY(B) returns the topological entropy of the braid B.  More
%   precisely, ENTR is the maximum growth rate of a loop under iteration of
%   B.  If the braid B labels a pseudo-Anosov isotopy class on the punctured
%   disk, then ENTR is the topological entropy of the pseudo-Anosov
%   representative.  The maximum number of iterations is chosen such that if
%   the iteration fails to converge, the braid is most likely finite-order
%   and an entropy of zero is returned.
%
%   ENTR = ENTROPY(B,TOL) also specifies the absolute tolerance TOL (default
%   1e-6) that should be aimed for.  TOL is only approximate: if the
%   iteration converges slowly it can be off by a small amount.
%
%   ENTR = ENTROPY(B,TOL,MAXIT) also specifies the maximum number of
%   iterations MAXIT to try before giving up.  The default is computed based
%   on TOL and the extreme case given by the small-dilatation psi braids.
%
%   ENTR = ENTROPY(B,[],MAXIT) or ENTROPY(B,0,MAXIT) uses a tolerance of
%   zero, which means that exactly MAXIT iterations are performed and
%   convergence is not checked for.  The final value of the entropy at
%   the end of iteration is returned.
%
%   Note that the "length" of the loop is not computed using LOOP.MINLENGTH
%   or LOOP.INTAXIS.  Rather, the L^2 norm of the Dynnikov coordinates is
%   used.  This is more expedient and doesn't change the growth rate, but
%   may lead to differences between BRAID.ENTROPY and the normalized output
%   of BRAID.COMPLEXITY when a small number of iterations is used.
%
%   ENTR = ENTROPY(B,TOL,MAXIT,NCONV) or ENTROPY(B,TOL,[],NCONV) demands
%   that the tolerance TOL be achieved NCONV consecutive times (default 3).
%   For low-entropy braids, achieving TOL a few times does not guarantee TOL
%   digits, so increasing NCONV is required for extreme accuracy.
%
%   [ENTR,PLOOP] = ENTROPY(B,...) also returns the projective loop PLOOP
%   corresponding to the generalized eigenvector.  The Dynnikov coordinates
%   are normalized such that NORM(PLOOP.COORDS)=1.
%
%   ENTR = ENTROPY(B,'trains') uses the Bestvina-Handel train-track
%   algorithm instead of the Moussafir iterative technique.  (The flags 'BH'
%   and 'train-tracks' can also be used instead of 'trains'.)  Note that
%   for long braids this algorithm becomes very inefficient.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP.MINLENGTH, LOOP.INTAXIS, BRAID.TNTYPE, PSIROOTS.

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

import braidlab.util.debugmsg

if isempty(b.word) || b.n < 3
  varargout{1} = 0;
  if nargout > 1, varargout{2} = []; end
  return
end

toldef = 1e-6;
if nargin < 2, tol = toldef; end

if ischar(tol)
  if any(strcmpi(tol,{'trains','train','train-tracks','bh'}))
    if nargout > 1
      error('BRAIDLAB:braid:entropy:nargout',...
            'Too many output arguments for ''trains'' option.')
    end
    [TN,varargout{1}] = tntype_helper(b.word,b.n);
    if strcmpi(TN,'reducible1')
      warning('BRAIDLAB:braid:entropy:reducible',...
              'Reducible braid... falling back on iterative method.')
      tol = toldef;
    else
      return
    end
  elseif any(strcmpi(tol,{'iterative','iter','dynn','dynnikov'}))
  else
    error('BRAIDLAB:braid:entropy:badarg','Unknown input option ''%s''.',tol)
  end
end

if isempty(tol), tol = 0; end

if nargin < 3 || isempty(maxit)
  if tol == 0
    error('BRAIDLAB:braid:entropy:badarg', ...
          'Must specify tolerance>0 or maximum iterations.')
  end
  % Use the spectral gap of the lowest-entropy braid to compute the
  % maximum number of iterations.
  % The maximum number of iterations is chosen based on the tolerance and
  % spectral gap.  Roughly, each iteration yields spgap decimal digits.
  spgap = 19 * b.n^-3;
  maxit = ceil(-log10(tol) / spgap) + 30;
  debugmsg(sprintf('maxit = %d',maxit))
end

% Number of convergence criteria required to be satisfied.
% Consecutive convergence is more desirable, but becomes hard to achieve
% for low-entropy braids.
if nargin < 4, nconvreq = 3; end

% Use a fundamental group generating set as the initial multiloop.
u = braidlab.loop(b.n,@double);

if exist('entropy_helper','file') == 3
  % If MEX file is available, use that.
  % Only works on double precision numbers.
  [entr,i,u.coords] = entropy_helper(b.word,u.coords,maxit,nconvreq,tol);
else
  nconv = 0; entr0 = -1;
  for i = 1:maxit
    u.coords = u.coords/norm(u.coords);  % normalize to avoid overflow
    u = b*u;
    entr = log(norm(u.coords));
    debugmsg(sprintf('  iteration %d  entr=%.10e  diff=%.4e',...
		     i,entr,entr-entr0),2)
    % Check if we've converged to requested tolerance.
    if abs(entr-entr0) < tol
      nconv = nconv + 1;
      % Only break if we converged nconvreq times, to prevent accidental
      % convergence.
      if nconv >= nconvreq
        break;
      end
    elseif nconv > 0
      % We failed to converge nconvreq times in a row: reset nconv.
      debugmsg(sprintf('Converged %d time(s) in a row (< %d)',nconv,nconvreq))
      nconv = 0;
    end
    entr0 = entr;
  end
end

if tol > 0 % If tolerance is 0, we never expected convergence.
  if i >= maxit
    warning('BRAIDLAB:braid:entropy:noconv', ...
            ['Failed to converge to requested tolerance; braid is likely' ...
             ' finite-order or has low entropy.  Returning zero entropy.'])
    entr = 0;
  else
    debugmsg(sprintf(['Converged %d time(s) in a row after ' ...
                      '%d iterations'],nconvreq,i))
  end
end

varargout{1} = entr;

if nargout > 1
  u.coords = u.coords/norm(u.coords);
  varargout{2} = u;
end
