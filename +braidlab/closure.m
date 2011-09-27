function [varargout] = closure(XY,t)
%CLOSURE   Force closure of a set of trajectories to make a physical braid.
%   XYC = CLOSURE(XY) takes the particle trajectory data in XY and appends
%   the initial positions to the end of the list, in the correct order so
%   that no new crossings are created (when projected along the X axis).
%   The data format is XY(TIMESTEP,COORD,PARTICLES).
%
%   [XYC,TC] = CLOSURE(XY,T) appends an extra time to the time vector T,
%   based on the spacing from the previous timestep, and returns the new
%   vector as TC.
%
%   See also COLOR_BRAIDING.

% Currently, the method of closure is tightly related to the axis of
% projection.  A better method might be to minimize the L^2 norm of
% distances between the final points and the starting points.

% Find the initial order of the particles.
[X,I0] = sort(squeeze(XY(1,1,:)));
% Find the final order of the particles.
[X,I1] = sort(squeeze(XY(end,1,:)));

XYnew = zeros(size(XY(1,:,:)));
XYnew(1,:,I1) = XY(1,:,I0);

varargout{1} = [XY; XYnew];

if nargin > 1
  if nargout > 1
    % Rigmarole to make sure t remains a row or column vector.
    ts = size(t); ts = ts + (ts ~= 1);
    t = reshape(t,[length(t) 1]);
    % Append an extra t(end), so now t(end) is repeated twice.
    varargout{2} = reshape([t ; t(end)],ts);
    % Modify the second-to last time, to avoid changing the total time
    % interval.
    varargout{2}(end-1) = t(end) - (t(end)-t(end-1))/2;
  else
    error('BRAIDLAB:closure','Not enough output arguments.')
  end
end
