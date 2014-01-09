function [varargout] = entropy(b,tol,maxit)
%ENTROPY   Topological entropy of a braid.
%   ENTR = ENTROPY(B) returns the topological entropy of the braid B.
%   More precisely, ENTR is the maximum growth rate of a loop under
%   iteration of B.  If the braid B labels a pseudo-Anosov isotopy class
%   on the punctured disk, then ENTR is the topological entropy of the
%   pseudo-Anosov representative.
%
%   ENTR = ENTROPY(B,TOL,MAXIT) also specifies the tolerance TOL (default
%   1e-6) and the maximum number of iterations MAXIT to try before giving up
%   (default 100).
%
%   [ENTR,LOGL] = ENTROPY(B) also returns a list LOGL of logarithmic lengths
%   for each iteration of the algorithm.
%
%   ENTR = ENTROPY(B,'trains') uses the Bestvina-Handel train-track
%   algorithm instead of the Moussafir iterative technique.  (The flags 'BH'
%   and 'train-tracks' can also be used instead of 'trains'.)  Note that
%   for long braids this algorithm becomes very inefficient.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP.MINLENGTH, LOOP.INTAXIS, BRAID.TNTYPE.

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

lenfun = @intaxis; % length function: minlength or intaxis

if istrivial(b)
  varargout{1} = 0;
  if nargout > 1
    % Only one entry for the loop lengths (initial one).
    u = braidlab.loop(b.n);
    varargout{2} = log(lenfun(u));
  end
  return
end

toldef = 1e-6;
if nargin < 2, tol = toldef; end

if ischar(tol)
  if any(strcmpi(tol,{'trains','train','train-tracks','bh'}))
    if nargout > 1
      error('BRAIDLAD:braid:entropy:nargout',...
            'Too many output arguments for ''trains'' option.')
    end
    [TN,varargout{1}] = tntype_helper(b.word,b.n);
    if strcmpi(TN,'reducible1')
      warning('BRAIDLAD:braid:entropy:reducible',...
              'Reducible braid... falling back on iterative method.')
      tol = toldef;
    else
      return
    end
  elseif any(strcmpi(tol,{'iterative','iter','dynn','dynnikov'}))
  else
    error('BRAIDLAD:braid:entropy:badarg','Unknown input option ''%s''.',tol)
  end
end

if nargin < 3
  % Empirical formula (see find_maxit).
  maxit = max(min(90*b.n-500,4100),100);
end

% Number of convergence criteria required to be satisfied.
% Consecutive convergence is more desirable, but becomes hard to achieve
% for low-entropy braids.
nconvreq = 3; consecutiveconv = true;

% Use a fundamental group generating set as the initial multiloop.
u = braidlab.loop(b.n);
entr0 = -1;
logL0 = log(lenfun(u));
if nargout > 1, logLlist = logL0; end
nconv = 0;
for i = 1:maxit
  u = b*u;
  logL = log(lenfun(u));
  entr = logL-logL0;
  % Check if we've congerved to requested tolerance.
  if abs(entr-entr0) < tol
    nconv = nconv + 1;
    if i > 10 && entr < .15 && consecutiveconv
      warning('BRAIDLAD:braid:entropy:smallentr', ...
              'Braid has small entropy; result may be inaccurate.')
      consecutiveconv = false;
    end
    % Only break if we converged nconvreq times, to prevent accidental
    % convergence.
    if nconv >= nconvreq, break; end
  elseif nconv > 0 && consecutiveconv
    % We failed to converge nconvreq times in a row: reset nconv.
    nconv = 0;
  end
  if nargout > 1, logLlist = [logLlist logL]; end
  entr0 = entr; logL0 = logL;
end

if i == maxit
  warning('BRAIDLAD:braid:entropy:noconv', ...
          ['Failed to converge to requested tolerance; braid is likely' ...
           ' finite-order or has low entropy.'])
  entr = 0;
end

varargout{1} = entr;

if nargout > 1
  varargout{2} = logLlist;
end
