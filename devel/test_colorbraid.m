% test for colorbraid using Matlab and CPP code

global COLORBRAIDING_MATLAB   % modified colorbraiding will have a flag that can select Matlab vs C++ code

%% Set up a random physical braid in XY
rng('default');
N = 5;
L = 1000;

t = linspace(0,1,L);
XY = zeros( L, 2, 5 );

for k = 1:5

  XY(:,1,k) = cumsum( randn( L, 1) );
  XY(:,2,k) = cumsum( randn( L, 1) );  

end
D = 1.1* sqrt( XY(:,1,:).^2 + XY(:,2,:).^2 );
XY = XY ./ max(D(:));

%% plotting 
figure;
hold all;
for k = 1:5
  plot3(XY(:,1,k), XY(:,2,k), t);
end

%% Compute the braid using Matlab code
COLORBRAIDING_MATLAB = true
b_matlab = braidlab.braid(XY);

%% Compute the braid using C++ code
COLORBRAIDING_MATLAB = false
b_cpp = braidlab.braid(XY);

assert( b_matlab == b_cpp, 'Braids are not equal');
assert( lexeq(b_matlab,b_cpp), 'Braids are not lexically equal' );



