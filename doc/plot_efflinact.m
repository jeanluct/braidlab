asp = [1 2 1];
fs = 22;

b = braid([1 -2]); cycle(b,'plot')
pbaspect(asp)
set(gca,'FontSize',fs)
print -dpdf efflinact1

b = braid([1 2 3]); cycle(b,'plot')
pbaspect(asp)
set(gca,'FontSize',fs)
print -dpdf efflinact2

b = braid('psi',11); cycle(b,'plot')
pbaspect(asp)
set(gca,'FontSize',fs)
print -dpdf efflinact3
