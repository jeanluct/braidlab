function loops = loopwrap(p1,p2,N)

% DYN = LOOPLINE(P1,P2,XINI) is a code which creates the Dynnikov
% coordinates for the loop corresponding to the straight line connecting
% two points, DYN.  The set of points in their position is given by XINI.  The
% two points that are connected are the P1 and P2 punctures when the
% punctures are sorted.

% Reset the indecies so that the value of p1 is less than p2.

P1 = min(p1,p2);
P2 = max(p1,p2);

% Creation of the corresponding Dynnikov coordinate

Dyn = zeros(4,2*N-4);

% If the loops have to wrap around the right end

if P2~=N

    % Account for the portion of the loop that passes over or below the points
    Dyn(1,P1:P2-1) = 1;
    Dyn(2,P1:P2-1) = -1;

    % Account for the start and end of the loop
    Dyn(1:2,N+P1-3) = -1;
    Dyn(1:2,N+P2-3) = -1;

end

% If the loops have to wrap around the left end

if P1~=1    
    Dyn(3,1:N-2) = Dyn(1,N-2:-1:1);
    Dyn(4,1:N-2) = Dyn(2,N-2:-1:1);
    Dyn(3,N-1:end) = -Dyn(1,end:-1:N-1);
    Dyn(4,N-1:end) = -Dyn(2,end:-1:N-1);    
end

loops = braidlab.loop(Dyn);