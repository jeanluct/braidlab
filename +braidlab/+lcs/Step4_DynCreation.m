function nonGrowingLoop = Step4_DynCreation(b,punctureAssignment,ipsIndex,Xini)

% Read in the structures and for each structure cycle through pairs of
% points within a structure.  For each pair remove all other punctures
% within the strucutre and calculate the generators with the pair and all
% punctures outside the structure.  Next cycle through various loops
% connecting the two points and find one that is not growing (if there is
% one).  Document this loop.

% Once all the pairs have been cycled through figure out how to connect the
% loops which didn't grow.

% Sorting of the initial points by their x-coordinate

Xini = sortrows(Xini);

% Define the punctures that are in and not in the structure

P_in = find(punctureAssignment==ipsIndex);
P_out = find(punctureAssignment~=ipsIndex);

% Create a vector that labels which punctures have succesfully been
% connected

P_connected = 0*P_in;

% Get all the possible loops which have N punctures where N is equal to the
% number of punctures not in the structure plus two.  These loops make up
% all the basic ways that the two punctures can be simply connected when
% all other punctures in the structure have been removed.

[pairLoops, pairLoopIndex] = p2ploop(length(P_out)+2);

Dyn_set = [];

P_ind = 1;
P_try = 0*P_in;
P_try(P_ind) = 1;
s = 0; % Switch that tells the code to pick punctures to try incrementally to the right (0) or to the left (~0)
kill = 0; % Switch that ends the search

% While not all points are connected or till the kill switch is turned on

