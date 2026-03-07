%TEST_PATCH_HANDLES  Test that loop.plot returns patch handles.
%
% This script tests Phase 1.4: verifies that the plot method now returns
% patch objects instead of line objects.

% Add braidlab to path
addpath(fullfile(fileparts(mfilename('fullpath')),'../../..'));

import braidlab.*

fprintf('========================================\n');
fprintf('Testing patch handle return...\n');
fprintf('========================================\n\n');

%% Test 1: Simple single-component loop
fprintf('Test 1: Simple loop [1 0 0 0]\n');
L1 = loop([1 0 0 0]);
figure('Visible','off');
h1 = plot(L1);

% Check handle type
fprintf('  Handle class: %s\n',class(h1));
assert(isa(h1,'matlab.graphics.primitive.Patch'), ...
       'Handle should be a Patch object');
fprintf('  ✓ Handle is a Patch object\n');

% Check handle count
fprintf('  Number of handles: %d\n',length(h1));
assert(length(h1) == 1,'Should return 1 handle for single component');
fprintf('  ✓ Correct number of handles\n');

% Check we can access XData and YData
xdata = get(h1,'XData');
ydata = get(h1,'YData');
fprintf('  XData length: %d\n',length(xdata));
fprintf('  YData length: %d\n',length(ydata));
assert(length(xdata) > 0,'XData should not be empty');
assert(length(ydata) > 0,'YData should not be empty');
fprintf('  ✓ Can access XData and YData\n');

% Check EdgeColor and FaceColor properties
edgecolor = get(h1,'EdgeColor');
facecolor = get(h1,'FaceColor');
fprintf('  EdgeColor: [%.2f %.2f %.2f]\n',edgecolor);
fprintf('  FaceColor: %s\n',facecolor);
assert(strcmp(facecolor,'none'),'FaceColor should be ''none''');
fprintf('  ✓ FaceColor is ''none'' (no fill yet)\n');

close(gcf);
fprintf('\n');

%% Test 2: Multi-component loop
fprintf('Test 2: Multi-component loop [3 2 1 0 -1 -2]\n');
L2 = loop([3 2 1 0 -1 -2]);
figure('Visible','off');
h2 = plot(L2,'Components',true);

% Check handle type
fprintf('  Handle class: %s\n',class(h2));
assert(isa(h2,'matlab.graphics.primitive.Patch'), ...
       'Handles should be Patch objects');
fprintf('  ✓ Handles are Patch objects\n');

% Check handle count
fprintf('  Number of handles: %d\n',length(h2));
assert(length(h2) == 2,'Should return 2 handles for 2 components');
fprintf('  ✓ Correct number of handles\n');

% Check size (should be column vector)
fprintf('  Handle array size: [%d %d]\n',size(h2));
assert(size(h2,2) == 1,'Handles should be column vector');
fprintf('  ✓ Handles returned as column vector (N×1)\n');

% Check each handle
for i = 1:length(h2)
  xdata = get(h2(i),'XData');
  ydata = get(h2(i),'YData');
  fprintf('  Component %d: %d points\n',i,length(xdata));
  assert(length(xdata) > 0,'Component %d XData should not be empty',i);
  assert(length(ydata) > 0,'Component %d YData should not be empty',i);
end
fprintf('  ✓ All components have valid coordinate data\n');

close(gcf);
fprintf('\n');

%% Test 3: Verify backward compatibility (no output capture)
fprintf('Test 3: Backward compatibility (no output capture)\n');
L3 = loop([1 0 0 0]);
figure('Visible','off');
plot(L3,'LineColor','r');  % No output variable
fprintf('  ✓ plot() works without output capture\n');
close(gcf);
fprintf('\n');

fprintf('========================================\n');
fprintf('All patch handle tests passed!\n');
fprintf('========================================\n');
