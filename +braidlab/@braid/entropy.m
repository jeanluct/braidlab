function [varargout] = entropy(b,varargin)
%ENTROPY   Topological entropy of a braid.
%   ENTR = ENTROPY(B) returns the topological entropy of the braid B.  More
%   precisely, ENTR is the maximum growth rate of a loop under iteration of
%   B.  If the braid B labels a pseudo-Anosov isotopy class on the punctured
%   disk, then ENTR is the topological entropy of the pseudo-Anosov
%   representative.  The maximum number of iterations is chosen such that if
%   the iteration fails to converge, the braid is most likely finite-order
%   and an entropy of zero is returned.
%
%   ENTR = ENTROPY(B,'Parameter',VALUE,... ) takes additional
%   parameter-value pairs that modify algorithm behavior (defaults in
%   braces).
%
%   * Method - Algorithm Choice [ 'Trains' | {'Iter'} ] Chooses between
%   Bestvina-Handel train tracks or Moussafir iterative algorithm. Note that
%   for long braids B-H algorithm becomes very inefficient.
%
%   The following options apply only to the Iterative algorithm:
%
%   * Tol - Absolute convergence tolerance [non-negative number {1e-6}]
%   Tol is only approximate: if the iteration converges slowly it can
%   be off by a small amount.
%
%   * MaxIt - Maximum # of iterations [{varies}]
%   The default is computed based on Tol and the extreme case given by
%   the small-dilatation psi braids. If Tol == 0, MaxIt has to be
%   specified as a positive number
%
%   * Length - Choice of loop length function [ 'intaxis' |
%   'minlength' | {'l2norm'} ]  See documentation of loop.intaxis,
%   loop.minlength, loop.l2norm for details.  The choice should affect
%   the output only if finite (small) number of iterations is
%   performed.  For large number of iterations, 'l2norm' should be
%   preferred for speed.
%
%   * NConv - Number of consecutive convergences [ positive {3} ]
%   Demands that the tolerance TOL be achieved NConv consecutive
%   times, rounded up to an integer.  For low-entropy braids,
%   achieving Tol a few times does not guarantee Tol digits, so
%   increasing NConv is required for extreme accuracy.
%
%   ENTR = ENTROPY(B,'OneStep',...) computes a single iteration of the
%   algorithm.  Shortcut for Tol = 0 && MaxIt = 1.
%
%   ENTR = ENTROPY(B,'Finite','MaxInt',N, ...) computes exactly N iterations
%   of the algorithm (the parameter 'MaxInt' has to be specified).
%   Identical to passing Tol = 0 and MaxInt = N.
%
%   [ENTR,PLOOP] = ENTROPY(B,...) also returns the projective loop PLOOP
%   corresponding to the generalized eigenvector.  The Dynnikov coordinates
%   are normalized such that NORM(PLOOP.COORDS) = 1.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP.MINLENGTH, LOOP.INTAXIS, BRAID.TNTYPE, PSIROOTS.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2016  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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

%% Process inputs
import braidlab.util.validateflag

parser = inputParser;

parser.addRequired('b', @(x)isa(x,'braidlab.braid') );
parser.addOptional('flag', '', @(s)ischar(s) && ...
                   ( strcmpi(s,'finite') ...
                     || strcmpi(s,'onestep') )...
                   );
parser.addParameter('tol', 1e-6, @(x)isnumeric(x) && x >= 0 );
parser.addParameter('maxit', nan, @isnumeric );

% Number of convergence criteria required to be satisfied.
% Consecutive convergence is more desirable, but becomes hard to achieve
% for low-entropy braids.
parser.addParameter('nconv', 3, @(n)isnumeric(n) && n > 0 );

% Type of algorithm
parser.addParameter('method', 'iter', @ischar);
parser.addParameter('length','l2norm',@ischar);

parser.parse( b, varargin{:} );

params = parser.Results;

% shortcut flag passed
switch params.flag
  case 'finite'
    params.tol = 0;
  case 'onestep'
    params.tol = 0;
    params.maxit = 1;
end