while sum(P_connected) ~= length(P_connected) && kill == 0;
    
    % First determine which puncture to try and connect to.  The code goes
    % first in increasing order of index (left to right) then after all
    % punctures to the right have been tried it tries connecting to one to
    % the left.
    
    if s == 0 && P_ind < length(P_try)
        P_next = find(P_try==1,1,'last')+1;
    else
        P_next = find(P_try==1,1,'first')-1;
    end
    
    % If there is a potential pair the code tries to find a loop connecting
    % the two punctures in the structure.  This is done by analyzing loops
    % connecting the paired punctures in the structure while a generator
    % sequence mixes the two selected punctures and all the punctures
    % outside the structure.
    
    if P_next ~= 0
        
        % List the indicies of the pair trying to be connected
        
        P_pair = [P_in(P_ind) P_in(P_next)] % these will be called the structure punctures.
        
        % Create a list of the punctures including the pair and all
        % punctures outside the structure.  
        
        P = sort([P_pair P_out]); % sort the considered punctures.  This is the partial puncture set.
        Xini_part = Xini(P,:); % Get the initial positions of the partial puncture set.      
        numPunc = length(P);
        
        % Find the new indecies of the pair of structure punctures.
        
        p1 = find(P==P_pair(1));
        p2 = find(P==P_pair(2));
        
        % Calculate the generator sequence for the partial puncture set.
        
        bs = b.subbraid(P);
        
        % Now we need to determine the loops that we will consider.
        
        % The first loop is either the one connecting the points if they
        % are side by side in the partial puncture sequence.  If they
        % aren't next to each other it is the loop that connects the two by
        % passing above all punctures in between the structure punctures.
        
        loopIndex = find(pairLoopIndex(:,1) == p1 & pairLoopIndex(:,2) == p2);
        
        loopLinks(1) = pairLoops(loopIndex);
        
        % Next if the punctures are not next to each other we also consider
        % the loop conecting the structure punctures by passing below all
        % punctures in between.
        
        if abs(p1-p2) ~= 1;
            loopIndex = find(pairLoopIndex(:,1) == p2 & pairLoopIndex(:,2) == p1);
            loopLinks(2) = pairLoops(loopIndex);
        else            
            loopLinks(2) = braidlab.loop(zeros(1,2*numPunc-4));
        end
        
        % We now consider the loop which connects the structure punctures
        % as if it was a straight line from puncture to puncture.  This is
        % done by the code LOOPLINE.
        
        loopLine = loopline(p1,p2,Xini_part);
        
        % The resulting loop from loopline will only be added if it is a
        % unique loop when compared to the other loops listed above
        
        if loopLine == loopLinks(1) || loopLine == loopLinks(2)
            loopLinks(3) = braidlab.loop(zeros(1,2*numPunc-4));
        else
            loopLinks(3) = loopLine;
        end
        
        % Finally we account for the case where the loops can wrap around
        % the end
                  
        loopLinks(4:7) = loopwrap(p1,p2,numPunc);
        
        % At this point the generator sequence is applied to the considered
        % loops.
        
        braidedLoopLinks = bs*loopLinks;
        
        % The number of interceptions are then calculated

        L = braidedLoopLinks.intaxis;
        
        % Cycle through each loop and see if it didn't grow.  There is a
        % threshold for what is considered to be not growing.  This is set
        % below by the user. If the loop is not growing it is saved to a
        % Dynnikov coordinate list (Dyn_set).  The way the loop is saved is
        % by the way the structure punctures are connected.  If the loop
        % connecting puncture 1 to 3 above doesn't grow 1+i3 is saved. If
        % the loop connecting puncture 1 to 3 from below doesn't grow 3+i1
        % is saved.  Finally if the loop directly connecting (from
        % loopline) doesn't grow 1-i3 is saved.              
        
        L_max = 10;
        
        mis = 0; % Number of dynnikov coordinates that are growing
        
        for j = 1:size(loopLinks,2)
            
            if L(j) > 0 && L(j) < L_max
            
                pmin = min(P_pair);
                pmax = max(P_pair);
                if j == 1
                    Dyn_set = [Dyn_set; P_pair(1)+1i*P_pair(2)];
                elseif j == 2                    
                    Dyn_set = [Dyn_set; P_pair(2)+1i*P_pair(1)];
                elseif j == 3
                    Dyn_set = [Dyn_set; pmin-1i*pmax];
                elseif j == 4              
                    Dyn_set = [Dyn_set; -pmin+1i*pmax];
                elseif j == 5
                    Dyn_set = [Dyn_set; -pmax+1i*pmin];
                elseif j == 6
                    Dyn_set = [Dyn_set; -pmin-1i*pmax];
                elseif j == 7
                    Dyn_set = [Dyn_set; -pmax-1i*pmin];
                end
                    P_connected(P_ind) = 1; % Add the lower index to the list of punctures that are connected
                    P_ind = P_ind + 1; % Move on to the next index of the list or punctures in the structure
                    P_try = 0*P_in; % Reset the list of punctures that have been tried to be connected
                    P_try(P_ind) = 1; 
                    s = 0;
            else
                mis = mis + 1;
            end
        end
        
        % If all the loops grow the code tries the next possible puncture
        % to connect to
        
        if mis == size(loopLinks,2)
            P_try(P_next) = 1;
            
            % Once all the punctures to the right have been tried the
            % switch is turned so that punctures to the left are tried
            
            if P_next == length(P_try)
                s = 1;
            end
        end
    
        
    % If all possible attempts are tried and none of them connect the puncture the code is terminated
    
    else
        kill = 1;
        break
    end
end

% At this point we have a list of ways that the loops are connected to each
% other in a way that punctures from outside the structure do not cause the
% loop to grow.  We scan the list of connections to make sure all side by
% side connections are listed the same way.

for i = 1:length(Dyn_set)
    if imag(Dyn_set(i))==real(Dyn_set(i))-1
        Dyn_set(i) = imag(Dyn_set(i))+1i*real(Dyn_set(i));
    end
end

% We then sort the list and make sure any repeated connections are removed.

Dyn_set = unique(Dyn_set); % This is a set of complex numbers representing the punctures and how they are connected

% We now convert the complex numbers in Dyn_set to a list of the number of
% times each puncture is involved in a connection, A, and a matrix
% containing the punctures involved in each connection and how they are
% connected, Dyn_set_matrix.

