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
