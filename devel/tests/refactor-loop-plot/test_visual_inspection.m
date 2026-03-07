% Visual inspection test for loop plot refactoring
%
% This script creates several test plots and waits for user feedback
% before closing. Press any key in the command window to advance to the
% next plot.

% Add braidlab to path
addpath(genpath('.'));

import braidlab.*

%% Test 1: Simple loop
disp('==========================================================');
disp('Test 1: Simple loop - loop([1 0 0 0])');
disp('Expected: A simple closed curve around punctures');
disp('==========================================================');

figure(1); clf;
L1 = loop([1 0 0 0]);
h1 = plot(L1);
title('Test 1: Simple loop [1 0 0 0]');
xlabel('Press any key to continue...');

disp(['Number of handles: ' num2str(length(h1))]);
disp(['Number of points in curve: ' num2str(length(get(h1(1),'XData')))]);
disp(' ');
disp('Does this plot look correct? (Check the loop is continuous and closed)');
pause

%% Test 2: Loop with components
disp('==========================================================');
disp('Test 2: Loop with multiple components - loop([2 1 -1 0])');
disp('Expected: Multiple colored components');
disp('==========================================================');

figure(2); clf;
L2 = loop([2 1 -1 0]);
h2 = plot(L2,'Components',true);
title('Test 2: Loop with components [2 1 -1 0]');
xlabel('Press any key to continue...');

disp(['Number of component handles: ' num2str(length(h2))]);
for i = 1:length(h2)
  disp(['  Component ' num2str(i) ': ' num2str(length(get(h2(i),'XData'))) ' points']);
end
disp(' ');
disp('Does this plot look correct? (Check components have different colors)');
pause

%% Test 3: More complex loop
disp('==========================================================');
disp('Test 3: More complex loop - loop([3 2 1 0 -1])');
disp('Expected: More intricate pattern');
disp('==========================================================');

figure(3); clf;
L3 = loop([3 2 1 0 -1]);
h3 = plot(L3);
title('Test 3: Complex loop [3 2 1 0 -1]');
xlabel('Press any key to continue...');

disp(['Number of handles: ' num2str(length(h3))]);
disp(['Number of points in curve: ' num2str(length(get(h3(1),'XData')))]);
disp(' ');
disp('Does this plot look correct?');
pause

%% Test 4: Same complex loop with components
disp('==========================================================');
disp('Test 4: Same complex loop with components');
disp('Expected: Multiple colored components showing topology');
disp('==========================================================');

figure(4); clf;
h4 = plot(L3,'Components',true);
title('Test 4: Complex loop with components [3 2 1 0 -1]');
xlabel('Press any key to continue...');

disp(['Number of component handles: ' num2str(length(h4))]);
for i = 1:length(h4)
  disp(['  Component ' num2str(i) ': ' num2str(length(get(h4(i),'XData'))) ' points']);
end
disp(' ');
disp('Does this plot look correct?');
pause

%% Test 5: Custom styling
disp('==========================================================');
disp('Test 5: Custom line width and color');
disp('Expected: Thick red line');
disp('==========================================================');

figure(5); clf;
h5 = plot(L1,'LineWidth',4,'LineColor','r');
title('Test 5: Custom styling (thick red line)');
xlabel('Press any key to finish...');

disp('Does this plot look correct? (Thick red line)');
pause

disp(' ');
disp('==========================================================');
disp('Visual inspection complete!');
disp('All figures will remain open for review.');
disp('Close them manually when done.');
disp('==========================================================');
