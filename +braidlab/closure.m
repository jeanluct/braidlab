function XYc = closure(XY,ctype)
%CLOSURE   Force closure of a set of trajectories to make a physical braid.
%   XYC = CLOSURE(XY) or XYC = CLOSURE(XY,'Xproj') takes the particle
%   trajectory data in XY and appends the initial positions to the end of
%   the list, in the correct order so that no new crossings are created
%   (when projected along the X axis).  The data format is
%   XY(TIMESTEP,COORD,PARTICLES).
%
%   XYC = CLOSURE(XY,PERM) closes the braid so that final points are
%   linked according to permutation PERM.
%
%   See also BRAID, BRAID.BRAID.

% Currently, the method of closure is tightly related to the axis of
% projection.  A better method might be to minimize the L^2 norm of
% distances between the final points and the starting points.

if nargin < 2
  ctype = 'Xproj';
end

XYnew = zeros(size(XY(1,:,:)));

if ~isstr(ctype)
  if length(unique(ctype)) ~= length(ctype)
    error('BRAIDLAB:closure:badarg','Second argument must be a permutation.')
  end
  XYnew(1,:,:) = XY(1,:,ctype);
else
  switch lower(ctype)
   case 'xproj'
    % Find the initial order of the particles.
    [~,I0] = sort(squeeze(XY(1,1,:)));
    % Find the final order of the particles.
    [~,I1] = sort(squeeze(XY(end,1,:)));
    XYnew(1,:,I1) = XY(1,:,I0);
   case 'yproj'
    % Find the initial order of the particles.
    [~,I0] = sort(squeeze(XY(1,2,:)));
    % Find the final order of the particles.
    [~,I1] = sort(squeeze(XY(end,2,:)));
    XYnew(1,:,I1) = XY(1,:,I0);
   case 'mindist'
    n = size(XY,3);
    X0 = XY(1,:,:);
    X1 = XY(end,:,:);
    for i = 1:n
      for j = 1:n
	D(i,j) = norm(X1(:,i)-X0(:,j));
      end
    end
    if false
      [perm,dist] = assignmentoptimal(D);
      XYnew(1,:,:) = XY(1,:,perm);
    else
      f = D(:);
      Aeq1 = zeros(n,n,n); Aeq2 = zeros(n,n,n);
      for i = 1:n
	for k = 1:n
	  for l = 1:n
	    if i == k, Aeq1(i,k,l) = 1; end
	  end
	end
      end
      for j = 1:n
	for k = 1:n
	  for l = 1:n
	    if j == l, Aeq2(j,k,l) = 1; end
	  end
	end
      end
      Aeq = zeros(2*n,n^2);
      for i = 1:n
	Aeq(i,:) = Aeq1(i,:);
	Aeq(i+n,:) = Aeq2(i,:);
      end
      beq = ones(2*n,1);
      lb = zeros(n^2,1);
      ub = ones(n^2,1);
      [x,dist,exitflag] = linprog(f,[],[],Aeq,beq,lb,ub);
      D
      x = reshape(x,[n n])
      sum(x,1)
      sum(x,2)
      round(x)
      dist
      exitflag
      keyboard
    end
   otherwise
    error('BRAIDLAB:closure:badarg','Unknown closure type.')
  end
end

XYc = [XY; XYnew];
