function [varargout] = subbraid(b,s)
%SUBBRAID   Extract a subset of strings from a braid.
%   BS = SUBBRAID(B,S) returns the subbraid BS, obtained by discarding
%   all strings in B but the ones specified in S.  S is a vector which
%   is a subset of 1:N, where N is the number of strings in the braid.
%
%   This is a method for the BRAID class.
%   See also BRAID.

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

if isempty(s)
  error('BRAIDLAB:braid:subbraid:badstring', ...
        'Specify some substrings.')
end

% ensure input is unique and sorted
s = unique(s);

if min(s) < 1 || max(s) > b.n
  error('BRAIDLAB:braid:subbraid:badstring', ...
        'Substring out of range.')
end

%% determine if MEX implementation should be used
global BRAIDLAB_braid_nomex
if ~exist('BRAIDLAB_braid_nomex','var') || ...
      isempty(BRAIDLAB_braid_nomex) || ...
      BRAIDLAB_braid_nomex == false
  usematlab = false;
else
  usematlab = true;
end

nn = length(s);

% keeps colors of strings during permutations as integers
perm = cast(1:b.n, 'like', b.word);

% store membership of p in s, as logicals
keepstr = ismember(perm, s);

doesReturnIndex = nargout > 1;

%% MEX implementation of algorithm
if ~usematlab
  try
    if nargout > 1
      [bs, is] = subbraid_helper( b.word, perm, keepstr, doesReturnIndex );
    else
      bs = subbraid_helper( b.word, perm, keepstr, doesReturnIndex );
    end
  catch me
    warning(me.identifier, [ me.message ...
                    ' Reverting to Matlab subbraid'] );
    usematlab = true;
  end
end

%% Matlab implementation of algorithm
if usematlab
  if nargout > 1
    [bs, is] = subbraid_m( b.word, perm, keepstr, doesReturnIndex );
  else
    bs = subbraid_m( b.word, perm, keepstr, doesReturnIndex );
  end
end

varargout{1} = braidlab.braid(bs,nn);
if nargout > 1, varargout{2} = is; end


% =========================================================================
function [bs, is] = subbraid_m( word, perm, keepstr, storeind )
%% SUBBRAID_M Extract generators.

validateattributes( storeind, {'logical'}, {} );

% subbraid word
bs = cast([],'like',word);

% indices of subbraid generators in the original braid
is = cast([], 'like', word);

for i = 1:length(word)

  mygen = word(i);
  ind = abs(mygen); % generator index

  %% determine if the generator permutes strings that are kept
  if keepstr(ind) && keepstr(ind+1)
    % Of the substrings, find the order of the one we just switched.
    % This gives the unsigned generator for the subbraid.
    sgen = find(perm(keepstr) == perm(ind), 1);

    % Restore sign and append to list.
    bs = [bs sign(mygen)*sgen]; %#ok<AGROW>

    % Optionally also keep track of which generators we kept. This
    % is used by the subclass databraid.
    if storeind, is = [is i]; end %#ok<AGROW>
  end
  perm([ind ind+1]) = perm([ind+1 ind]); % update permutation
  keepstr([ind ind+1]) = keepstr([ind+1 ind]); % update membership permutation
end
