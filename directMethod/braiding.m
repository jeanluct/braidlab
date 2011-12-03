function [out Xtraj T1 gen] = braiding(run, file)

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

% clc

if nargin < 1
    % default loop analysis
    run = 2;
end

if nargin < 2
    % run trajectory_selection to create trajectories
    
    disp('Select initial conditions for trajectories in the figure')
    
    % Time parameters for the trajectories
    
    tmax = 300;
    dt = .01;
    [Xtraj T1] = trajectory_selection(tmax,dt);
    
    save test_traj.mat Xtraj T1
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


[gen,tcr] = color_braiding(Xtraj,T1);
tc = tcr;
length(gen)



% The next step is the loop analysis which will be done in one of the three
% ways previously mentioned.

if run == 1
    
    %  This mode allows the user to either input a loop via Dynnikov
    %  Coordinates or to draw one using the function loopdraw.  There is
    %  also the option to make a movie of the changing figure.
    
    in = input('Do you have a known loop you would like run? [y/n] ','s');
    
    if in == 'y'
        Dyn = input('Enter your Dynnikov Coordinate in the form [. . .]');
    elseif in =='n'
        Dyn =loopdraw([x_traj(1,:)' y_traj(1,:)']);
        close
    end
    
    in = input('Did you want to make a movie? [y/n] ','s');

    braiding_movie(x_traj, y_traj, T1, Dyn, gen, tc,in) 
    
    out = [];
    
elseif run==2
    
    %  This mode allows for a rapid progression through all possible loops
    %  within the given Dynnicov coordinate range.  Loops which don't grow
    %  beyond a certain factor of their initial size are saved and plotted
    %  once the function LOOPLISTSIGMA has completed going through all
    %  loops.  The output of this method is a plot of all the loops which
    %  remain below the threshold growth.
   
    up = looplistsigma(gen,size(Xtraj,3),-1,1);   

    out = up;
    
elseif run==3
    
    %  This mode will create a list of all possible loops using the
    %  LOOPLIST function.  All the loops are then modified by the LOOPINTER
    %  code simultaneously.  The sizes of the loops are tracked and the
    %  output of this method is a plot with all the loop interceptions as a
    %  function of time.
    
    Dyn = looplist(2*size(Xtraj,3)-4,-1,1);
    L(:,1) = loopinter(Dyn);
    
    for i = 1:length(gen)
        if mod(i,10)==0
            disp([num2str(i) '/' num2str(length(gen))]);
        end
        Dyn = loopsigma(gen(i),Dyn);              
        L(:,end+1) = loopinter(Dyn);                   
    end
    
    for q = 2:(tmax/dt)
        TT = t1(q);
        idx = find(tc <= TT);
        L1(:,q) = L(:,idx(end));
    end
    
    out = L1;
end