function outname = validateflag( requestedname, varargin )
%%VALIDATEFLAG Match multiple strings to a single string name.
%
% V = VALIDATEFLAG( REQUESTEDNAME, FLAGNAME1, FLAGNAME1, ... )
%   compares string REQUESTEDNAME to valid flag names. Each FLAGNAMEn
%   argument is a either a string, or a cell array { FLAGNAME,
%   ALTNAME1, ALTNAME2, ... }. If REQUESTEDNAME matches a FLAGNAME or
%   any of the ALTNAME1, ALTNAME2, etc. then the output OUTNAME =
%   FLAGNAME.
%
%   If no FLAGNAMEn is matched by REQUESTEDNAME, exception
%   BRAIDLAB:validateflag:invalid is generated.
%
%   Partial matching is enabled, i.e., "tr" will match "train" and
%   "train-track". The output will be the first FLAGNAME matched.
%
%   This function is used when parsing arguments such that multiple
%   strings can have the same result.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

validateattributes( requestedname, {'char'}, {},'validateflag', ...
                    'requestedname');

outname = [];

for n = 1:length(varargin)

  % if elements of varargin are just strings, encapsulate them in cell
  if iscell(varargin{n})
    flagset = varargin{n};
  else
    flagset = {varargin{n}};
  end

  try
    validatestring(lower(requestedname),...
                   lower(flagset), 'validateflag','',n);
  catch me
    switch(me.identifier)
      case 'MATLAB:validateflag:ambiguousStringChoice'
        % good - more than one string matched - do nothing.
      case 'MATLAB:validateflag:unrecognizedStringChoice'
        % not matched - go to next iteration
        continue;
      otherwise
        % something else went wrong
        rethrow(me);
    end
  end

  % if multiple strings were matched or no error was reported
  % then set the output to desired value
  outname = flagset{1};
  break;

end

% if nothing was matched, throw the error
if isempty(outname)
  error('BRAIDLAB:validateflag:flaginvalid',...
        'Flag ''%s'' unmatched.', requestedname);
end

end