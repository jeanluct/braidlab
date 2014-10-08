n = 200; % number of strands
nLoops = 10000; % number of loops
maxN = 10;

% generate random coordinates
C = randi(maxN, [nLoops,2*n - 4]) - round(maxN/2);

% convert coordinates to loops
loops = braidlab.loop(C);

global BRAIDLAB_loop_minlength_nomex

% mex calculatio
tic
BRAIDLAB_loop_minlength_nomex = 0
l_cpp = loops.minlength.';
disp('MEX time'), toc

% matlab calculation
tic
BRAIDLAB_loop_minlength_nomex = 1
l_mat = loops.minlength.';
disp('MAT time'), toc

% assert they are the same

assert( all(l_cpp == l_mat) )
