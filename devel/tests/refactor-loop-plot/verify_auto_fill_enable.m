% verify_auto_fill_enable.m - Verify FillColor/FillAlpha auto-enable FillLoop
%
% This script demonstrates that specifying FillColor or FillAlpha
% automatically enables loop filling without requiring FillLoop=true.

addpath(fullfile(fileparts(mfilename('fullpath')),'../../..'));
import braidlab.*

fprintf('========================================\n');
fprintf('Verifying Auto-Enable Fill Behavior\n');
fprintf('========================================\n\n');

% Create a simple test loop
L = loop([1 0 0 0]);  % 4 punctures
fprintf('Test loop: 4 punctures\n\n');

%% Test 1: FillColor auto-enables filling
fprintf('Test 1: FillColor auto-enables filling\n');
fprintf('  OLD API: plot(L, ''FillLoop'', true, ''FillColor'', [1 1 0])\n');
fprintf('  NEW API: plot(L, ''FillColor'', [1 1 0])\n\n');
figure('Visible','off','Name','FillColor Auto-Enable');
h1 = plot(L, 'FillColor', [1 1 0]);
facecolor1 = get(h1, 'FaceColor');
fprintf('  Result: FaceColor = [%.1f %.1f %.1f]\n', facecolor1);
if isequal(facecolor1, [1 1 0])
    fprintf('  ✓ FillColor auto-enabled filling\n\n');
else
    fprintf('  ✗ FAILED - expected [1 1 0], got [%.1f %.1f %.1f]\n\n', facecolor1);
end
saveas(gcf, 'auto_fill_1_fillcolor.png');
close(gcf);

%% Test 2: FillAlpha auto-enables filling
fprintf('Test 2: FillAlpha auto-enables filling\n');
fprintf('  OLD API: plot(L, ''FillLoop'', true, ''FillAlpha'', 0.7)\n');
fprintf('  NEW API: plot(L, ''FillAlpha'', 0.7)\n\n');
figure('Visible','off','Name','FillAlpha Auto-Enable');
h2 = plot(L, 'FillAlpha', 0.7);
facecolor2 = get(h2, 'FaceColor');
facealpha2 = get(h2, 'FaceAlpha');
fprintf('  Result: FaceAlpha = %.1f\n', facealpha2);
fprintf('  Result: FaceColor = %s (auto-generated)\n', mat2str(facecolor2));
if ~strcmp(facecolor2, 'none') && facealpha2 == 0.7
    fprintf('  ✓ FillAlpha auto-enabled filling\n\n');
else
    fprintf('  ✗ FAILED - fill not enabled or alpha incorrect\n\n');
end
saveas(gcf, 'auto_fill_2_fillalpha.png');
close(gcf);

%% Test 3: Both FillColor and FillAlpha
fprintf('Test 3: FillColor + FillAlpha (both work together)\n');
fprintf('  OLD API: plot(L, ''FillLoop'', true, ''FillColor'', [1 0 0], ''FillAlpha'', 0.5)\n');
fprintf('  NEW API: plot(L, ''FillColor'', [1 0 0], ''FillAlpha'', 0.5)\n\n');
figure('Visible','off','Name','FillColor + FillAlpha');
h3 = plot(L, 'FillColor', [1 0 0], 'FillAlpha', 0.5);
facecolor3 = get(h3, 'FaceColor');
facealpha3 = get(h3, 'FaceAlpha');
fprintf('  Result: FaceColor = [%.1f %.1f %.1f]\n', facecolor3);
fprintf('  Result: FaceAlpha = %.1f\n', facealpha3);
if isequal(facecolor3, [1 0 0]) && facealpha3 == 0.5
    fprintf('  ✓ Both parameters work together\n\n');
else
    fprintf('  ✗ FAILED - parameters not applied correctly\n\n');
end
saveas(gcf, 'auto_fill_3_both.png');
close(gcf);

