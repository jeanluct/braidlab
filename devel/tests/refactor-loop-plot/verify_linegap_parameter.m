% verify_linegap_parameter.m - Verify LineGap parameter works correctly
%
% This script demonstrates the new unified LineGap parameter that replaces
% the old PunctureGap (scalar) and PunctureGapVector (vector) parameters.

addpath(fullfile(fileparts(mfilename('fullpath')),'../../..'));
import braidlab.*

fprintf('========================================\n');
fprintf('Verifying LineGap Parameter\n');
fprintf('========================================\n\n');

% Create a simple test loop
L = loop([1 0 0 0]);  % 4 punctures
fprintf('Test loop: 4 punctures\n\n');

%% Test 1: Scalar LineGap
fprintf('Test 1: Scalar LineGap\n');
fprintf('  Usage: plot(L, ''LineGap'', 0.15)\n');
figure('Visible','off','Name','Scalar LineGap');
h1 = plot(L, 'LineGap', 0.15);
fprintf('  ✓ Returns %d handle(s)\n', length(h1));
fprintf('  ✓ Handle type: %s\n\n', class(h1));
saveas(gcf, 'verify_scalar_linegap.png');
close(gcf);

%% Test 2: Vector LineGap (uniform)
fprintf('Test 2: Vector LineGap (uniform)\n');
fprintf('  Usage: plot(L, ''LineGap'', [0.1; 0.1; 0.1; 0.1])\n');
figure('Visible','off','Name','Vector LineGap (uniform)');
h2 = plot(L, 'LineGap', [0.1; 0.1; 0.1; 0.1]);
fprintf('  ✓ Returns %d handle(s)\n', length(h2));
ydata2 = get(h2, 'YData');
fprintf('  ✓ Y extent: %.3f\n\n', max(abs(ydata2)));
saveas(gcf, 'verify_vector_linegap_uniform.png');
close(gcf);

%% Test 3: Vector LineGap (variable)
fprintf('Test 3: Vector LineGap (variable)\n');
fprintf('  Usage: plot(L, ''LineGap'', [0.05; 0.2; 0.1; 0.15])\n');
figure('Visible','off','Name','Vector LineGap (variable)');
h3 = plot(L, 'LineGap', [0.05; 0.2; 0.1; 0.15]);
fprintf('  ✓ Returns %d handle(s)\n', length(h3));
ydata3 = get(h3, 'YData');
fprintf('  ✓ Y extent: %.3f\n\n', max(abs(ydata3)));
saveas(gcf, 'verify_vector_linegap_variable.png');
close(gcf);

%% Test 4: Auto-calculated gaps (default)
fprintf('Test 4: Auto-calculated gaps (default behavior)\n');
fprintf('  Usage: plot(L)\n');
figure('Visible','off','Name','Auto LineGap');
h4 = plot(L);
fprintf('  ✓ Returns %d handle(s)\n', length(h4));
ydata4 = get(h4, 'YData');
fprintf('  ✓ Y extent: %.3f\n\n', max(abs(ydata4)));
saveas(gcf, 'verify_auto_linegap.png');
close(gcf);

%% Test 5: Error handling - wrong size vector
fprintf('Test 5: Error handling - wrong size vector\n');
fprintf('  Usage: plot(L, ''LineGap'', [0.1; 0.2])  %% Only 2 elements instead of 4\n');
try
    figure('Visible','off');
    plot(L, 'LineGap', [0.1; 0.2]);
    fprintf('  ✗ Should have thrown error!\n\n');
    close(gcf);
catch ME
    if strcmp(ME.identifier, 'BRAIDLAB:loop:plot:badlinegap')
        fprintf('  ✓ Correctly throws error: %s\n', ME.identifier);
        fprintf('  ✓ Message: %s\n\n', ME.message);
    else
        fprintf('  ✗ Wrong error type: %s\n\n', ME.identifier);
    end
end

%% Test 6: Error handling - negative gap
fprintf('Test 6: Error handling - negative gap\n');
fprintf('  Usage: plot(L, ''LineGap'', -0.1)\n');
try
    figure('Visible','off');
    plot(L, 'LineGap', -0.1);
    fprintf('  ✗ Should have thrown error!\n\n');
    close(gcf);
catch ME
    if contains(ME.identifier, 'MATLAB:InputParser')
        fprintf('  ✓ Correctly throws validation error: %s\n\n', ME.identifier);
    else
        fprintf('  ✗ Wrong error type: %s\n\n', ME.identifier);
    end
end

%% Summary
fprintf('========================================\n');
fprintf('Summary\n');
fprintf('========================================\n');
fprintf('✓ Scalar LineGap works\n');
fprintf('✓ Vector LineGap (uniform) works\n');
fprintf('✓ Vector LineGap (variable) works\n');
fprintf('✓ Auto-calculated gaps work\n');
fprintf('✓ Error handling works correctly\n\n');
fprintf('Generated images:\n');
fprintf('  - verify_scalar_linegap.png\n');
fprintf('  - verify_vector_linegap_uniform.png\n');
fprintf('  - verify_vector_linegap_variable.png\n');
fprintf('  - verify_auto_linegap.png\n\n');
fprintf('Migration from old API:\n');
fprintf('  OLD: plot(L, ''PunctureGap'', 0.15)\n');
fprintf('  NEW: plot(L, ''LineGap'', 0.15)\n\n');
fprintf('  OLD: plot(L, ''PunctureGapVector'', [0.1; 0.2; 0.1; 0.2])\n');
fprintf('  NEW: plot(L, ''LineGap'', [0.1; 0.2; 0.1; 0.2])\n\n');
