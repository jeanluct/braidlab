% test for colorbraid using Matlab and CPP code

global BRAIDLAB_debuglvl
BRAIDLAB_debuglvl = 1  % or higher
BRAIDLAB_threads = 2


%% Set up a random physical braid in XY
rng('default');
N = 120;
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
tic
BRAIDLAB_COLORBRAIDING_CPP = true
b_cpp_p = braidlab.braid(XY, 'threads', BRAIDLAB_threads);
toc                              

tic
BRAIDLAB_COLORBRAIDING_CPP = true
b_cpp_s = braidlab.braid(XY, 'threads', 0);
toc                              
                              
tic
BRAIDLAB_COLORBRAIDING_CPP = false
b_matlab = braidlab.braid(XY);
toc

%assert( b_matlab == b_cpp, 'Braids are not equal');
assert( lexeq(b_matlab,b_cpp_p), ['C++ multithreaded and MATLAB ' ...
                    'braids are not lexically equal'] );
assert( lexeq(b_matlab,b_cpp_s), ['C++ singlethreaded and MATLAB ' ...
                    'braids are not lexically equal'] );


disp('BRAIDS ARE EQUAL');


