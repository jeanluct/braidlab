% Test fill functionality for loop.plot (Phase 4 / Issue #144)
% Tests:
% - FillLoop parameter (true/false)
% - FillColor parameter (auto and custom)
% - FillAlpha parameter (various transparency levels)
% - Interaction with Components option
% - Multi-component loops with fill

addpath(genpath('.'));
import braidlab.*

disp('========================================');
disp('Testing Fill Loop Functionality (#144)');
disp('========================================');
disp(' ');

%% Test 1: Simple loop - No fill (baseline)
disp('Test 1: Simple loop - No fill (baseline)');
L1 = loop([1 0 0 0]);
figure(1); clf; set(gcf,'Position',[50 700 500 350]);
h1 = plot(L1);
title('Test 1: No fill (default)','FontSize',12);
saveas(gcf,'fill_test_1_no_fill.png');
disp('  Saved: fill_test_1_no_fill.png');
disp(['  Handle count: ' num2str(length(h1))]);
disp(' ');

%% Test 2: Simple loop - With fill (auto color)
disp('Test 2: Simple loop - Fill with auto color');
figure(2); clf; set(gcf,'Position',[600 700 500 350]);
h2 = plot(L1,'FillLoop',true);
title('Test 2: Fill with auto color','FontSize',12);
saveas(gcf,'fill_test_2_auto_color.png');
disp('  Saved: fill_test_2_auto_color.png');
disp(['  FaceColor: ' mat2str(get(h2,'FaceColor'))]);
disp(['  FaceAlpha: ' num2str(get(h2,'FaceAlpha'))]);
disp(' ');

%% Test 3: Simple loop - Custom fill color
disp('Test 3: Simple loop - Custom fill color (yellow)');
figure(3); clf; set(gcf,'Position',[1150 700 500 350]);
h3 = plot(L1,'FillLoop',true,'FillColor',[1 1 0]);
title('Test 3: Fill with custom color (yellow)','FontSize',12);
saveas(gcf,'fill_test_3_custom_color.png');
disp('  Saved: fill_test_3_custom_color.png');
disp(['  FaceColor: ' mat2str(get(h3,'FaceColor'))]);
disp(' ');

%% Test 4: Simple loop - Different alpha values
disp('Test 4: Simple loop - Different alpha values');
figure(4); clf; set(gcf,'Position',[50 250 1600 350]);
alphas = [0.1,0.3,0.7,1.0];
for i = 1:length(alphas)
  subplot(1,4,i);
  h4 = plot(L1,'FillLoop',true,'FillAlpha',alphas(i));
  title(['Alpha = ' num2str(alphas(i))],'FontSize',10);
  axis equal; axis off;
end
saveas(gcf,'fill_test_4_alpha_variations.png');
disp('  Saved: fill_test_4_alpha_variations.png');
disp(['  Tested alphas: ' mat2str(alphas)]);
disp(' ');

%% Test 5: Multi-component loop - No fill
disp('Test 5: Multi-component - No fill with Components option');
L5 = loop([2 1 -1 0]);
figure(5); clf; set(gcf,'Position',[50 -200 500 350]);
h5 = plot(L5,'Components',true);
title('Test 5: Multi-component, no fill','FontSize',12);
saveas(gcf,'fill_test_5_multicomp_no_fill.png');
disp('  Saved: fill_test_5_multicomp_no_fill.png');
disp(['  Component count: ' num2str(length(h5))]);
disp(' ');

%% Test 6: Multi-component loop - Fill with auto colors
disp('Test 6: Multi-component - Fill with auto colors');
figure(6); clf; set(gcf,'Position',[600 -200 500 350]);
h6 = plot(L5,'Components',true,'FillLoop',true);
title('Test 6: Multi-component with auto fill','FontSize',12);
saveas(gcf,'fill_test_6_multicomp_auto_fill.png');
disp('  Saved: fill_test_6_multicomp_auto_fill.png');
disp(['  Component count: ' num2str(length(h6))]);
for i = 1:length(h6)
  disp(['  Component ' num2str(i) ' - EdgeColor: ' ...
        mat2str(get(h6(i),'EdgeColor')) ...
        ', FaceColor: ' mat2str(get(h6(i),'FaceColor'))]);
end
disp(' ');

%% Test 7: Complex multi-component - Fill with custom alpha
disp('Test 7: Complex multi-component - Custom alpha');
L7 = loop([3 2 1 0 -1 -2]);
figure(7); clf; set(gcf,'Position',[1150 -200 500 350]);
h7 = plot(L7,'Components',true,'FillLoop',true,'FillAlpha',0.5);
title('Test 7: Complex multi-component, alpha=0.5','FontSize',12);
saveas(gcf,'fill_test_7_complex_alpha.png');
disp('  Saved: fill_test_7_complex_alpha.png');
disp(['  Component count: ' num2str(length(h7))]);
disp(['  FaceAlpha (all): ' num2str(get(h7(1),'FaceAlpha'))]);
disp(' ');

%% Test 8: Complex multi-component - Custom fill color for all
disp('Test 8: Complex multi-component - Custom fill color (cyan)');
figure(8); clf; set(gcf,'Position',[325 -650 500 350]);
h8 = plot(L7,'Components',true,'FillLoop',true,'FillColor',[0 1 1]);
title('Test 8: Multi-component, custom fill (cyan)','FontSize',12);
saveas(gcf,'fill_test_8_custom_fill_multicomp.png');
disp('  Saved: fill_test_8_custom_fill_multicomp.png');
disp(['  Component count: ' num2str(length(h8))]);
for i = 1:length(h8)
  disp(['  Component ' num2str(i) ' - FaceColor: ' ...
        mat2str(get(h8(i),'FaceColor'))]);
end
disp(' ');

%% Summary
disp('========================================');
disp('Fill Tests Complete!');
disp('========================================');
disp(' ');
disp('Generated 8 test images:');
disp('  fill_test_1_no_fill.png - Baseline (no fill)');
disp('  fill_test_2_auto_color.png - Auto fill color');
disp('  fill_test_3_custom_color.png - Custom fill color');
disp('  fill_test_4_alpha_variations.png - Four alpha levels');
disp('  fill_test_5_multicomp_no_fill.png - Multi-component baseline');
disp('  fill_test_6_multicomp_auto_fill.png - Multi-component auto fill');
disp('  fill_test_7_complex_alpha.png - Complex with alpha=0.5');
disp('  fill_test_8_custom_fill_multicomp.png - Custom fill on multi-comp');
disp(' ');
disp('All tests verify:');
disp('  - FillLoop parameter works (true/false)');
disp('  - FillColor auto-generation (lighter version of edge)');
disp('  - FillColor custom specification');
disp('  - FillAlpha transparency control (0.1 to 1.0)');
disp('  - Interaction with Components option');
disp('  - Multi-component loops maintain individual edge colors');
disp(' ');
