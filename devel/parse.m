function parse(varargin)

% stage parsing for loop.plot.
% started with arrow.m

% 'PuncturePositions'
% 'PunctureRadius'
% 'PunctureColor'
% 'LoopColor' (alias to 'Color'?)
% pass remaining properties as options to plot.

% Find first property number
%firstprop = nargin+1;
%for k = 1:length(varargin)
%  if ~isnumeric(varargin{k}), firstprop = k; break; end;
%end
%lastnumeric = firstprop-1;
firstprop = 1;

% Check property list
if firstprop <= nargin
  for k = firstprop:2:nargin
    curarg = varargin{k};
    if ~isstr(curarg) | sum(size(curarg) > 1) > 1
      error([upper(mfilename) ' requires that a property name be a single string.']);
    end
  end
  if rem(nargin - firstprop,2) ~= 1
    error([upper(mfilename) ' requires that the property ''' ...
	   varargin{nargin} ''' be paired with a property value.']);
  end
end

% Parse property pairs.
extraprops = {};
for k = firstprop:2:nargin,
  prop = varargin{k};
  val  = varargin{k+1};
  prop = lower(prop(:)') '      '];
  if     strcmp(prop,'punctureposition'),   start      = val;
  elseif strncmp(prop,'stop'  ,4),   stop       = val;
  elseif strncmp(prop,'len'   ,3),   len        = val(:);
  elseif strncmp(prop,'base'  ,4),   baseangle  = val(:);
  elseif strncmp(prop,'tip'   ,3),   tipangle   = val(:);
  elseif strncmp(prop,'wid'   ,3),   wid        = val(:);
  elseif strncmp(prop,'page'  ,4),   page       = val;
  elseif strncmp(prop,'cross' ,5),   crossdir   = val;
  elseif strncmp(prop,'norm'  ,4),   if (isstr(val)), crossdir=val; else, crossdir=val*sqrt(-1); end;
  elseif strncmp(prop,'end'   ,3),   ends       = val;
  elseif strncmp(prop,'object',6),   oldh       = val(:);
  elseif strncmp(prop,'handle',6),   oldh       = val(:);
  elseif strncmp(prop,'type'  ,4),   ispatch    = val;
  elseif strncmp(prop,'userd' ,5),   %ignore it
  else,
    % make sure it is a valid patch or line property
    try
      get(0,['DefaultPatch' varargin{k}]);
    catch
      errstr = lasterr;
      try
	get(0,['DefaultLine' varargin{k}]);
      catch
	errstr(1:max(find(errstr==char(13)|errstr==char(10)))) = '';
	error([upper(mfilename) ' got ' errstr]);
      end
    end;
    extraprops={extraprops{:},varargin{k},val};
  end;
end;

% Check if we got 'default' values
start     = arrow_defcheck(start    ,defstart    ,'Start'        );
stop      = arrow_defcheck(stop     ,defstop     ,'Stop'         );
len       = arrow_defcheck(len      ,deflen      ,'Length'       );
baseangle = arrow_defcheck(baseangle,defbaseangle,'BaseAngle'    );
tipangle  = arrow_defcheck(tipangle ,deftipangle ,'TipAngle'     );
wid       = arrow_defcheck(wid      ,defwid      ,'Width'        );
crossdir  = arrow_defcheck(crossdir ,defcrossdir ,'CrossDir'     );
page      = arrow_defcheck(page     ,defpage     ,'Page'         );
ends      = arrow_defcheck(ends     ,defends     ,''             );
oldh      = arrow_defcheck(oldh     ,[]          ,'ObjectHandles');
ispatch   = arrow_defcheck(ispatch  ,defispatch  ,''             );
