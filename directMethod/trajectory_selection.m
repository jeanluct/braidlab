function [Xtraj T1] = trajectory_selection(tmax,dt)

% [XTRAJ T1] = TRAJECTORY_SELECTION(TMAX,DT) is a code that allows the user
% to select the initial conditions for a set of trajectories advected by
% the duffing oscilator.

addpath ../Multi_Use_Code/
close all
% Set parameters for integration

t = 0:dt:tmax;
delta = .0; gamma = .14; omega = 1;

% Define the vectors for the quiver/streamslice

x = -3:.5:3;
y = x;
[X Y] = meshgrid(x,y);

% Duffing oscilator velocity vector

U = Y;
V = X.*(1-X.^2)+gamma*cos(omega*t(1))-delta*Y;

% Plot streamlines (for time independent system) This just gives a rough
% idea of where the dynamically different regions might

h = streamslice(X,Y,U,V);
axis([-3 3 -3 3])
xlabel('X')
ylabel('Y')
title({'Phase Plane with trajectories in black';'Click on the plot to add trajectories press a key to continue'})

% Get first initial position for the trajectories

x = ginput(1);
N = 1; % Number of trajectories

% Calculate the trajectory for the first initial condition

options = odeset('Refine',10);
[T1 Y1] = ode45(@duffing,0:dt:tmax,x,options);
Xtraj(:,:,N) = Y1;

% Plot the trajectory 

for i = 1:20:length(t)    
    cla      
    hold on
    xlabel('X')
    ylabel('Y')
    title({'Phase Plane with trajectories in black';'Click on the plot to add trajectories press a key to continue'})
    plot(Xtraj(1:i,1,1),Xtraj(1:i,2,1),'k')
    drawnow
end

% The program will allow the user to continue to add new initial conditions
% till a key is pressed

kill = 0;

while kill == 0
    
    keydown = waitforbuttonpress;  % Parameter which detects if a key has been hit to indicate a change needs to be made
    for i = 1:N
        plot(Xtraj(1,1,i),Xtraj(1,2,i),'rx','MarkerSize',10,'LineWidth',2)
    end
    %  If no key is hit the user continues to create vertices for the loop
    if keydown == 0
        
        % Specify the new initial condition and calculate the trajectory
        
        x = ginput(1);
        N = N + 1;
        [T1 Y1] = ode45(@duffing,0:dt:tmax,x,options);        
        Xtraj(:,:,N) = Y1;
        
        % Plot all of the trajectories
        
        for i = 1:100:length(t)
            U = Y;
            V = X.*(1-X.^2)+gamma*cos(omega*t(i))-delta*Y;
            cla
            xlabel('X')
            ylabel('Y')
            title({'Phase Plane with trajectories in black';'Click on the plot to add trajectories press a key to continue'})

            h = quiver(X,Y,U,V);    
            hold on
            for j = 1:N
                plot(Xtraj(1:i,1,j),Xtraj(1:i,2,j),'k')
            end        
            drawnow
        end
        
        % If a key is pressed end the code
        
    elseif keydown == 1
        kill = 1;
    end    
end

N