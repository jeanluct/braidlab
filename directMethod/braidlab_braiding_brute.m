function [out Xtraj T1 gen b] = braidlab_braiding_brute(file)

figure

%BRAIDING  takes or calculates trajectories then determines how loops grow
%  as a function of time
%  BRAIDING(RUN, FILE) starts first with establishing the trajectories
%  which are either contained in the file name FILE or are selected
%  by the user.  If no file is included, the default will have the user 
%  select the initial conditions.  With the trajectories gencross is used 
%  to calculate the generators.  At this point there are three options on 
%  how to study the loop growth.  The option which is run is determined by 
%  the input RUN.  The first option allows the user to draw the desired
%  loop using the function looppdraw.  The second option uses the mex file
%  helper listloopsigma which cycles through each loop one at a time and
%  saves loops which do not grow beyond a certain size ratio.  The final
%  option cycles through all loops simultaneously over all generators.  The
%  default is the second option.

clc

if nargin < 1
    % run trajectory_selection to create trajectories
    
    disp('Select initial conditions for trajectories in the figure')
    % Time parameters for the trajectories
    tmax = 600;
    dt = 5;
    [Xtraj T1] = trajectory_selection(tmax,dt);
    
else
    % if a file is designated load the file
    
    disp(['Loading trajectories'])    
    load(file);
    tmax = max(T1);
    dt = tmax/100;
end

t1 = dt*(1:tmax/dt);
disp('Trajectories established')


% Break the trajectories into their initial conditions (x_coord, y_coord)
% and the trajectory x and y components (x_traj, y_traj).

for i = 1:size(Xtraj,3)
    x_traj(:,i) = Xtraj(:,1,i);
    x_coord(i,1) = Xtraj(1,1,i);
    y_traj(:,i) = Xtraj(:,2,i);
    y_coord(i,1) = Xtraj(1,2,i);
end

% With the trajectories established the generators are calculated using the
% function GENCROSS

disp('Generators being calculated')

tic

[gen,tcr] = color_braiding(Xtraj,T1);
tc = tcr;
length(gen)

addpath ../.
b = braidlab.braid(Xtraj);

toc

loops = looplist(2*size(Xtraj,3)-4,-1,1);

tic
disp('Generator application via braidlab')
for i = 1:size(loops,1)
    if mod(i,10000)==0
        disp(num2str(i))
    end
    l1 = braidlab.loop(loops(i,:));
    save braidError.mat l1
    l2 = b*l1;
    if l2.intaxis<l1.intaxis*3
               l1.disp
               l1.plot
               figure
    end
end
toc

% The next step is the loop analysis which will be done in one of the three
% ways previously mentioned.
    
tic    
disp('Generator application via mex file')
up = looplistsigma(gen,size(Xtraj,3),-1,1)
toc
if size(up,1) < 50
    for i = 1:size(up,1)
        figure
        loopplot(up(i,:));
    end
end
out = up;
