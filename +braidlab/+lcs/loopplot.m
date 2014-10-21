 function loopplot(loop,Xcoord)
%LOOPPLOT   Plot a loop.
%   LOOPPLOT(U) makes a plot of a loop.  The loop is assumed to be in
%   Dynnikov coding form U = [a(1),...,a(n-2),b(1),...,b(n-2)].

Xcoord = sortrows(Xcoord);

hold on

% Number of punctures.
n = loop.n;
a = loop.a;
b = loop.b;

% Convert Dynnikov coding to crossing numbers.
% (make a new dynn2cross function)
cumb = [zeros(size(loop,1),1) cumsum(b,2)];
% The number of intersections before/after the first and last punctures.
% See Hall & Yurttas (2009).
b0 = -max(abs(a) + max(b,0) + cumb(:,1:end-1),[],2);
bn = -b0 - sum(b,2);
% Extend the coordinates.
B = [b0 b bn];
A = [0 a 0];

% Convert to older P,M,N notation.
[mu, nu] = loop.intersec;

M = [nu(:,1)/2 mu(:,1:2:end) nu(:,n-1)/2];
N = [nu(:,1)/2 mu(:,2:2:end) nu(:,n-1)/2];

% How many segments on each side?  Take the max.  This will
% determine the 'gap size'.
maxmax = max(max(M),max(N));
  gap = .5/(maxmax+1);

% Draw punctures.
for p = 1:n
  x = p;
  rad = .15*gap;
  xx = linspace(-rad,rad,100);
  yy1 = sqrt(rad^2 - xx.^2);
  yy2 = -sqrt(rad^2 - xx(end:-1:1).^2);
  col = 'r-';
  patch(Xcoord(p,1)+[xx xx(end:-1:1)],Xcoord(p,2)+[yy1 yy2],col)
end

% Draw semicircles.
for p = 1:n
  if p == n
    nl = M(n);
  else
    nl = B(p);
  end
  x = p;
  for sc = 1:abs(nl)
    rad = sc*gap;
    xx = sign(nl)*linspace(0,rad,50);
    yy1 = sqrt(rad^2 - xx.^2);
    yy2 = -sqrt(rad^2 - xx(end:-1:1).^2);
    plot(Xcoord(p,1)+[xx xx(end:-1:1)],Xcoord(p,2)+[yy1 yy2],'-')    
  end
end

% Draw the upper part of the loop.
for p = 1:n-1
  x = p;

  % How many right-semicircles (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(B(p),0);
  end
  tojoin = M(p)-nr;

  if tojoin > 0
    % How many left-semicircles (b<0) around the next puncture?
    if p < n-1
      nl = -min(B(p+1),0);
    else
      nl = 0;
    end
    % We can't joint to these left-facing loops from the left.
    tojoinup = M(p+1)-nl;
    tojoindown = max(tojoin-tojoinup,0);
    %keyboard
    % The lines that join downwards.
    for s = 1:tojoindown
      y1 = gap*(nr+s)+Xcoord(p,2);
      y2 = -gap*(nl-s+tojoindown+1)+Xcoord(p+1,2);
      plot([Xcoord(p,1) Xcoord(p+1,1)],[y1 y2],'-')
    end
    % The lines that join upwards (on the same side).
    for s = tojoindown+1:tojoin
      y1 = gap*(nr+s)+Xcoord(p,2);
      y2 = gap*(nl+s - (tojoin-tojoinup))+Xcoord(p+1,2);
      %if y2 <= gap*nl; y2 = -gap*(nl+3-s); end
      plot([Xcoord(p,1) Xcoord(p+1,1)],[y1 y2],'-')
    end
  end
end

% Now draw the lower part of the loop.
for p = 1:n-1
  x = p;

  % How many right-semicircles (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(B(p),0);
  end
  tojoin = N(p)-nr;

  if tojoin > 0
    % How many left-semicircles (b<0) around the next puncture?
    if p < n-1
      nl = -min(B(p+1),0);
    else
      nl = 0;
    end
    % We can't joint to these left-facing loops from the left.
    tojoindown = N(p+1)-nl;
    tojoinup = max(tojoin-tojoindown,0);
    % The lines that join upwards.
    for s = 1:tojoinup
      y1 = -gap*(nr+s)+Xcoord(p,2);
      y2 = gap*(nl-s+tojoinup+1)+Xcoord(p+1,2);
      plot([Xcoord(p,1) Xcoord(p+1,1)],[y1 y2],'-')
    end
    % The lines that join downwards (on the same side).
    for s = tojoinup+1:tojoin
      y1 = -gap*(nr+s)+Xcoord(p,2);
      y2 = -gap*(nl+s - (tojoin-tojoindown))+Xcoord(p+1,2);
      plot([Xcoord(p,1) Xcoord(p+1,1)],[y1 y2],'-')
    end
  end
end

hold off
% axis equal
axis off
axis tight
