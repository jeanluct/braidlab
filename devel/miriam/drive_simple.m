function [ yt ] = drive_simple( t,y )
% Driver takes the form of f(t)F(x,y)
yt=zeros(size(y));

 L=12*pi ; % Period of the twisting.
 t1=mod(t,L); % set time to be modulo one period so driver can be applied for any desired length of time. 
 
 %Set Vx, (yt(1,:)) and Vy, (yt(2,:)) over different stages of the driver.

 if 0 < t1 && t1 < pi
     yt(1,:) = (0.075-0.075*cos(t1))*y(2,:)*exp((-(y(1,:))^2 -(y(2,:))^2)/2);
     yt(2,:) = -(0.075-0.075*cos(t1))*y(1,:)*exp((-(y(1,:))^2 -(y(2,:))^2)/2);
 elseif pi <t1 && t1 < 11*pi
     yt(1,:) =0.15*y(2,:)*exp((-(y(1,:))^2 -(y(2,:))^2)/2);
     yt(2,:) = -0.15*y(1,:)*exp((-(y(1,:))^2 -(y(2,:))^2)/2);
 elseif 11*pi < t1 && t1 < L
      yt(1,:) = (0.075-0.075*cos(t1))*y(2,:)*exp((-(y(1,:))^2 -(y(2,:))^2)/2);
     yt(2,:) = -(0.075-0.075*cos(t1))*y(1,:)*exp((-(y(1,:))^2 -(y(2,:))^2)/2); 
 end
 
end

