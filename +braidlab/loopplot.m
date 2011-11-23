function loopplot(Dyn,color,X,prad)

% LOOPPLOT(DYN,COLOR,X,PRAD) is a function which produces the simplified
% loop plot for a given Dynnikov coordinate, DYN.  The user has the option
% to change the loop color from the default by using the standard plot
% color strings. Position of the punctures can also be selected by inputing
% their positions as X.  The default is to have them at integer values
% along the x-axis.  Finally the puncture radius can be set with prad,
% otherwise the code selects the best size for a given loop.

% The code begins with breaking the Dynnikov coordinates into the PMN
% coordinates then uses these values to determine where the lines that make
% up the loop are and how to connect them.

if nargin < 1
  % Sample loop.
  Dyn = [ 1 0   2 0 ];
end

n = (size(Dyn,2)+4)/2;

if nargin<2
    color = 'b';
end

if nargin<3
    X = [(1:n)' 0*(1:n)'];
end

Xs = sortrows(X);

if floor(n)~=n
    error('There must be an even number of Dynnikov coordinates');
end
if n~=size(X,1)
    error('Number of points does not match Dynnikov coordinates');
end

d = zeros(size(Xs,1)-1,1);

for i = 1:n-1
    d(i) = sqrt((Xs(i,1)-Xs(i+1,1))^2+(Xs(i,2)-Xs(i+1,2))^2);
end

a = Dyn(:,1:n-2);
b = Dyn(:,(n-1):end);

% Convert Dynnikov coding to crossing numbers.
% (make a new dynn2cross function)
cumb = [zeros(size(Dyn,1),1) cumsum(b,2)];
% The number of intersections before/after the first and last punctures.
% See Hall & Yurttas (2009).
b0 = -max(abs(a) + max(b,0) + cumb(:,1:end-1),[],2);
bn = -b0 - sum(b,2);
% Extend the coordinates.

B = [b0 b bn];
A = zeros(size(a,1),size(a,2)+2);
A(:,2:end-1) = a;
% Find nu, mu (crossing numbers).
nu(1) = -2*b0;
for i = 2:n-1
  nu(i) = nu(i-1) - 2*B(i-1 + 1);
end
for i = 1:2*n-4
  ic = ceil(i/2);
  mu(i) = (-1)^i * A(ic + 1);
  if B(ic + 1) >= 0
    mu(i) = mu(i) + nu(ic)/2;
  else
    mu(i) = mu(i) + nu(ic+1)/2;
  end
end

% Convert to older P,M,N notation.
P = nu/2;
M = [nu(1)/2 mu(2*(1:(n-2))-1) nu(n-1)/2];
N = [nu(1)/2 mu(2*(1:(n-2))) nu(n-1)/2];
b = B;
a = A;

gap = 0*d;

for i = 1:n-1
    gap(i) = min(d(i)/M(i),d(i)/N(i))*.7;
end

pgap = zeros(n,1);

pgap(1) = gap(1);
pgap(end) = gap(end);

for i = 2:n-1
    pgap(i) = min(gap(i),gap(i-1));
end

pgap = min(pgap)/2+zeros(n,1);

hold on

if nargin<4
    prad = .15*min(gap);
end

if prad > min(gap)
    error(['Puncture radius is too large.  For this loop the value can' ...
           ' not exceed ' num2str(min(gap)) '.']);
end

% Draw punctures.
for p = 1:n
  x = p;
  rad = .15*gap;
  xx = linspace(-prad,prad,100);
  yy1 = sqrt(prad^2 - xx.^2);
  yy2 = -sqrt(prad^2 - xx(end:-1:1).^2);
  col = 'r-';
  patch(Xs(p,1)+[xx xx(end:-1:1)],Xs(p,2)+[yy1 yy2],col)
end

% Draw semicircles.
for p = 1:n
  if p == n
    nl = M(n);
  else
    nl = b(p);
  end
  x = p;
  for sc = 1:abs(nl)
    rad = sc*pgap(p);
    xx = sign(nl)*linspace(0,rad,50);
    yy1 = sqrt(rad^2 - xx.^2);
    yy2 = -sqrt(rad^2 - xx(end:-1:1).^2);
    plot(Xs(p,1)+[xx xx(end:-1:1)],Xs(p,2)+[yy1 yy2],color,'LineWidth',2)    
  end
end

% Draw the upper part of the loop.
for p = 1:n-1
  x = p;

  % How many right-semicircles (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(b(p),0);
  end
  tojoin = M(p)-nr;

  if tojoin > 0
    % How many left-semicircles (b<0) around the next puncture?
    if p < n-1
      nl = -min(b(p+1),0);
    else
      nl = 0;
    end
    % We can't joint to these left-facing loops from the left.
    tojoinup = M(p+1)-nl;
    tojoindown = max(tojoin-tojoinup,0);
    %keyboard
    % The lines that join downwards.
    for s = 1:tojoindown
      y1 = pgap(p)*(nr+s)+Xs(p,2);
      y2 = -pgap(p+1)*(nl-s+tojoindown+1)+Xs(p+1,2);
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],color,'LineWidth',2)
    end
    % The lines that join upwards (on the same side).
    for s = tojoindown+1:tojoin
      y1 = pgap(p)*(nr+s)+Xs(p,2);
      y2 = pgap(p+1)*(nl+s - (tojoin-tojoinup))+Xs(p+1,2);
      %if y2 <= gap*nl; y2 = -gap*(nl+3-s); end
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],color,'LineWidth',2)
    end
  end
end


for p = 1:n-1
  x = p;

  % How many right-semicircles (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(b(p),0);
  end
  tojoin = N(p)-nr;

  if tojoin > 0
    % How many left-semicircles (b<0) around the next puncture?
    if p < n-1
      nl = -min(b(p+1),0);
    else
      nl = 0;
    end
    % We can't joint to these left-facing loops from the left.
    tojoindown = N(p+1)-nl;
    tojoinup = max(tojoin-tojoindown,0);
    % The lines that join upwards.
    for s = 1:tojoinup
      y1 = -pgap(p)*(nr+s)+Xs(p,2);
      y2 = pgap(p+1)*(nl-s+tojoinup+1)+Xs(p+1,2);
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],color,'LineWidth',2)
    end
    % The lines that join downwards (on the same side).
    for s = tojoinup+1:tojoin
      y1 = -pgap(p)*(nr+s)+Xs(p,2);
      y2 = -pgap(p+1)*(nl+s - (tojoin-tojoindown))+Xs(p+1,2);
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],color,'LineWidth',2)
    end
  end
end
