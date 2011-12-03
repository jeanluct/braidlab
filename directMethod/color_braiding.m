function [gen tcr cross_cell] = color_braiding(X,t)

% [GEN TCR CROSS_CELL] = COLOR_BRAIDING(X,T) is a code which take the
% inputs X (the trajectory set) and T (time) and calculates the
% corresponding generator sequence via a color braiding method.  The color
% braiding method takes pairs of strands and finds the crossings that occur
% between the two.  This is done for all pairs then the crossings for each
% pair are converted to generators.  The outputs for this code are the
% generator sequence (GEN), the time of crossing (TCR), and the cell
% structure containing times of crossings for each pair of strands
% (CROSS_CELL).


disp('Part 1: Initialize parameters for crossing analysis')

% Need to calculate the number of punctures.  Sort the trajectories into
% order based on lowest to highest initial x value. Create the cell
% structure which will store the crossing times.

n = size(X,3); % number of punctures

% To sort the trajectories, the initial conditions are placed into a matrix
% which then is sorted

Xini = zeros(n,2); % Initial condition matrix
for i = 1:n
    Xini(i,:) = [X(1,1,i) X(1,2,i)];
end

[Xs Ind] = sortrows(Xini); % Sorting of the initial conditions.  
                           % IND is the index number from the sort

% Creation of the sorted trajectories which will be stored as Xtraj

Xtraj = 0*X;
for i = 1:n
    Xtraj(:,1,i) = X(:,1,Ind(i));
    Xtraj(:,2,i) = X(:,2,Ind(i));
end

cross_cell = cell(n); % cell structure for crossing times.

disp('Part 2: Search for crossings between pairs of strands')

% This portion of the code will cycle through all pairs of strands and find
% all crossings and calculate the time at which the crossing occured.  This
% time is then storred into CROSS_CELL.  Its location indicates both the
% strands involved and the direction of crossing.  For example if strand I
% and J cross with I in the lower index initially the time of the crossing 
% will be stored in CROSS_CELL(I,J) but if J is in the lower index initially
% the time will be stored in CROSS_CELL(J,I).  The direction of crossing
% either positive or negative is saved in the same cell to be used for to
% determine the generator sequence later. To ensure that each pair is 
% analyzed one the code loops through each of the strands and compares it 
% to every strand with a higher index

for I = 1:n
    
    disp([num2str(I) '/' num2str(n)]) % Counter to monitor progress
    
    for J = I+1:n
        
        % Save the current pair of trajectories which will be analyzed
        
        x_traj1 = Xtraj(:,1,I);
        y_traj1 = Xtraj(:,2,I);
        x_traj2 = Xtraj(:,1,J);
        y_traj2 = Xtraj(:,2,J);
        
        % Determine the order of the x-coordinates, PERM.  Each crossing will
        % correspond to a change in sign of PERM.
        
        perm = sign(x_traj1-x_traj2);
        permZeroIndex = find(perm==0);
        perm(permZeroIndex) = perm(permZeroIndex-1);
        
        % For each time step up to the last one the code will determine if
        % there was a crossing.  Two things have to be taken into account.
        % If the two points happen to have the same x-coordinate than
        % either a crossing is occuring at that moment or the points are
        % colliding (i.e. have the same y-coordinate).  If the trajectories
        % have the same x-coordinate the value of PERM at this instant will
        % be 0.  Otherwise crosses only occur when there has been a change
        % in the value of PERM from one time step to the next.
        
        for i = 1:length(perm)-1
            if perm(i+1) ~= perm(i) % true if the order of the trajectories changed
                
                % Function INTERPCROSS calculates the interpolated time of
                % crossing
                [tc,dY] = interpcross(t,[x_traj1 x_traj2],[y_traj1 y_traj2],i,1,2); 
                if perm(i) < 0 % This is true if I was in the lower index
                    if dY > 0
                        cross_cell{I,J} = [cross_cell{I,J}; tc 1];
                    elseif dY < 0
                        cross_cell{I,J} = [cross_cell{I,J}; tc -1];
                    else
                        error('Intersecting points');
                    end                    
                elseif perm(i) > 0 % This is true if J was in the lower index
                    if dY > 0
                        cross_cell{J,I} = [cross_cell{J,I}; tc -1];
                    elseif dY < 0
                        cross_cell{J,I} = [cross_cell{J,I}; tc 1];
                    else
                        error('Intersecting points');
                    end
                end
            end
        end        
        
    end
end

disp('Part 3: Sorting the pair crossings into the generator sequence')

% At this point the variable CROSS_CELL is a structue which contains the
% crossing times and directions for strand pairings which are initially in
% the order I,J.  These have to be sorted and applied to the system to make
% sure the sequence is correct.

t_cross = []; % This will be the matrix containing information on the 
              % crossing.  Column 1: time. Column 2: direction. Column 3:
              % lower strand.  Column 4: higher strand.

for I = 1:n %Cycle through all cells
    for J = 1:n
        if size(cross_cell{I,J},1)~=0 % If the cell is not empty add information
            t_cross = [t_cross; cross_cell{I,J} ones(size(cross_cell{I,J},1),1)*I ones(size(cross_cell{I,J},1),1)*J];
        end
    end
end

% Sort the data based on time of crossing
t_cross = sortrows(t_cross);

% To determine the magnitude of the generator, the crossings have to be
% applied to the system and the location of the lower strand in the
% crossing will be the magnitude of the generator.  The direction of
% crossing caluclated earlier is then applied to get the generator value.

Iperm = 1:n; % This is the initial vector which the generators will be applied to

% Create the generator and time of crossing, tcr, vectors.

gen = zeros(size(t_cross,1),1);
tcr = gen;

% Cycle through each crossing, apply, and calculate the corresponding
% generator

for i = 1:size(t_cross,1)
    ind_1 = find(Iperm == t_cross(i,3)); % Find the location of the lower strand
    if Iperm(ind_1+1) == t_cross(i,4) % If the higher strand is in fact the 
                                      % next strand to the right apply the crossing
        Iperm(ind_1:ind_1+1) = [t_cross(i,4) t_cross(i,3)]; % Update the index vector
        gen(i) = ind_1*t_cross(i,2); % save the generator
        tcr(i) = t_cross(i,1); % save the time of crossing
    else % If for some reason the two strands crossing are not next to each 
         % other an error has occured and the program will stop and give some 
         % information on the break point
        i
        Ip
        t_cross(i,2)
        error('t_cross mistake')
    end
end
