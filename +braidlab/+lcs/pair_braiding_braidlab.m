function nonGrowingLoops = pair_braiding_braidlab(Xtraj,braid)

if nargin < 2
    braid = braidlab.braid(Xtraj);
end

Xini = [permute(Xtraj(1,1,:),[3 1 2]) permute(Xtraj(1,2,:),[3 1 2])];

% Step 1: takes in either the trajectories or the braid and calculates the
% corresponding pair-loops and acts on these loops.  The outputs are the
% array of modified loops (loops) and an array with the punctures connected 
% by each pair loop

[loops loopIndex] = Step1_PairLoopModification(braid);

% Step 2: takes in the modified loops and calculates the punctures that are
% not entangled by the action of the braid.  The output is a cell
% containing the complement of the entangled puncture set, the number and
% which loops result in this set

deps = Step2_CreateEPS(braid,loops,loopIndex);

% If there are disentangled sets the code will search for structures and
% try to find the corresponding Dynnikov coordinate that surrounds the
% points in the structure in a non-growing way

if isempty(deps{1,1})==0
    
    % Step 3: calculate the invarint puncture sets from the disentangled
    % sets and assign each puncture to an IPS

    punctureAssignment = Step3_FindIPS(deps,loops.n);    
    
    for ipsIndex = 1:max(punctureAssignment)
        
        % Step 4: Using link-loops try to connect the punctures in an IPS
        % in such a way that the resulting loop does not grow under the
        % action of the braid.
        
        nonGrowingLoops(ipsIndex) = Step4_DynCreation(braid,punctureAssignment,ipsIndex,Xini);
    end
        
else
    nonGrowingLoops = [];
end