b = params.b;
%% 2-POINT and ZERO BRAIDS HAVE ENTROPY ZERO
if isempty(b.word) || b.n < 3
  varargout{1} = 0;
  if nargout > 1, varargout{2} = []; end
  return
end

% determine type of algorithm
params.method = validateflag(params.method, {'iter','moussafir'},...
                           {'trains','train-tracks','bh'});

params.length = validateflag(params.length, 'intaxis','minlength','l2norm');


%% TRAIN-TRACKS ALGORITHM (EXITS AFTER if)
if strcmpi( params.method, 'trains' )
  if nargout > 1
    error('BRAIDLAB:braid:entropy:nargout',...
          'Too many output arguments for ''trains'' option.')
  end
  [TN,varargout{1}] = tntype_helper(b.word,b.n);
  if strcmpi(TN,'reducible1')
    warning('BRAIDLAB:braid:entropy:reducible',...
            'Reducible braid... falling back on iterative method.')
  else
    return
  end
end

%% ITERATIVE ALGORITHM LENGTH CHOICE
switch params.length
  case 'intaxis',
    lenfun = @(l)l.intaxis;
  case 'minlength',
    lenfun = @minlength;
  case 'l2norm',
    lenfun = @l2norm;
end

%% ITERATIVE ALGORITHM: set parameters
nconvreq = ceil(params.nconv);
tol = params.tol;


% determine maximum iteration number
if isnan(params.maxit)
  if tol == 0
    error('BRAIDLAB:braid:entropy:badarg', ...
          'Must specify either tolerance>0 or maximum iterations.')
  else
    % Use the spectral gap of the lowest-entropy braid to compute the
    % maximum number of iterations.
    % The maximum number of iterations is chosen based on the tolerance and
    % spectral gap.  Roughly, each iteration yields spgap decimal digits.
    spgap = 19 * b.n^-3;
    maxit = ceil(-log10(tol) / spgap) + 30;
  end
else
  maxit = params.maxit;
end

%% ITERATIVE ALGORITHM

% Use a fundamental group generating set as the initial multiloop.
u = braidlab.loop(b.n,@double,'bp');

%% determine if mex should be attempted
global BRAIDLAB_braid_nomex
if ~exist('BRAIDLAB_braid_nomex','var') || ...
      isempty(BRAIDLAB_braid_nomex) || ...
      BRAIDLAB_braid_nomex == false
  usematlab = false;
else
  usematlab = true;
end

paramstring = sprintf(['TOL = %.1e \t MAXIT = %d \t NCONV = %d \t ' ...
                    'LENGTH = %s\n'], tol,maxit,nconvreq,params.length);

braidlab.util.debugmsg( paramstring, 1);

%% MEX implementation
if ~usematlab
  try
    % Only works on double precision numbers.
    %
    % Limited argument checking with
    % BRAIDLAB:entropy_helper:badlengthflag and
    % BRAIDLAB:entropy_helper:badarg
    % errors.
    switch( params.length )
      case 'intaxis'
        lengthflag = 0;
      case 'minlength'
        lengthflag = 1;
      case 'l2norm'
        lengthflag = 2;
    end

    [entr,i,u.coords] = entropy_helper(b.word,u.coords,...
                                       maxit,nconvreq,...
                                       tol,lengthflag, true);
    usematlab = false;
  catch me
    warning(me.identifier, [ me.message ...
                        ' Reverting to Matlab entropy'] );
    usematlab = true;
  end
end

%% MATLAB implementation
if usematlab

  nconv = 0;
  entr0 = -1;

  % discount extra arcs if intaxis is used
  switch params.length
    case 'intaxis'
      discount = b.n - 1;
    otherwise
      discount = 0;
  end

  currentLoopLength = lenfun(u) - discount;
  for i = 1:maxit

    % normalize discounting factor
    discount = discount/currentLoopLength;

    % normalize braid coordinates to avoid overflow
    u.coords = u.coords/currentLoopLength;

    % apply braid to loop
    u = b*u;

    % update loop length
    currentLoopLength = lenfun(u) - discount;

    entr = log(currentLoopLength);

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
  u.coords = u.coords/currentLoopLength;
  varargout{2} = u;
end