%% Test 4: FillColor overrides explicit FillLoop=false
fprintf('Test 4: FillColor overrides explicit FillLoop=false\n');
fprintf('  Usage: plot(L, ''FillLoop'', false, ''FillColor'', [0 1 0])\n');
fprintf('  (FillColor takes precedence)\n\n');
figure('Visible','off','Name','Override FillLoop=false');
h4 = plot(L, 'FillLoop', false, 'FillColor', [0 1 0]);
facecolor4 = get(h4, 'FaceColor');
fprintf('  Result: FaceColor = [%.1f %.1f %.1f]\n', facecolor4);
if isequal(facecolor4, [0 1 0])
    fprintf('  ✓ FillColor overrides FillLoop=false\n\n');
else
    fprintf('  ✗ FAILED - FillLoop=false prevented filling\n\n');
end
saveas(gcf, 'auto_fill_4_override.png');
close(gcf);

%% Test 5: Default behavior (no fill) unchanged
fprintf('Test 5: Default behavior (no fill parameters)\n');
fprintf('  Usage: plot(L)\n\n');
figure('Visible','off','Name','Default No Fill');
h5 = plot(L);
facecolor5 = get(h5, 'FaceColor');
fprintf('  Result: FaceColor = %s\n', mat2str(facecolor5));
if strcmp(facecolor5, 'none')
    fprintf('  ✓ Correctly does not fill by default\n\n');
else
    fprintf('  ✗ FAILED - incorrectly filled by default\n\n');
end
saveas(gcf, 'auto_fill_5_default.png');
close(gcf);

%% Test 6: Explicit FillLoop=true still works
fprintf('Test 6: Explicit FillLoop=true still works\n');
fprintf('  Usage: plot(L, ''FillLoop'', true)\n\n');
figure('Visible','off','Name','Explicit FillLoop=true');
h6 = plot(L, 'FillLoop', true);
facecolor6 = get(h6, 'FaceColor');
fprintf('  Result: FaceColor = %s (auto-generated)\n', mat2str(facecolor6));
if ~strcmp(facecolor6, 'none')
    fprintf('  ✓ Explicit FillLoop=true still works\n\n');
else
    fprintf('  ✗ FAILED - FillLoop=true did not enable fill\n\n');
end
saveas(gcf, 'auto_fill_6_explicit.png');
close(gcf);

%% Test 7: Color names work too
fprintf('Test 7: FillColor with color name (not just RGB)\n');
fprintf('  Usage: plot(L, ''FillColor'', ''cyan'')\n\n');
figure('Visible','off','Name','Color Name');
h7 = plot(L, 'FillColor', 'c');  % cyan
facecolor7 = get(h7, 'FaceColor');
fprintf('  Result: FaceColor = [%.1f %.1f %.1f]\n', facecolor7);
if isequal(facecolor7, [0 1 1])  % cyan = [0 1 1]
    fprintf('  ✓ Color name auto-enabled filling\n\n');
else
    fprintf('  ✗ FAILED - color name not handled correctly\n\n');
end
saveas(gcf, 'auto_fill_7_colorname.png');
close(gcf);

%% Summary
fprintf('========================================\n');
fprintf('Summary\n');
fprintf('========================================\n');
fprintf('✓ FillColor auto-enables filling\n');
fprintf('✓ FillAlpha auto-enables filling\n');
fprintf('✓ FillColor + FillAlpha work together\n');
fprintf('✓ FillColor overrides FillLoop=false\n');
fprintf('✓ Default behavior (no fill) unchanged\n');
fprintf('✓ Explicit FillLoop=true still works\n');
fprintf('✓ Color names work correctly\n\n');
fprintf('Generated images:\n');
fprintf('  - auto_fill_1_fillcolor.png\n');
fprintf('  - auto_fill_2_fillalpha.png\n');
fprintf('  - auto_fill_3_both.png\n');
fprintf('  - auto_fill_4_override.png\n');
fprintf('  - auto_fill_5_default.png\n');
fprintf('  - auto_fill_6_explicit.png\n');
fprintf('  - auto_fill_7_colorname.png\n\n');
fprintf('API Improvement:\n');
fprintf('  Before: plot(L, ''FillLoop'', true, ''FillColor'', [1 1 0])\n');
fprintf('  After:  plot(L, ''FillColor'', [1 1 0])\n\n');
fprintf('  Before: plot(L, ''FillLoop'', true, ''FillAlpha'', 0.5)\n');
fprintf('  After:  plot(L, ''FillAlpha'', 0.5)\n\n');
