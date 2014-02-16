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

import braidlab.debugmsg

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
  if b.n <= 100
    % Pre-computed spectral gap for 3 <= n <= 100.
    %
    % This is log10(abs(r(1)/r(2))), where r(1) and r(2) are the two
    % largest roots of the braid's polynomial.
    spgaps = [
      4.1179753e-01
      3.6109108e-01
      2.3605428e-01
      3.1827604e-01
      8.3003466e-02
      5.6109015e-02
      3.2443313e-02
      3.3357112e-02
      1.6610611e-02
      1.3132736e-02
      9.7237407e-03
      9.1009771e-03
      6.2032130e-03
      5.2000119e-03
      4.2062893e-03
      3.8839500e-03
      2.9862353e-03
      2.5907556e-03
      2.1976739e-03
      2.0310987e-03
      1.6649014e-03
      1.4779248e-03
      1.2917820e-03
      1.1991711e-03
      1.0225819e-03
      9.2282755e-04
      8.2342598e-04
      7.6830919e-04
      6.7289595e-04
      6.1485705e-04
      5.5698874e-04
      5.2227822e-04
      4.6628160e-04
      4.3023188e-04
      3.9427302e-04
      3.7137575e-04
      3.3637717e-04
      3.1281038e-04
      2.8929568e-04
      2.7360071e-04
      2.5061457e-04
      2.3456107e-04
      2.1853921e-04
      2.0743034e-04
      1.9171645e-04
      1.8040458e-04
      1.6911285e-04
      1.6103347e-04
      1.4992983e-04
      1.4173009e-04
      1.3354367e-04
      1.2752926e-04
      1.1946235e-04
      1.1337376e-04
      1.0729426e-04
      1.0272597e-04
      9.6725019e-05
      9.2109457e-05
      8.7500285e-05
      8.3968815e-05
      7.9412792e-05
      7.5850337e-05
      7.2292478e-05
      6.9519891e-05
      6.5998921e-05
      6.3205512e-05
      6.0415478e-05
      5.8208572e-05
      5.5444718e-05
      5.3223511e-05
      5.1004828e-05
      4.9226495e-05
      4.7026765e-05
      4.5238419e-05
      4.3451991e-05
      4.2003115e-05
      4.0230652e-05
      3.8774644e-05
      3.7320115e-05
      3.6127846e-05
      3.4683773e-05
      3.3486345e-05
      3.2290072e-05
      3.1300055e-05
      3.0111723e-05
      2.9117923e-05
      2.8125036e-05
      2.7296159e-05
      2.6309381e-05
      2.5477696e-05
      2.4646740e-05
      2.3947523e-05
      2.3121324e-05
      2.2419997e-05
      2.1719259e-05
      2.1125318e-05
      2.0428324e-05
      1.9832782e-05];
    spgap = spgaps(b.n-2);
  else
    % For n>100, use asymptotic formula.
    spgap = 8*pi^2/sqrt(3)/log(10) * b.n^-3;
  end
  % The maximum number of iterations is chosen based on the tolerance and
  % spectral gap.  Roughly, each iteration yields spgap decimal digits.
  maxit = ceil(-log10(tol) / spgap) + 10;
  debugmsg(sprintf('maxit = %d',maxit))
end

% Number of convergence criteria required to be satisfied.
% Consecutive convergence is more desirable, but becomes hard to achieve
% for low-entropy braids.
if nargin < 4, nconvreq = 3; end

% Use the lines below to help guarantee TOL.  We set the number of required
% consecutive convergences to one digit.  Not yet fully tested.
%if nargin < 4
%  if exist('spgap'), nconvreq = ceil(1/spgap); maxit = maxit + nconvreq; end
%end

% Use a fundamental group generating set as the initial multiloop.
u = braidlab.loop(b.n);

if exist('entropy_helper') == 3
  % If MEX file is available, use that.
  % Only works on double precision numbers.
  [entr,i,u.coords] = entropy_helper(b.word,u.coords,maxit,nconvreq,tol);
else
  nconv = 0; entr0 = -1;
  for i = 1:maxit
    u.coords = u.coords/norm(u.coords);  % normalize to avoid overflow
    u = b*u;
    entr = log(norm(u.coords));
    debugmsg(sprintf('  iteration %d  entr=%.10e',i,entr),2)
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
