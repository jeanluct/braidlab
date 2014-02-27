function punctureAssignment = Step3_FindIPS(deps,n)

% STRUCTURES = STRUC(DIS_SETS,N) is a code which takes in the disentangled
% sets (DIS_SETS) and places them into puncture structure sets.  

% Create the structure Index vecto where each puncture is represented as an
% index and the value in the vector at that index is the structure at which
% the puncture belongs

punctureAssignment = zeros(1,n);

numStruc = 1;

kill = 0;
startIndex=1; % The set number that the search starts with

while kill == 0
    
    % The code will loop through the disentangled sets and try to group the
    % punctures which were entangled together into sets.  If th
    for i = startIndex:size(deps,1)        
        punctures = ones(1,n);
        punctures(deps{i,1})=0;
        p_ind = find(punctures==1);
        
        if length(p_ind) < n
            
            % Is this a new structure? If so place all the punctures
            % entangled into this new structure with a new structure index.            
            if sum(punctureAssignment(p_ind))==0
                punctureAssignment(p_ind) = numStruc;
                numStruc = numStruc+1;
                
            % If it is not a new structure all the points in the entangled
            % set which are not yet in the structure are put into the
            % structure.            
            else            
                l_inc = unique(punctureAssignment(p_ind));
                if l_inc(1) == 0
                    l_inc = l_inc(2:end);
                end
                punctureAssignment(p_ind) = l_inc;                            
            end
        end
    end    
    
    % If all punctures have been assigned and they are not all in the same
    % structre the code can move on    
    if isempty(find(punctureAssignment==0))==1 && sum(punctureAssignment)>n
        kill = 1;
        
    % If the code can't find multiple structures after an attempt then it
    % tries again starting with the next disentangled set.  The reason for
    % this is that the previous first set tried could have entangled
    % multiple structures.  The number of punctures in each disentangled
    % set decreases meaning that there is a chance the multiple structures
    % will be found    
    elseif startIndex ~= size(deps,1)
        startIndex = startIndex+1;
        punctureAssignment = zeros(1,n);
        numStruc = 0;
    
    % If all the starting points have been tried the code ends and some
    % punctures remain unassigned then it is assumed that they form another
    % structure        
    elseif isempty(find(punctureAssignment==0))==0
        unassignedPunctures = find(punctureAssignment==0);
        punctureAssignment(unassignedPunctures) = numStruc;
        kill = 1;
        
    % If all the starting points have been tried and all punctures have
    % been assigned to the same IPS then the code has failed to find
    % multiple structures for the given braid        
    else        
        error('Structure set assignment failed');
    end    
end