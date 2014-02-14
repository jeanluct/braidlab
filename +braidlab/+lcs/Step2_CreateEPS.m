function nes_combined = Step2_CreateEPS(system_braid,loops,loopIndex)

%STEP2_CREATEEPS calculates the entangled puncture sets for a set of loops
%  EPS = STEP2_CREATEEPS(DYN) takes in an array of loops (DYN) calculates
%  the punctures that are entangled by each loop.  Then combines the
%  entangled puncture sets into a structue which contains information on
%  which pair-loops result in the same EPS.


%% Calculation of the mu and nu coordinates for the pair-loops in their
% evolved state.  We have to make sure to calculate the number of times the
% loop passes above and below the first and last puncture which are a
% function of the first and last nu value.  This gives information on which 
% punctures are entangled or not. (M and N are part of the P,M,N coordinate
% representation.)

Num_punc = loops.n;

[mu, nu] = loops.intersec;

M = [nu(:,1)/2 mu(:,1:2:end) nu(:,Num_punc-1)/2];
N = [nu(:,1)/2 mu(:,2:2:end) nu(:,Num_punc-1)/2];

%% Apply the generator sequnce to an index vector to determine where the
% punctures end.  The value of the i_th index is the location of the i_th
% puncture after all generators have been applied.

Ind_end = system_braid.perm;

%% Creation of the data structure which will contain the indexes of
% punctures that have not been entangled by a given pair-loop.  Each cell
% contains the set of punctures that were not entagled (ne).

not_entangled_sets = cell(Num_punc,Num_punc);

%% For each pair-loop the code will use the P,M,N coordinates to determine
% which punctures are not entangled by this loop after advection.  

for I = 1:size(loopIndex,1)
    M_zeros = find(M(I,:)==0);
    N_zeros = find(N(I,:)==0);
    not_entangled_sets{loopIndex(I,1),loopIndex(I,2)} = sort(Ind_end(unique([M_zeros N_zeros]))); 
end

%% Condensing identical not_entangled_sets
% This takes takes the loops that result in the same entangled set and 
% groups them together.  The information saved in each column of the cell 
% are: 1 - set of punctures not entangled by loop, 2 - number of loops 
% resulting in this set, 3 - the loops resulting in this set, 4 -the number 
% of punctures in the disentangled puncture set

nes_combined = cell(0,2);
new_entry = 1;

for I = 1:Num_punc
    for J = 1:Num_punc
        if ~isempty(not_entangled_sets{I,J})    
            
            % Start by searching to see if the set matches an already
            % existing set     
            
            K = 0; % Start at the beginning of ne_sets
            
            while new_entry==1 && K < size(nes_combined,1)
                K = K + 1;
                if length(not_entangled_sets{I,J}) == length(nes_combined{K,1}) & not_entangled_sets{I,J} == nes_combined{K,1}
                    nes_combined{K,2} = nes_combined{K,2}+1;
                    nes_combined{K,3} = [nes_combined{K,3}; I+1i*J];
                    new_entry = 0;
                end
            end
            
            % If there were no matches and a new entry is needed add the
            % set to the end of the list
            
            if new_entry == 1                
                nes_combined{1+end,1} = not_entangled_sets{I,J};
                nes_combined{end,2} = 1;
                nes_combined{end,3} = I+1i*J;
                nes_combined{end,4} = length(not_entangled_sets{I,J});
            end
            
            % Reset new_entry parameter for next puncture set
            
            new_entry = 1;
            
        end
    end
end

%% Sort the rows first by the number of points that make up the set and then
% by the number of loops that result in that set

nes_combined = sortrows(nes_combined,[4 2]); 