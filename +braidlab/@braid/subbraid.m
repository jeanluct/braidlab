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
%   http://bitbucket.org/jeanluc/braidlab/
%
%   Copyright (C) 2013--2014  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                             Marko Budisic         <marko@math.wisc.edu>
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

if min(s) < 1 || max(s) > b.n
  error('BRAIDLAB:braid:subbraid:badstring', ...
        'Substring out of range.')
end

nn = length(s);

p = 1:b.n;
bs = [];
is = [];

for i = 1:length(b)
  gen = abs(b.word(i)); % unsigned generator
  i1 = find(p(gen) == s,1); i2 = find(p(gen+1) == s,1);
  if ~isempty(i1) && ~isempty(i2)
    % The current generator involves two of our substrings.
    % Find the position of all sub-strings in p.
    pos = ismember(p,s);
    % Of the substrings, find the order of the one we just switched.
    % This gives the unsigned generator for the subbraid.
    sgen = find(p(pos) == s(i1));
    % Restore sign and append to list.
    bs = [bs sign(b.word(i))*sgen]; %#ok<AGROW>
    % Optionally also keep track of which generators we kept.  This is
    % used by the subclass databraid.
    if nargout > 1, is = [is i]; end %#ok<AGROW>
  end
  p([gen gen+1]) = p([gen+1 gen]); % update permutation
end

varargout{1} = braidlab.braid(bs,nn);
if nargout > 1, varargout{2} = is; end
