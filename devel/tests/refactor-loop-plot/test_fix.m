% Quick test of the fixed segment joining
addpath(genpath('.'));
import braidlab.*

% Simple test loop
L = loop([1 0 0 0]);

figure(1); clf;
h = plot(L);
title('Test: Simple loop [1 0 0 0] - AFTER FIX');

% Check the coordinates
xd = get(h(1),'XData');
yd = get(h(1),'YData');

disp(['Number of points: ' num2str(length(xd))]);
disp(['First point: (' num2str(xd(1)) ', ' num2str(yd(1)) ')']);
disp(['Last point: (' num2str(xd(end)) ', ' num2str(yd(end)) ')']);
disp(['Loop closed: ' num2str(abs(xd(1)-xd(end)) < 0.01 && abs(yd(1)-yd(end)) < 0.01)]);

saveas(gcf,'test_fix1.png');

% Test with components
figure(2); clf;
L2 = loop([2 1 -1 0]);
h2 = plot(L2,'Components',true);
title('Test: Loop with components [2 1 -1 0] - AFTER FIX');

saveas(gcf,'test_fix2.png');

disp('Tests completed. Check test_fix1.png and test_fix2.png');
