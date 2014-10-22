% change to 'intaxis'/'minlength' to test it
lengthType = 'intaxis'; 
n = 200; % number of strands
nLoops = 200000; % number of loops
maxN = 30;

% n = 20; % number of strands
% nLoops = 20; % number of loops
% maxN = 6;

fprintf(['Computing %d loops of %d punctures with coordinate numbers ' ...
         'between +-%d\n'], nLoops, n, round(maxN/2));

% generate random coordinates
C = randi(maxN, [nLoops,2*n - 4]) - round(maxN/2);

% convert coordinates to loops
loops = braidlab.loop(C);

global BRAIDLAB_loop_nomex

% mex calculation
tic
BRAIDLAB_loop_nomex = 0;
l_cpp = loops.(lengthType).';
mextime = toc;
fprintf('MEX computation completed in %f sec\n', mextime);
% matlab calculation
tic
BRAIDLAB_loop_nomex = 1;
l_mat = loops.(lengthType).';
mattime = toc;
fprintf('MATLAB computation completed in %f sec\n', mattime);

% assert they are the same

assert( all(l_cpp == l_mat) )
fprintf(['Results of Matlab and MEX computation of %s ' ...
         'match. \nSpeedup factor: %f\n'], lengthType, mattime/mextime);