puncUseCount = 0*punctureAssignment;
Dyn_set_matrix = zeros(length(Dyn_set),3);

for i = 1:length(Dyn_set)
    puncUseCount(abs(imag(Dyn_set(i)))) = puncUseCount(abs(imag(Dyn_set(i))))+1;
    puncUseCount(abs(real(Dyn_set(i)))) = puncUseCount(abs(real(Dyn_set(i))))+1;
    Dyn_set_matrix(i,:) = [real(Dyn_set(i)) abs(imag(Dyn_set(i))) sign(real(Dyn_set(i))-abs(imag(Dyn_set(i))))];
end

% Get the Dynnikov coordinates for all the loops that simply connect a pair
% of punctures

[pairLoopsFull loopIndexFull] = p2ploop(length(punctureAssignment));

% Now we will cycle through all the connections and try to combine them to
% form one loop.

Dyn = 0*zeros(1,2*length(punctureAssignment)-4); % Dynnikov coordinates for the combined loop.

for i = 1:length(Dyn_set)
    
    % If the connection is a simply connected loop (not a lineloop)
    if real(Dyn_set(i))>0
        if imag(Dyn_set(i))>0
            p1 = real(Dyn_set(i));
            p2 = imag(Dyn_set(i));
            loopIndex = find(loopIndexFull(:,1)==p1 & loopIndexFull(:,2)==p2);

            linkDyn = pairLoopsFull(loopIndex).coords;

        % If the connection is a line loop

        else
            loopLine = loopline(real(Dyn_set(i)),abs(imag(Dyn_set(i))),Xini);
            linkDyn = loopLine.coords;
        end
    else
        loopWraps = loopwrap(abs(real(Dyn_set(i))),abs(imag(Dyn_set(i))),length(punctureAssignment));
        if abs(real(Dyn_set(i))) < abs(imag(Dyn_set(i)))
            if imag(Dyn_set(i)) < 0
                linkDyn = loopWraps(3).coords;
            else
                linkDyn = loopWraps(1).coords;
            end
        else
            if imag(Dyn_set(i)) < 0
                linkDyn = loopWraps(4).coords;
            else
                linkDyn = loopWraps(2).coords;
            end
        end
    end
    
    Dyn = Dyn + linkDyn;
end

% At this point we account for the fact that by adding all the coordinates
% together causes some overlap and the coordinates must be reduced to
% accurately reflect the connections.

if puncUseCount(1)>1
    Dyn(length(punctureAssignment)-2+1) = Dyn(length(punctureAssignment)-2+1) -1;
end
for i = 2:length(puncUseCount)-1
    if puncUseCount(i) > 2
        A_1 = find(Dyn_set_matrix(:,1)==i);
        Dir_1 = sign(Dyn_set_matrix(A_1,1)-Dyn_set_matrix(A_1,2));
        A_2 = find(Dyn_set_matrix(:,2)==i);
        Dir_2 = sign(Dyn_set_matrix(A_2,2)-Dyn_set_matrix(A_2,1));
        Dir = sum(Dir_1) + sum(Dir_2);
        if Dir<0
            Dyn(length(punctureAssignment)-2+i) = Dyn(length(punctureAssignment)-2+i) - 1;
            Dyn(length(punctureAssignment)-2+i-1) = Dyn(length(punctureAssignment)-2+i-1) + 1;
        else
            Dyn(length(punctureAssignment)-2+i-1) = Dyn(length(punctureAssignment)-2+i-1) - 1;
            Dyn(length(punctureAssignment)-2+i-2) = Dyn(length(punctureAssignment)-2+i-2) + 1;
        end
    end
end
if puncUseCount(end)>1
    Dyn(end) = Dyn(end) + 1;
end

nonGrowingLoop = braidlab.loop(Dyn);

braidedNonGrowingLoop = b*nonGrowingLoop;
L_test = braidedNonGrowingLoop.intaxis