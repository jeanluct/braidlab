n = 200; % number of strands
nLoops = 200000; % number of loops
maxN = 30;

fprintf(['Computing %d loops of %d punctures with coordinate numbers ' ...
         'between +-%d\n'], nLoops, n, round(maxN/2));

% generate random coordinates
C = randi(maxN, [nLoops,2*n - 4]) - round(maxN/2);

% convert coordinates to loops
loops = braidlab.loop(C);

global BRAIDLAB_loop_minlength_nomex

% mex calculation
tic
BRAIDLAB_loop_minlength_nomex = 0;
l_cpp = loops.minlength.';
mextime = toc;
fprintf('MEX computation completed in %f sec\n', mextime);
% matlab calculation
tic
BRAIDLAB_loop_minlength_nomex = 1;
l_mat = loops.minlength.';
mattime = toc;
fprintf('MATLAB computation completed in %f sec\n', mattime);

% assert they are the same

assert( all(l_cpp == l_mat) )
fprintf(['Results of Matlab and MEX computation of loop lengths ' ...
         'match. \nSpeedup factor: %f\n'], mattime/mextime);
