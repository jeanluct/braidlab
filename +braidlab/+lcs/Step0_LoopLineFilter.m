function punctureAssignment = Step0_LoopLineFilter(xTraj)

%% Create braid from trajectories

system_braid = braidlab.braid(xTraj);

%% Set the initial conditions and resort the trajectories
% Want the trajectory list to match the order of the initial distribution

[xInitial, rowIndex] = sortrows(permute(xTraj(1,:,:),[3 2 1]));

xTrajSorted = zeros(size(xTraj,1),size(xTraj,2),size(xTraj,3));

for i = 1:length(rowIndex)
    xTrajSorted(:,:,i) = xTraj(:,:,rowIndex(i));
end

%% Create the list of loops connecting pairs of trajectories and 

loopIndex = zeros(size(xInitial,1)*(size(xInitial,1)-1),2);
loopList = [];
k = 1;

for i = 1:size(xInitial,1)
    for j = i+1:size(xInitial,1)
        
        loopIndex(k,:) = [i j];
        loopList(k) = braidlab.lcs.loopline(i,j,xInitial);
        
        k = k + 1;
    end
end
        
%% Act on the braids

loopListModified = system_braid*loopList;

%% Calculate the ratio of the lengths before and after advection

lengthRatio = loopListModified.length./loopList.length;
loopIndexShort = loopIndex(lengthRatio<1,1);

%% Label the puncture groups

punctureAssignment = zeros(1,system_braid.n);

for i = 1:length(loopIndexShort)
    ind1 = punctureAssignment(loopIndexShort(i,1));
    ind2 = punctureAssignment(loopIndexShort(i,2));
    
    if ind1 == 0 && ind2 == 0
       punctureAssignment(loopIndexShort(i,1)) = max(punctureAssignment)+1;
       punctureAssignment(loopIndexShort(i,2)) = punctureAssignment(loopIndexShort(i,1));
    elseif ind1 == 0 && ind2 ~= 0
       punctureAssignment(loopIndexShort(i,1)) = punctureAssignment(loopIndexShort(i,2));
    elseif ind1 ~= 0 && ind2 == 0
       punctureAssignment(loopIndexShort(i,2)) = punctureAssignment(loopIndexShort(i,1));
    else
       punctureAssignment(punctureAssignment==ind2) = ind1;
    end
    
end


end