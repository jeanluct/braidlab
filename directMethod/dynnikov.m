function Dyn = dynnikov(x_points,y_points,Xcoord,L_parameters)

%  The objective of DYNNIKOV is to convert the lines created in the code
%  loopdraw to the appropriate Dynnov Coordinates.  The inputs for the code
%  are x_points: the x-coordinates of the braids, y_points: the
%  y-coordinates of the braids, Xcoord: the coordinates of the verticies of
%  the drawn loop, and L_parameters: the defining parameters of each of the
%  lines drawn (x-range, slope, and intercept of the line).

%  Calculation of the number of points, number of lines, and the
%  x-coordinate of the mid point between braids

npoints = length(x_points);
N = length(Xcoord);

x_mids = zeros(1,npoints-1);

for i = 1:npoints-1
    x_mids(i) = (x_points(i)+x_points(i+1))/2;
end


%  Calculation of the mu values for the braid

mu = zeros(1,npoints*2-4);

for i = 1:N
    
    %  Determine if the i_th line passes a braid over its range
    
    t1 = x_points-L_parameters(i,1);
    t2 = x_points-L_parameters(i,2);
    t = sign(t1.*t2);
    
    %  If a braid has been passed it will register a negative one value in
    %  t
    
    if sum(t)<npoints
        
        %  Loops through the middle braids looking for a crossing
        
        for j = 2:npoints-1            
            if t(j) == -1      
                
                %  Given the i_th line has crossed the j_th braid
                %  x_coordinate it is now necessary to determine if the
                %  line passes in front or behind the braid.
                
                y_line = x_points(j)*L_parameters(i,3)+L_parameters(i,4);
                if y_line < y_points(j)
                    mu(2*j-2) = mu(2*j-2) + 1;
                elseif y_line > y_points(j)
                    mu(2*j-3) = mu(2*j-3) + 1;
                end
            end
        end
    end
end

%  Calculation of the v values for the loop

v = 0*x_mids;

%  Calculation of the range of braids which the loop surrounds 

mi = min(find(x_points>min(Xcoord(:,1))));
ma = max(find(x_points<max(Xcoord(:,1))));



for i = 1:N
    
    %  Determines if the i_th line passes through the midway point between
    %  two braids.
    
    t1 = x_mids(mi:ma-1)-L_parameters(i,1);
    t2 = x_mids(mi:ma-1)-L_parameters(i,2);    
    t = sign(t1.*t2);    
    if min(t)<0
        for j = 1:length(mi:ma-1)
            if t(j) < 0
                v(j+mi-1) = v(j+mi-1) + 1;
            end
        end
    end
end

%  Calculation of the reduced coordinate system

a = zeros(npoints-2,1);

for i = 1:npoints-2
    a(i) = (mu(2*i)-mu(2*i-1))/2;
end

b = 0*a;

for i = 1:npoints-2
    b(i) = (v(i)-v(i+1))/2;
end

Dyn = [a' b'];