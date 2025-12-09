function linecount_plot(ptype)

if nargin < 1, ptype = 'rev'; end

fid = fopen('linecount.dat','rt');
dat = textscan(fid, '%s %d %d', 'HeaderLines', 0, 'CollectOutput', false);
fclose(fid);

revhash = dat{1};
utc = dat{2};
lc = dat{3};

rev = 1:length(revhash);

% Convert Unix time to datenum.
dnum = utc/86400 + datenum(1970,1,1);

fig = figure;

switch lower(ptype)
 case {'date','time'}
  plot(dnum,lc,'.-')
  datetick('x','mmm yy','keepticks')
  xlabel('date (UTC)')
  ylabel('# lines')
 case {'rev','revision'}
  plot(rev,lc,'.-')
  xlabel('revision')
  ylabel('# lines')
 otherwise
end

gl = @(x,y) gitlog(x,y,revhash);

% Display clickable tooltips for each datapoint, showing log message.
dcm_obj = datacursormode(fig);
set(dcm_obj,'DisplayStyle','window','SnapToDataVertex','on',...
            'Enable','on','UpdateFcn',gl)


% ==================================================================
function txt = gitlog(~,event_obj,revhash)

pos = get(event_obj,'Position');

[~,shell] = system('echo $0');
if ~isempty(findstr(shell,'bash'))
  termset = 'export TERM=ansi';
elseif ~isempty(findstr(shell,'tcsh'))
  termset = 'setenv TERM ansi';
else
  error('Unknown shell.')
end

gitcmd0 = 'git log -1 --pretty=format:''%h: %s''';

if pos(1) > 5e5
  % pos(1) is most likely a datenum date, not a revision number.
  % Convert datenum to UTC.
  utc = int32(86400*(pos(1) - datenum(1970,1,1)));
  gitcmd = sprintf('%s --before="%d"',gitcmd0,utc);
else
  gitcmd = sprintf('%s %s',gitcmd0,revhash{pos(1)});
end

[~,out] = system([termset ' ; ' gitcmd]);
out(end-8:end) = [];  % delete rubbish at the end of the string
txt = {out};
