% Find asymptotic form of spectral gaps for psi braids.

nmax = 300;
gaps = [];
for n = 3:nmax
  r = psiroots(n);
  gaps = [gaps log10(abs(r(1)/r(2)))];
end

n = 3:nmax;

format long
n1 = 2000;
r = psiroots(n1); gap1 = log10(abs(r(1)/r(2)));
c = gap1 / n1^-3

figure(1)
loglog(n,gaps,'.')
hold on
loglog(n,c*n.^-3,'r')
hold off
xlabel('n')
ylabel('spectral gap')

figure(2)
loglog(n,abs(gaps - c*n.^-3)./gaps,'.')
xlabel('n')
ylabel('error in spectral gap')
