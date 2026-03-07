% Visual test - displays plots for manual inspection
% Images will be saved to PNG files for review

addpath(genpath('.'));
import braidlab.*

disp('========================================');
disp('Creating test plots...');
disp('========================================');
disp(' ');

%% Test 1: Simple loop
disp('Test 1: Simple loop [1 0 0 0]');
L1 = loop([1 0 0 0]);
figure(1); clf; set(gcf,'Position',[100 500 600 400]);
h1 = plot(L1);
title('Test 1: Simple loop [1 0 0 0]','FontSize',14);
saveas(gcf,'visual_test_1_simple.png');
disp('  Saved: visual_test_1_simple.png');
disp(' ');

%% Test 2: With components  
disp('Test 2: Loop with components [2 1 -1 0]');
L2 = loop([2 1 -1 0]);
figure(2); clf; set(gcf,'Position',[100 50 600 400]);
h2 = plot(L2,'Components',true);
title('Test 2: Components [2 1 -1 0]','FontSize',14);
saveas(gcf,'visual_test_2_components.png');
disp('  Saved: visual_test_2_components.png');
disp(['  Number of components: ' num2str(length(h2))]);
disp(' ');

%% Test 3: More complex
disp('Test 3: Complex loop [3 2 1 0 -1 -2]');
L3 = loop([3 2 1 0 -1 -2]);
figure(3); clf; set(gcf,'Position',[750 500 600 400]);
h3 = plot(L3);
title('Test 3: Complex loop [3 2 1 0 -1 -2]','FontSize',14);
saveas(gcf,'visual_test_3_complex.png');
disp('  Saved: visual_test_3_complex.png');
disp(' ');

%% Test 4: Complex with components
disp('Test 4: Complex with components [3 2 1 0 -1 -2]');
figure(4); clf; set(gcf,'Position',[750 50 600 400]);
h4 = plot(L3,'Components',true);
title('Test 4: Complex with components [3 2 1 0 -1 -2]','FontSize',14);
saveas(gcf,'visual_test_4_complex_comp.png');
disp('  Saved: visual_test_4_complex_comp.png');
disp(['  Number of components: ' num2str(length(h4))]);
disp(' ');

%% Test 5: Different Dynnikov coords
disp('Test 5: Loop [0 1 0 -1]');
L5 = loop([0 1 0 -1]);
figure(5); clf; set(gcf,'Position',[425 275 600 400]);
h5 = plot(L5,'Components',true);
title('Test 5: Loop [0 1 0 -1] with components','FontSize',14);
saveas(gcf,'visual_test_5_other.png');
disp('  Saved: visual_test_5_other.png');
disp(['  Number of components: ' num2str(length(h5))]);
disp(' ');

disp('========================================');
disp('All test images saved.');
disp('Please review the PNG files:');
disp('  visual_test_1_simple.png');
disp('  visual_test_2_components.png');
disp('  visual_test_3_complex.png');
disp('  visual_test_4_complex_comp.png');
disp('  visual_test_5_other.png');
disp('========================================');
disp(' ');
disp('Figures remain open. Close manually when done.');
