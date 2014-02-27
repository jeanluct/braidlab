function debugmsg(msg,lvl)
%DEBUGMSG   Selectively display debugging information.
%   DEBUGMSG(MSG,LVL) displays MSG if LVL is greater than or equal to the
%   global variable BRAIDLAB_debuglvl.  LVL defaults to 1 if omitted.
%
%   To turn on display debugging information from the command line:
%
%     >> global BRAIDLAB_debuglvl
%     >> BRAIDLAB_debuglvl = 1    % or higher
%

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

% Note that this function can't be private, otherwise the global
% namespace is invisible. (?)

global BRAIDLAB_debuglvl

if nargin < 1
  error('BRAIDLAB:debugmsg:nargin','Need to at least specify a message.')
end

if nargin < 2, lvl = 1; end

if exist('BRAIDLAB_debuglvl') == 1
  if BRAIDLAB_debuglvl >= lvl
    disp(msg)
  end
end
