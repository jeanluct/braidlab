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

%% plotting 
% figure;
% hold all;
% for k = 1:5
%   plot3(XY(:,1,k), XY(:,2,k), t);
% end
% 
%% Compute the braid using Matlab code

global BRAIDLAB_COLORBRAIDING_CPP   % modified colorbraiding will have a flag
                              % that can select Matlab vs C++ code

%% Compute the braid using C++ code
timing = {};

setn = 1; tic

clearvars -global BRAIDLAB_threads
BRAIDLAB_COLORBRAIDING_CPP = true
b_cpp_p = braidlab.braid(XY);
timing{setn}.type = 'Threaded (autoset)';
timing{setn}.time = toc;

setn = setn + 1; tic
global BRAIDLAB_threads
BRAIDLAB_threads = 2;
BRAIDLAB_COLORBRAIDING_CPP = true
b_cpp_p = braidlab.braid(XY);
timing{setn}.type = 'Threaded (2 threads)';
timing{setn}.time = toc;


setn = setn + 1; tic
BRAIDLAB_threads = 1
BRAIDLAB_COLORBRAIDING_CPP = true
b_cpp_s = braidlab.braid(XY);
timing{setn}.type = 'Unthreaded';
timing{setn}.time = toc;
                              
setn = setn + 1; tic
BRAIDLAB_COLORBRAIDING_CPP = false
b_matlab = braidlab.braid(XY);
timing{setn}.type = 'Matlab';
timing{setn}.time = toc;

%assert( b_matlab == b_cpp, 'Braids are not equal');
assert( lexeq(b_matlab,b_cpp_p), ['C++ multithreaded and MATLAB ' ...
                    'braids are not lexically equal'] );
assert( lexeq(b_matlab,b_cpp_s), ['C++ singlethreaded and MATLAB ' ...
                    'braids are not lexically equal'] );

disp('BRAIDS ARE EQUAL');

disp('Timing information (sec)')
for k = 1:length(timing)
  fprintf('Timing type: %s \n\t Time (sec): %f\n', timing{k}.type, ...
          timing{k}.time)
end
