global BRAIDLAB_colorbraiding_nomex
global BRAIDLAB_threads

n = 100;
k = 1000;
eps = .2;
proj = .234;

rng('default');
XY = randomwalk(n,k,eps);

BRAIDLAB_colorbraiding_nomex = 1;
tic
b1 = braid(XY,proj);
toc

BRAIDLAB_colorbraiding_nomex = 0;
BRAIDLAB_threads = 1;
tic
b2 = braid(XY,proj);
toc

BRAIDLAB_threads = 2;
tic
b2 = braid(XY,proj);
toc

lexeq(b1,b2)
