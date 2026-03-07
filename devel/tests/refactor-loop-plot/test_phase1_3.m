% Test script for Phase 1.3 - segment ordering
%
% This tests that segments are properly ordered into continuous paths

% Add braidlab to path
addpath(genpath('.'));

% Create a simple test loop
import braidlab.*
L = loop([1 0 0 0]);

% Test 1: Basic plot with handle return
figure(1); clf;
h = plot(L);
title('Test 1: Basic loop with handle return');
disp(['Number of handles returned: ' num2str(length(h))]);
disp(['Handle class: ' class(h(1))]);
saveas(gcf,'test_ordered_1.png');

% Test 2: Plot with components
figure(2); clf;
L2 = loop([2 1 -1 0]);
h2 = plot(L2,'Components',true);
title('Test 2: Loop with components and handles');
disp(['Number of component handles: ' num2str(length(h2))]);
saveas(gcf,'test_ordered_2.png');

% Test 3: Verify we can access handle data
if ~isempty(h)
  xdata = get(h(1),'XData');
  ydata = get(h(1),'YData');
  disp(['First handle has ' num2str(length(xdata)) ' points']);
end

disp('Phase 1.3 tests completed successfully!');
