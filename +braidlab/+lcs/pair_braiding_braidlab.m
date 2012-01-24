function nonGrowingLoops = pair_braiding_braidlab(X,braid)
%PAIR_BRAIDING_BRAIDLAB takes a set of trajectories and calculates the
%non-growing loops that are present
%  NONGROWINGLOOPS = PAIR_BRAIDING_BRAIDLAB(X) calculates the braid
%  and initial positions from the trajectories (X) and applies them to the
%  pair-loop method to find the non-growing loops.
%  NONGROWINGLOOPS = PAIR_BRAIDING_BRAIDLAB(X,braid) applies the braid and 
%  initial conditions directly to the pair-loop method

if nargin < 2
    if size(X,3)==0 || size(X,2)~=2        
      error('LCS:pair_braiding_braidlab:trajectoryformat',...
            'The trajectories are not in the proper format.  Need to be (x,y,z)...')
    end
    braid = braidlab.braid(X);
    Xini = [permute(X(1,1,:),[3 1 2]) permute(X(1,2,:),[3 1 2])];
else
    if ~isa(braid,'braidlab.braid')      
        error('LCS:pair_braiding_braidlab:braidformat',...
            'The braid input needs to be a braid object...')
    end
    if size(X,2)==2
        Xini = X;
    else
        Xini = X';
    end
    if size(Xini,1) ~= braid.n
        error('LCS:pair_braiding_braidlab:strandnumber',...
            'The number of strands in the initial condition does not match the given braid...')
    end        
end


% Step 1: takes in either the trajectories or the braid and calculates the
% corresponding pair-loops and acts on these loops.  The outputs are the
% array of modified loops (loops) and an array with the punctures connected 
% by each pair loop

[loops loopIndex] = braidlab.lcs.Step1_PairLoopModification(braid);

% Step 2: takes in the modified loops and calculates the punctures that are
% not entangled by the action of the braid.  The output is a cell
% containing the complement of the entangled puncture set, the number and
% which loops result in this set

deps = braidlab.lcs.Step2_CreateEPS(braid,loops,loopIndex);

% If there are disentangled sets the code will search for structures and
% try to find the corresponding Dynnikov coordinate that surrounds the
% points in the structure in a non-growing way

if isempty(deps{1,1})==0
    
    % Step 3: calculate the invarint puncture sets from the disentangled
    % sets and assign each puncture to an IPS

    punctureAssignment = braidlab.lcs.Step3_FindIPS(deps,loops.n);    
    
    for ipsIndex = 1:max(punctureAssignment)
        
        % Step 4: Using link-loops try to connect the punctures in an IPS
        % in such a way that the resulting loop does not grow under the
        % action of the braid.
        
        nonGrowingLoops(ipsIndex) = braidlab.lcs.Step4_DynCreation(braid,punctureAssignment,ipsIndex,Xini);
    end
        
else
    nonGrowingLoops = [];
end