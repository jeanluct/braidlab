function [gen tcr cross_cell_sub] = color_braiding_sub(cross_cell,p_ind)

% [GEN TCR CROSS_CELL_SUB] = COLOR_BRAIDING_SUB(CROSS_CELL,P_IND) is a code
% which takes the input parameters of the cell structure containing the
% crossing times of a given braid, CROSS_CELL, and creates a braid with
% just the trajectories contained in P_IND.  This code should produce the
% generator sequence, GEN, for a braid containing only a subset of the
% initial strands within the braid.

% This partial braid is calculated using the crosses between trajectories
% that are still in the braid.  For example if the initial braid contained
% strainds 1, 2, 3, and 4, but the parital braid contains only strands 1,
% 2, and 4 then the crossings found previously between 1-2, 1-4, and 2-4,
% will be analyzed.

% disp('COLOR_BRAIDING_SUB routine in use')

n = length(p_ind); % number of strands in the new braid

cross_cell_sub = cell(n); % new cell structure for the partial braid


% For each cell in the new structure, the code fills out the cell with the 
% contents corresponding to the i_th and j_th designated punctures which
% are in the complete crossing structure, CROSS_CELL.

for i = 1:n
    for j = 1:n
        cross_cell_sub{i,j} = cross_cell{p_ind(i),p_ind(j)};
    end
end


% With the new crossing structure, the 3rd part of the code color_braiding
% is completed. (Sorting of crossing times.  Calculation of the generators
% and creation of the generator sequnce, GEN, and the time of crossing,
% TCR, vectors.

t_cross = [];


for I = 1:n
    for J = 1:n
        if size(cross_cell_sub{I,J},1)~=0
            t_cross = [t_cross; cross_cell_sub{I,J} ones(size(cross_cell_sub{I,J},1),1)*I ones(size(cross_cell_sub{I,J},1),1)*J];
        end
    end
end


t_cross = sortrows(t_cross);

Iperm = 1:n;
gen = zeros(size(t_cross,1),1);
tcr = gen;

for i = 1:size(t_cross,1)
    ind_1 = find(Iperm == t_cross(i,3));
    if Iperm(ind_1+1) == t_cross(i,4)
        Iperm(ind_1:ind_1+1) = [t_cross(i,4) t_cross(i,3)];
        gen = [gen; ind_1*t_cross(i,2)];
        tcr = [tcr; t_cross(i,1)];
    else
        error('t_cross mistake')
    end
end