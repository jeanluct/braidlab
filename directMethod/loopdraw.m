function Dyn = loopdraw(X)
 
%  This code creates a field of random points (X if designated) which a 
%  loop can be drawn around.  The user will be presented the points and
%  will be able to point and click where they would like to place the loop
%  vertices.
 
%  If the code is run without specified points a sample set of points will
%  be created.
 
if nargin < 1    
    npoints = 4;
    X = rand(npoints,2);
else
    npoints = length(X);
end
 
%  The coordinates of the points are now resorted so that they are in order
%  from lowest to greatest x value.  The x and y coordinates are then
%  separated into their own vectors.
 
X = sortrows(X);
x_points = X(:,1);
y_points = X(:,2);
 
%  A plot is now created containing all the points as well as vertical
%  dashed lines to give the user a reference while drawing the loop


figure(1)
plot(X(:,1),X(:,2),'x','MarkerSize',15,'LineWidth',2)
xlabel('X')
ylabel('Y')
axis([min(x_points)-.5 max(x_points)+.5 min(y_points)-.5 max(y_points)+.5])
hold on
 
for i = 1:npoints
    plot([X(:,1) X(:,1)],[min(y_points)-.5 max(y_points)+.5],'--k')
end
 
%  Matrices are then created which will store the coordinates of each
%  vertex (Xcoord), and the properties of each line connecting the
%  consecutive vertices (L_parameters).
 
Xcoord = [];
L_parameters = [];
 
N = 0;  %  Number of vertices
 
title({'Click on the figure to pick the next loop vertex.';'Press any key if you want to start over, undo, or finish'})
Xcurrent = ginput(1);
N = N + 1;
Xcoord = [Xcoord; Xcurrent];
 
%  The code will now loop through allowing the user to select more points
%  for the loop.  If the user wants to change something or finish the loop
%  they need to press a key.  They will then be presented options of what
%  they can do (clear, undo, or finish).
 
kill = 0;  % Parameter that when changed exits the loop creation
 
while kill == 0             
    keydown = waitforbuttonpress;  % Parameter which detects if a key has been hit to indicate a change needs to be made
    
    %  If no key is hit the user continues to create vertices for the loop
    
    if keydown == 0            
        Xcurrent = ginput(1); % User selects the next vertex
        N = N + 1; % Vertex counter increases
        Xcoord = [Xcoord; Xcurrent];  %  Vertex coordinates are stored
        if N>1        
            % A line connecting the current vertex and the previous one is
            % drawn.  The parameters of that line (starting x, ending x,
            % slope of the line, and projected x-intercept) are calculated
            % and stored.
            
            x1 = Xcoord(end-1,1); x2 = Xcoord(end,1); y1 = Xcoord(end-1,2); y2 = Xcoord(end,2);                                  
            line([x1 x2],[y1 y2]);  
            L_parameters = [L_parameters; x1 x2 (y2-y1)/(x2-x1) y1-(y2-y1)/(x2-x1)*x1];
        end
        
    %  If a key is struck the code will prompt the user to select what they
    %  would like to do
        
    else        
        reply = input('Clear (x), Undo (u),  or Finish (f): ','s');
        
        %  The user is given three options to clear the loop entirely and
        %  start over (Clear - 'x'), to undo the last vertex created (Undo
        %  - 'u') or to finish the loop (Finish - 'f').  Finishing the 
        %  loop does not require selecting the initial vertex.
        
        if reply == 'f'
            
            %  Finishing the loop will cause it to exit this while loop
            
            kill = 1;                      
            
        elseif reply == 'x'
            
            %  Clearing the loop will cause all previous vertex coordinates
            %  to be deleted and the figure will be redrawn without the
            %  loop.
            
            Xcoord = []
            N = 0;
            cla
            plot(X(:,1),X(:,2),'x','MarkerSize',15,'LineWidth',2)
            hold on
            for i = 1:npoints
                plot([X(:,1) X(:,1)],[0 1],'--k')
            end
            
        elseif reply == 'u'
            
            %  Undo will cause the selected coordinate to be dropped while
            %  keeping all previous coordinates.  The figure is redrawn to
            %  reflect the unmodified loop at points.
            
            Xcoord = Xcoord(1:end-1,:);
            L_parameters = L_parameters(1:end-1,:);
            N = N - 1;
            cla            
            plot(X(:,1),X(:,2),'x','MarkerSize',15,'LineWidth',2)
            hold on
            for i = 1:npoints
                plot([X(:,1) X(:,1)],[0 1],'--k')
            end
            for i = 1:N-1
                line([Xcoord(i,1) Xcoord(i+1,1)],[Xcoord(i,2) Xcoord(i+1,2)]);
            end                          
        end
    end  
