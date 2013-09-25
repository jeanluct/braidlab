function deps = Step2_CreateEPS(braid,loops,loopIndex)

%STEP2_CREATEEPS calculates the entangled puncture sets for a set of loops
%  EPS = STEP2_CREATEEPS(DYN) takes in an array of loops (DYN) calculates
%  the punctures that are entangled by each loop.  Then combines the
%  entangled puncture sets into a structue which contains information on
%  which pair-loops result in the same EPS.


% Calculation of the mu and nu coordinates for the pair-loops in their
% evolved state.  We have to make sure to calculate the number of times the
% loop passes above and below the first and last puncture which are a
% function of the first and last nu value.  This gives information on which 
% punctures are entangled or not. 

Num_punc = loops.n;

[mu, nu] = loops.intersec;

M = [nu(:,1)/2 mu(:,1:2:end) nu(:,Num_punc-1)/2];
N = [nu(:,1)/2 mu(:,2:2:end) nu(:,Num_punc-1)/2];

% Apply the generator sequnce to an index vector to determine where the
% punctures end.  The value of the i_th index is the location of that
% puncture after all generators have been applied.

Ind_end = braid.perm;

% Calculation of the punctures which are not entangled by a given pair-loop
% stored in the cell structure dis.

dis = cell(Num_punc,Num_punc);

% For each pair-loop the code will use the P,M,N coordinates to determine
% which punctures are not entangled by this loop.  

for i = 1:size(loopIndex,1)
    MN_coord = [M(i,:) N(i,:)];
    zero_ind = find(MN_coord==0);
    for j = 1:length(zero_ind)
        if zero_ind(j) == Num_punc || zero_ind(j) == 2*Num_punc
            dis{loopIndex(i,1),loopIndex(i,2)} = [dis{loopIndex(i,1),loopIndex(i,2)} Ind_end(Num_punc)];
        else
            dis{loopIndex(i,1),loopIndex(i,2)} = [dis{loopIndex(i,1),loopIndex(i,2)} Ind_end(mod(zero_ind(j),Num_punc))];
        end
    end
    dis{loopIndex(i,1),loopIndex(i,2)} = unique(dis{loopIndex(i,1),loopIndex(i,2)}); 
end

% Conversion of dis to dis_sets.  This takes takes the loops that result in
% the same entangled set and groups them together.  The information saved
% in each column of the cell are: 1 - disentangled puncture set, 2 - number
% of loops resulting in this set, 3 - the loops resulting in this set, 4 -
% the number of punctures in the disentangled puncture set

dis_sets = cell(0,2);
f = 0; % a switch that indicates if a new puncture set needs to be created or not

for i = 1:Num_punc
    for j = 1:Num_punc
        if length(dis{i,j})~=0
            
            % Start by searching to see if the set matches an already
            % existing set            
            for k = 1:size(dis_sets,1)
                if length(dis{i,j}) == length(dis_sets{k,1})
                    if dis{i,j} == dis_sets{k,1}
                        dis_sets{k,2} = dis_sets{k,2}+1;
                        dis_sets{k,3} = [dis_sets{k,3}; i+1i*j];
                        f = 1;
                    end
                end
            end
            
            % If there is no match the set is saved
            if f ~=1           
                dis_sets{1+size(dis_sets,1),1} = dis{i,j};
                dis_sets{size(dis_sets,1),2} = 1;
                dis_sets{size(dis_sets,1),3} = i+1i*j;
                dis_sets{size(dis_sets,1),4} = length(dis{i,j});
            end
        end
        f = 0;
    end
end

% Sort the rows first by the number of points that make up the set and then
% by the number of loops that result in that set
deps = sortrows(dis_sets,[4 2]); 