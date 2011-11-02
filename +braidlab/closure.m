function XYc = closure(XY)
%CLOSURE   Force closure of a set of trajectories to make a physical braid.
%   XYC = CLOSURE(XY) takes the particle trajectory data in XY and appends
%   the initial positions to the end of the list, in the correct order so
%   that no new crossings are created (when projected along the X axis).
%   The data format is XY(TIMESTEP,COORD,PARTICLES).
%
%   See also BRAID, BRAID.BRAID.

% Currently, the method of closure is tightly related to the axis of
% projection.  A better method might be to minimize the L^2 norm of
% distances between the final points and the starting points.

% Find the initial order of the particles.
[~,I0] = sort(squeeze(XY(1,1,:)));
% Find the final order of the particles.
[~,I1] = sort(squeeze(XY(end,1,:)));

XYnew = zeros(size(XY(1,:,:)));
XYnew(1,:,I1) = XY(1,:,I0);

XYc = [XY; XYnew];
