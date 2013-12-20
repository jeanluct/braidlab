d = load('linecount.dat');

rev = d(:,1);
utc = d(:,2);
lc = d(:,3);

% Convert Unix time to datenum.
dnum = utc/86400 + datenum(1970,1,1);

subplot(2,1,1)
plot(dnum,lc,'.-')
datetick('x','mmm yy','keepticks')
xlabel('date (UTC)')
ylabel('# lines')

subplot(2,1,2)
plot(rev,lc,'.-')
xlabel('revision')
ylabel('# lines')
