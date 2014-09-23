% test for colorbraid using Matlab and CPP code

global BRAIDLAB_debuglvl
BRAIDLAB_debuglvl = 1  % or higher

%% Set up a random physical braid in XY
rng('default');
N = 80;
L = 20000;

t = linspace(0,1,L);
XY = zeros( L, 2, N );

for k = 1:N

  XY(:,1,k) = cumsum( randn( L, 1) );
  XY(:,2,k) = cumsum( randn( L, 1) );  

end
D = 1.1* sqrt( XY(:,1,:).^2 + XY(:,2,:).^2 );
XY = XY ./ max(D(:));

% % plotting 
% figure;
% hold all;
% for k = 1:5
%   plot3(XY(:,1,k), XY(:,2,k), t);
% end

%% prepare the simulation setup by clearing all globals
clearvars -global BRAIDLAB_COLORBRAIDING_MATLAB BRAIDLAB_threads

global BRAIDLAB_COLORBRAIDING_MATLAB   % modified colorbraiding will have a flag
                                       % that can select Matlab vs C++ code

timing = {};

%% Compute braid using default settings (C++ and autodetect thread #)
fprintf('\n*************************************\n')
setn = 1; tic
b_cpp_p = braidlab.braid(XY);
timing{setn}.type = 'Threaded (autoset)';
timing{setn}.time = toc;

%% Compute braid using C++ code and fixed number of threads (3)
fprintf('\n*************************************\n')
setn = setn + 1; tic
global BRAIDLAB_threads
BRAIDLAB_threads = 3;
b_cpp_p = braidlab.braid(XY);
timing{setn}.type = sprintf('Threaded (%d threads)', BRAIDLAB_threads);
timing{setn}.time = toc;

%% Compute braid using C++ code and a single thread
fprintf('\n*************************************\n')
setn = setn + 1; tic
BRAIDLAB_threads = 1;
b_cpp_s = braidlab.braid(XY);
timing{setn}.type = 'Unthreaded';
timing{setn}.time = toc;

%% Compute braid using MATLAB version of the code
fprintf('\n*************************************\n')
setn = setn + 1; tic
BRAIDLAB_COLORBRAIDING_MATLAB = true;
b_matlab = braidlab.braid(XY);
timing{setn}.type = 'Matlab';
timing{setn}.time = toc;
fprintf('\n*************************************\n')

%% Compare Matlab and C++ single/multithreaded braids
%assert( b_matlab == b_cpp, 'Braids are not equal');
assert( lexeq(b_matlab,b_cpp_p), ['C++ multithreaded and MATLAB ' ...
                    'braids are not lexically equal'] );
assert( lexeq(b_matlab,b_cpp_s), ['C++ singlethreaded and MATLAB ' ...
                    'braids are not lexically equal'] );
disp('BRAIDS ARE EQUAL');

%% Display timing info
disp('Timing information (sec)')
for k = 1:length(timing)
  fprintf('Timing type: %s \n\t Time (sec): %f\n', timing{k}.type, ...
          timing{k}.time)
end
