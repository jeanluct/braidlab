function [varargout] = gencross(t,X,Y)
%GENCROSS   Find braid generators from crossings of trajectories.
%   G = GENCROSS(T,X,Y) finds the braid group generators associated with
%   crossings of particle trajectories.  Here T is a column vector of times,
%   and X and Y are coordinates of particles at those times.  X and Y have
%   the same number of rows as T, and N columns, where N is the number of
%   particles.  A projection on the X axis is used to define crossings.
%
%   [G,TC] = GENCROSS(T,X,Y) also returns a vector of times TC when the
%   crossings occurred.

import braidlab.interpcross

% Find the permutation at each time.
[Xperm,Iperm] = sort(X,2);
dperm = diff(Iperm,1);     % Crossings occur when the permutation changes.
icr = find(any(dperm,2));  % Index of crossings.
gen = []; tcr = [];

for i = 1:length(icr)
  % Order (from left to right) of particles involved in crossing.
  igen = find(dperm(icr(i),:));
  j = 1;
  while j < length(igen)
    if ~sum(dperm(icr(i),igen(j:j+1)))
      %
      % Crossing involves a pair of particles.
      %
      p = Iperm(icr(i),igen(j:j+1));  % The two particles involved in crossing.
      [tt,dY] = interpcross(t,X,Y,icr(i),p(1),p(2));
      tcr = [tcr;tt]; gen = [gen; igen(j)*dY];
      j = j+2;

    elseif ~sum(dperm(icr(i),igen(j:j+2)))
      %
      % Crossing involves a triplet of particles.
      % Two cases are possible:
      %
      if Iperm(icr(i),igen(j)) == Iperm(icr(i)+1,igen(j)+1)
        % Case 1: ABC -> CAB

        % Particles B&C cross first
        p = Iperm(icr(i),igen([j+1 j+2]));
        [tt,dY] = interpcross(t,X,Y,icr(i),p(1),p(2));
        tcr = [tcr;tt]; gen = [gen; igen(j+1)*dY];

        % Particles A&C cross second
        p = Iperm(icr(i),igen([j j+2]));
        [tt,dY] = interpcross(t,X,Y,icr(i),p(1),p(2));
        tcr = [tcr;tt]; gen = [gen; igen(j)*dY];
      elseif Iperm(icr(i),igen(j)) == Iperm(icr(i)+1,igen(j)+2)
        % Case 2: ABC -> BCA

        % Particles A&B cross first
        p = Iperm(icr(i),igen([j j+1]));
        [tt,dY] = interpcross(t,X,Y,icr(i),p(1),p(2));
        tcr = [tcr;tt]; gen = [gen; igen(j)*dY];

        % Particles A&C cross second
        p = Iperm(icr(i),igen([j j+2]));
        [tt,dY] = interpcross(t,X,Y,icr(i),p(1),p(2));
        tcr = [tcr;tt]; gen = [gen; igen(j+1)*dY];
      else
        error('BRAIDLAB:gencross:badtriple', ...
	      'Something''s wrong with triple crossing -- increase resolution.')
      end
      j = j+3;
    else
      error('BRAIDLAB:gencross:toomanycrossings', ...
	    'Too many simultaneous crossings -- increase resolution.')
    end
  end
end
varargout{1} = gen;
if nargout > 1, varargout{2} = tcr; end
