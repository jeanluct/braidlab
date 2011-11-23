function plot(L,colr,X,prad)
%PLOT   Plot a loop.
%   PLOT(L,COLOR,X,PRAD) plots a representative of the equivalence class
%   define by the loop L.  COLOR may be speficied optionally, as well as the
%   position X of the punctures (default integers).  strings. Position of
%   the punctures can also be selected by inputing their positions as X.
%   The default is to have them at integer values along the x-axis.  The
%   puncture radius can be set with PRAD, otherwise the code selects the
%   best size for a given loop.
%
%   This is a method for the LOOP class.
%   See also LOOP.

if ishold
  holdstate = true;
else
  holdstate = false;
  clf reset
end

n = L.n;
lw = 2; % default line width

if nargin < 2, colr = 'b'; end

if nargin < 3
  X = [(1:n)' 0*(1:n)'];
end

Xs = sortrows(X);

if n ~= length(X)
  error('BRAIDLAB:loop:badlen','Length of X does not match loop.')
end

d = zeros(size(Xs,1)-1,1);
for i = 1:n-1
  d(i) = sqrt((Xs(i,1)-Xs(i+1,1))^2+(Xs(i,2)-Xs(i+1,2))^2);
end

[a,b] = L.ab;

% Convert Dynnikov coding to intersection numbers.
[mu,nu] = L.intersec;

% Extend the coordinates.
B = [-nu(1)/2 b nu(end)/2];
A = [0 a 0];

% Convert to older P,M,N notation.
P = nu/2;
M = [nu(1)/2 mu(2*(1:(n-2))-1) nu(n-1)/2];
N = [nu(1)/2 mu(2*(1:(n-2))) nu(n-1)/2];
b = B;
a = A;

% The gap between lines.
% (clarify: gap vs pgap?)
% TODO: Keep punctures same size (need special gap near x-axis).
gap = zeros(size(d));
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

if nargin < 4
  prad = .15*min(gap);
end

if prad > min(gap)
  error('BRAIDLAB:loop:badrad', ...
        ['Puncture radius is too large.  For this loop the value' ...
         'can''t exceed %f.'],min(gap))
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
  hold on
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
    plot(Xs(p,1)+[xx xx(end:-1:1)],Xs(p,2)+[yy1 yy2],colr,'LineWidth',lw)    
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
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],colr,'LineWidth',lw)
    end
    % The lines that join upwards (on the same side).
    for s = tojoindown+1:tojoin
      y1 = pgap(p)*(nr+s)+Xs(p,2);
      y2 = pgap(p+1)*(nl+s - (tojoin-tojoinup))+Xs(p+1,2);
      %if y2 <= gap*nl; y2 = -gap*(nl+3-s); end
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],colr,'LineWidth',lw)
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
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],colr,'LineWidth',lw)
    end
    % The lines that join downwards (on the same side).
    for s = tojoinup+1:tojoin
      y1 = -pgap(p)*(nr+s)+Xs(p,2);
      y2 = -pgap(p+1)*(nl+s - (tojoin-tojoindown))+Xs(p+1,2);
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],colr,'LineWidth',lw)
    end
  end
end

if ~holdstate
  hold off
  axis equal
  axis off
end
