function linecount_plot(ptype)

if nargin < 1, ptype = 'rev'; end

d = load('linecount.dat');
ii = [1 ; find(diff(d(:,3)))+1];

rev = d(ii,1);
utc = d(ii,2);
lc = d(ii,3);

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

% Display clickable tooltips for each datapoint, showing Mercurial log.
dcm_obj = datacursormode(fig);
set(dcm_obj,'DisplayStyle','window','SnapToDataVertex','on',...
	    'Enable','on','UpdateFcn',@hglog)


% ==================================================================
function txt = hglog(~,event_obj)

pos = get(event_obj,'Position');

[~,shell] = system('echo $0');
if ~isempty(findstr(shell,'bash'))
  termset = 'export TERM=ansi';
elseif ~isempty(findstr(shell,'tcsh'))
  termset = 'setenv TERM ansi';
else
  error('Unknown shell.')
end

if pos(1) > 5e5
  % pos(1) is most likely a datenum date, not a revision number.
  % Convert datenum to UTC.
  utc = int32(86400*(pos(1) - datenum(1970,1,1)));
  hgcmd = sprintf('hg log -d "%d 0" --template ''{rev}: {desc}''',utc);
else
  hgcmd = sprintf('hg log -r %d --template ''{rev}: {desc}''',pos(1));
end

[~,out] = system([termset ' ; ' hgcmd]);
out(end-8:end) = [];  % delete rubbish at the end of the string
txt = {out};
