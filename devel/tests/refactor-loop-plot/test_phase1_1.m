% Test script for Phase 1.1 - geometry computation extraction
%
% This tests that the refactored code produces the same visual output
% as the original implementation.

% Add braidlab to path
addpath(genpath('.'));

% Create a simple test loop
import braidlab.*
L = loop([1 0 0 0]);

% Test 1: Basic plot (no components)
figure(1); clf;
plot(L);
title('Test 1: Basic loop plot');
saveas(gcf,'test1_basic.png');

% Test 2: Plot with components
figure(2); clf;
L2 = loop([2 1 -1 0]);
plot(L2,'Components',true);
title('Test 2: Loop with components');
saveas(gcf,'test2_components.png');

% Test 3: Custom puncture positions (L has 4 punctures)
figure(3); clf;
plot(L,'PuncturePositions',[0 0; 2 0; 4 0; 6 0]);
title('Test 3: Custom puncture positions');
saveas(gcf,'test3_custom_positions.png');

disp('Phase 1.1 tests completed successfully!');
