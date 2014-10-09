function loop = loopline(P1,P2,Xini)

% DYN = LOOPLINE(P1,P2,XINI) is a code which creates the Dynnikov
% coordinates for the loop corresponding to the straight line connecting
% two points, DYN.  The set of points in their position is given by XINI.  The
% two points that are connected are the P1 and P2 punctures when the
% punctures are sorted.

% Sort initial conditions based on the x-coordinate

Xini = sortrows(Xini);

% Reset the indecies so that the value of p1 is less than p2.

p1 = min(P1,P2);
p2 = max(P1,P2);

N = size(Xini,1); % Number of punctures

X1 = Xini(p1,:); % Position of the p1-puncture
X2 = Xini(p2,:); % Position of the p2-puncture

% Get the paramters for the line connecting the two punctures (slope, and
% intercept)

m = (X2(2)-X1(2))/(X2(1)-X1(1));
b = X1(2)-m*X1(1);

% Create a position vector which tracks if the point is above or below the
% line connecting the selected punctures

pos = [];

% Loop through all the other punctures to determine where they are with
% respect to the line 

for i = p1+1:p2-1
    y = m*Xini(i,1)+b;
    
    % Only consider punctures which have an x-coordinate between the two
    % selected punctures
    
    if Xini(i,2)>y
        pos = [pos 1];
    else
        pos = [pos -1];
    end
end

% Creation of the corresponding Dynnikov coordinate

Dyn = zeros(1,2*N-4);

% Input the contribution of points being above or below the line

Dyn((p1+1:p2-1)-1) = pos;

% Input the contribution of the loop being before or after the selected
% punctures.  This contribution to the Dynnikov coordinate only occurs if
% the selected puncture is not either the first or last puncture.

if p1~=1
    Dyn(p1+N-2-1) = -1;
end
if p2~=N
    Dyn(p2+N-2-1) = 1;
end

loop = braidlab.loop(Dyn);