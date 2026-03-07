% Test to dump all segment information
addpath(genpath('.'));
import braidlab.*

% Add a modified version of plot that dumps segment info
L = loop([3 2 1 0 -1 -2]);

% Manually call the geometry computation
% We'll have to replicate some code here for debugging

% First plot normally to trigger component computation
figure(1); clf;
h = plot(L,'Components',true);

fprintf('Plotted %d components\n',length(h));
xd2 = get(h(2),'XData');
yd2 = get(h(2),'YData');
fprintf('Component 2 endpoints: start=(%.4f,%.4f), end=(%.4f,%.4f)\n', ...
        xd2(1),yd2(1),xd2(end),yd2(end));