end
 
%  At the conclusion of the while loop the final line is drawn connecting
%  the first and last vertex selected. The parameters for this 
 
x1 = Xcoord(end,1); x2 = Xcoord(1,1); y1 = Xcoord(end,2); y2 = Xcoord(1,2);
line([Xcoord(end,1) Xcoord(1,1)],[Xcoord(end,2) Xcoord(1,2)]);
L_parameters = [L_parameters; x1 x2 (y2-y1)/(x2-x1) y1-(y2-y1)/(x2-x1)*x1];
 
%  With the specified loop the appropriate Dynnikov coordinates are
%  calculate
 
Dyn = dynnikov(x_points,y_points,Xcoord,L_parameters);
 
%  With the Dynnikov coordinates the simplified loop is drawn using the
%  code loopplot
 
figure(2)
loopplot(Dyn);
 
%  Based on the simplified loop the user is now asked if this is the loop
%  they intended to draw.  If it is the code ends.  If it is not the user is
%  asked to adjust the loop they drew to possibly clear up potential
%  confusion in the code.

%  At this point the code is unable to detect loop intersections which are
%  illegal.  Also if the loop unnecessarily crosses one of the dashed lines
%  or a mid-point between points the calculated braid will be incorrect.
 
reply = input('Is this your loop? [y/n]: ','s')
 
while reply == 'n'
    
    %  If the desired loop is not presented the user is presented the
    %  opportunity to move the vertices one at a time to correct errors.
    %  The new loop will be shown over top of the old one and the user will
    %  be shown what the updated loop generated by loopplot looks like then
    %  have the opportunity to continue moving verticies till the desired
    %  one is found.
    
    
    disp('Select a point to move and select where you would like to move it')
    figure(1)
    xmove = ginput(1);
    d = sqrt((xmove(1)-Xcoord(:,1)).^2+(xmove(2)-Xcoord(:,2)).^2);
    i_move = find(d==min(d));
    xmove = ginput(1);
    Xcoord(i_move,:) = xmove;
    L_mod = L_parameters;
    for j = 1:N-1        
            x1 = Xcoord(j,1); x2 = Xcoord(j+1,1); y1 = Xcoord(j,2); y2 = Xcoord(j+1,2);
            l1 = line([x1 x2],[y1 y2]);
            set(l1,'Color','r')
            L_mod(j,:) = [x1 x2 (y2-y1)/(x2-x1) y1-(y2-y1)/(x2-x1)*x1];
    end
    x1 = Xcoord(end,1); x2 = Xcoord(1,1); y1 = Xcoord(end,2); y2 = Xcoord(1,2);
    l1 = line([Xcoord(end,1) Xcoord(1,1)],[Xcoord(end,2) Xcoord(1,2)]);
    set(l1,'Color','r')   
 
    L_parameters = L_mod;
    
    Dyn = dynnikov(x_points,y_points,Xcoord,L_parameters);
    
    figure(2)
    loopplot(Dyn)
 
    reply = input('Is this your loop? [y/n]: ','s')
    
    cla            
    plot(X(:,1),X(:,2),'x','MarkerSize',15,'LineWidth',2)
    hold on
    for i = 1:npoints
        plot([X(:,1) X(:,1)],[0 1],'--k')
    end
    for i = 1:N-1
        line([Xcoord(i,1) Xcoord(i+1,1)],[Xcoord(i,2) Xcoord(i+1,2)]);
    end  
    line([Xcoord(N,1) Xcoord(1,1)],[Xcoord(N,2) Xcoord(1,2)]);
end

