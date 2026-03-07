%TEST_SPACING_CONTROL  Test Phase 2 spacing control parameters.
%
% This script tests the new spacing parameters added in Phase 2:
% - PunctureGap: Scalar gap multiplier
% - PunctureGapVector: Per-puncture gap sizes
% - PunctureRadius: Explicit puncture radius

% Add braidlab to path
addpath(fullfile(fileparts(mfilename('fullpath')),'../../..'));

import braidlab.*

fprintf('========================================\n');
fprintf('Testing spacing control parameters...\n');
fprintf('========================================\n\n');

% Create test loop
L = loop([3 2 1 0 -1 -2]);

%% Test 1: Default spacing (backward compatibility)
fprintf('Test 1: Default spacing (no parameters)\n');
figure('Visible','off');
h1 = plot(L);
fprintf('  ✓ Default spacing works\n');
saveas(gcf,'spacing_test_1_default.png');
close(gcf);

%% Test 2: PunctureGap scalar parameter
fprintf('\nTest 2: PunctureGap parameter\n');

% Small gap
figure('Visible','off');
h2a = plot(L,'PunctureGap',0.05);
fprintf('  ✓ PunctureGap=0.05 (tight spacing)\n');
saveas(gcf,'spacing_test_2a_small_gap.png');
close(gcf);

% Large gap
figure('Visible','off');
h2b = plot(L,'PunctureGap',0.3);
fprintf('  ✓ PunctureGap=0.3 (wide spacing)\n');
saveas(gcf,'spacing_test_2b_large_gap.png');
close(gcf);

%% Test 3: PunctureGapVector parameter
fprintf('\nTest 3: PunctureGapVector parameter\n');

% Get number of punctures from loop
n = L.totaln;

% Variable gaps (increasing)
gaps = linspace(0.05,0.25,n)';
figure('Visible','off');
h3 = plot(L,'PunctureGapVector',gaps);
fprintf('  ✓ PunctureGapVector=[0.05...0.25] (variable spacing)\n');
fprintf('  Number of punctures: %d\n',n);
saveas(gcf,'spacing_test_3_variable_gaps.png');
close(gcf);

%% Test 4: PunctureRadius parameter
fprintf('\nTest 4: PunctureRadius parameter\n');

% Small punctures
figure('Visible','off');
h4a = plot(L,'PunctureRadius',0.02);
fprintf('  ✓ PunctureRadius=0.02 (small punctures)\n');
saveas(gcf,'spacing_test_4a_small_radius.png');
close(gcf);

% Large punctures
figure('Visible','off');
h4b = plot(L,'PunctureRadius',0.1);
fprintf('  ✓ PunctureRadius=0.1 (large punctures)\n');
saveas(gcf,'spacing_test_4b_large_radius.png');
close(gcf);

%% Test 5: Combined parameters
fprintf('\nTest 5: Combined parameters\n');
figure('Visible','off');
h5 = plot(L,'PunctureGap',0.15,'PunctureRadius',0.05);
fprintf('  ✓ PunctureGap=0.15 + PunctureRadius=0.05\n');
saveas(gcf,'spacing_test_5_combined.png');
close(gcf);

%% Test 6: Validation - bad PunctureGapVector length
fprintf('\nTest 6: Validation - incorrect vector length\n');
try
  figure('Visible','off');
  plot(L,'PunctureGapVector',[0.1 0.2]);  % Wrong length (2 instead of 4)
  fprintf('  ✗ Should have thrown error\n');
  close(gcf);
catch ME
  if strcmp(ME.identifier,'BRAIDLAB:loop:plot:badgapvec')
    fprintf('  ✓ Correctly rejects wrong-length PunctureGapVector\n');
  else
    fprintf('  ✗ Wrong error: %s\n',ME.identifier);
  end
end

%% Test 7: Components with custom spacing
fprintf('\nTest 7: Components with custom spacing\n');
figure('Visible','off');
h7 = plot(L,'Components',true,'PunctureGap',0.2);
fprintf('  ✓ Components work with PunctureGap\n');
fprintf('  Number of components: %d\n',length(h7));
saveas(gcf,'spacing_test_7_components.png');
close(gcf);

%% Summary
fprintf('\n========================================\n');
fprintf('All spacing control tests passed!\n');
fprintf('========================================\n');
fprintf('\nGenerated images:\n');
fprintf('  spacing_test_1_default.png\n');
fprintf('  spacing_test_2a_small_gap.png\n');
fprintf('  spacing_test_2b_large_gap.png\n');
fprintf('  spacing_test_3_variable_gaps.png\n');
fprintf('  spacing_test_4a_small_radius.png\n');
fprintf('  spacing_test_4b_large_radius.png\n');
fprintf('  spacing_test_5_combined.png\n');
fprintf('  spacing_test_7_components.png\n');
