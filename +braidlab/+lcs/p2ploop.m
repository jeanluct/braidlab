function [loops, loopIndex] = p2ploop(n)

% P2PLOOP(N) produces the loops that connect two punctures simply above all
% in between punctures or below.
% Dyn_cell: a cell structure containing the Dynnikov coordinates for the
% loop connecting a given pair of points.
% Dyn_vec: is a vector of the produced Dynnikov coordinates
% Dyn_ind: the indicies for the coordinates stored in Dyn_vec

% Create the parameters that will be output

DynVec = zeros((n-1)^2,2*n-4);
loopIndex = zeros((n-1)^2,2);

% Cycle through all the loops with indicies I and J where J has to be
% greater than I

ind = 1;

for I = 1:n
    for J = I+1:n
        
        % Create the Dynnikov coordinates which will be modified
        
        Dyn = zeros(1,2*n-4);
        
        % A -1 at the index k-1 indicates that the loop is passing under
        % the kth puncture.  This is applied to all punctures between
        % punctures I and J
        
        for k = I+1:J-1
            Dyn(k-1) = -1;
        end
        
        % If the loop starts after the first point a value of -1 has to be
        % placed in the b portion of the Dynnikov coordinate before the Ith
        % puncture which is where the loop starts

        if I > 1
            Dyn(n-2+I-1) = -1;
        end
        
        % If the loop ends before the last puncture a value of 1 has to be
        % placed in the b portion of the Dynnikov coordinate after the Jth
        % puncture which indicates the loop has ended

        if J < n
            Dyn(n-2+J-1) = 1;
        end
        
        % Place the created Dynnikov coordinate in the output parameters.

        DynVec(ind,:) = Dyn;
        loopIndex(ind,:) = [I J];
        
        ind = ind+1;
        
        % To create a corresponding loop which connects punctures I and J
        % but from above as opposed to below the 'a' portion of the
        % Dynnikov coordinates are changed to their negative.  This
        % coordinate system is also saved into the output parameters.

        if J-I ~= 1
            DynVec(ind,:) = [-Dyn(1:(n-2)) Dyn(n-1:end)];   
            loopIndex(ind,:) = [J I];
            ind = ind+1;
        end
           
    end
end

loops = braidlab.loop(DynVec);