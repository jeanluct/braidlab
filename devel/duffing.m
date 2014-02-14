function yr = duffing(t,y)

global delta gamma

Xr = y(1,:);
Yr = y(2,:);

Omega = 1/6;

X = Xr.*cos(Omega.*t)+Yr.*sin(Omega.*t);
Y = -Xr.*sin(Omega.*t)+Yr.*cos(Omega.*t);

delta = .08; gamma = .14; omega = 1;

Xp = Y +.1*cos(omega*t);
Yp = X.*(1-X.^2)+gamma.*cos(omega*t)-delta*Y;

Xdotr = Xp.*cos(Omega*t)-X*Omega*sin(Omega*t)-Yp.*sin(Omega*t)-Y*Omega*cos(Omega*t);
Ydotr = Xp.*sin(Omega*t)+X*Omega*cos(Omega*t)+Yp.*cos(Omega*t)-Y*Omega*sin(Omega*t);
   
yr = zeros(size(y));
yr(1,:) = Xdotr;
yr(2,:) = Ydotr;