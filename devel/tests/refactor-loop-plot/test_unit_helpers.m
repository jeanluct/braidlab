% Unit tests for loop.plot helper functions
% Tests individual functions added during refactoring

addpath(genpath('.'));
import braidlab.*

disp('========================================');
disp('Unit Tests for loop.plot Helpers');
disp('========================================');
disp(' ');

% Test counter
total_tests = 0;
passed_tests = 0;

%% Test 1: Geometry computation - Simple loop produces closed path
disp('Test 1: Geometry computation - Simple loop produces closed path');
total_tests = total_tests + 1;
try
  % Simple loop should produce a closed path
  L = loop([1 0 0 0]);
  h = plot(L);
  
  xdata = get(h,'XData');
  ydata = get(h,'YData');
  
  % Verify closed path
  assert(xdata(1) == xdata(end),'Path should close in X');
  assert(ydata(1) == ydata(end),'Path should close in Y');
  
  % Verify multiple points (not just a single point)
  assert(length(xdata) > 10,'Should have multiple points');
  
  delete(h);
  disp('  PASS: Simple loop produces closed path');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 2: Geometry computation - Complex loop produces closed path
disp('Test 2: Geometry computation - Complex loop produces closed path');
total_tests = total_tests + 1;
try
  % More complex loop
  L = loop([3 2 1 0 -1 -2]);
  h = plot(L);
  
  % Should produce multiple components, each closed
  for i = 1:length(h)
    xdata = get(h(i),'XData');
    ydata = get(h(i),'YData');
    
    assert(xdata(1) == xdata(end),['Component ' num2str(i) ' should close in X']);
    assert(ydata(1) == ydata(end),['Component ' num2str(i) ' should close in Y']);
  end
  
  delete(h);
  disp('  PASS: Complex loop produces closed paths');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 3: Component ordering - Multi-component loop
disp('Test 3: Component ordering - Multi-component loop');
total_tests = total_tests + 1;
try
  % Loop with multiple components
  L = loop([2 1 -1 0]);
  h = plot(L,'Components',true);
  
  % Each component should be a separate handle
  assert(length(h) >= 1,'Should have at least 1 component');
  
  % Each should be closed
  for i = 1:length(h)
    xdata = get(h(i),'XData');
    ydata = get(h(i),'YData');
    assert(xdata(1) == xdata(end),'Component should be closed');
    assert(ydata(1) == ydata(end),'Component should be closed');
  end
  
  delete(h);
  disp('  PASS: Multi-component ordering');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 4: Puncture positioning affects geometry
disp('Test 4: Puncture positioning affects geometry');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);  % 4 punctures
  
  % Default positions (on x-axis at integers)
  h1 = plot(L);
  xdata1 = get(h1,'XData');
  ydata1 = get(h1,'YData');
  
  % Custom positions with Y offset (4 punctures)
  h2 = plot(L,'PuncturePositions',[1 0.5; 2 0.5; 3 0.5; 4 0.5]);
  xdata2 = get(h2,'XData');
  ydata2 = get(h2,'YData');
  
  % Geometries should differ (especially Y coordinates due to offset)
  geometry_changed = ~isequal(xdata1,xdata2) || ~isequal(ydata1,ydata2);
  assert(geometry_changed,'Different puncture positions should change geometry');
  
  delete(h1);
  delete(h2);
  disp('  PASS: Puncture positioning');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 5: Gap parameter affects geometry
disp('Test 5: Gap parameter affects loop geometry');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);
  
  % Small gap
  h1 = plot(L,'PunctureGap',0.05);
  ydata1 = get(h1,'YData');
  max_extent1 = max(abs(ydata1));
  
  % Large gap
  h2 = plot(L,'PunctureGap',0.3);
  ydata2 = get(h2,'YData');
  max_extent2 = max(abs(ydata2));
  
  % Larger gap should produce larger vertical extent
  assert(max_extent2 > max_extent1,'Larger gap should increase extent');
  
  delete(h1);
  delete(h2);
  disp('  PASS: Gap affects geometry');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 6: GapVector parameter - per-puncture control
disp('Test 6: GapVector parameter - per-puncture control');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);  % 4 punctures
  
  % Uniform gaps (4 punctures)
  h1 = plot(L,'PunctureGapVector',[0.1; 0.1; 0.1; 0.1]);
  ydata1 = get(h1,'YData');
  
  % Non-uniform gaps (4 punctures)
  h2 = plot(L,'PunctureGapVector',[0.05; 0.3; 0.05; 0.3]);
  ydata2 = get(h2,'YData');
  
  % Should produce different geometries
  assert(~isequal(ydata1,ydata2),'Different gap vectors should change geometry');
  
  delete(h1);
  delete(h2);
  disp('  PASS: GapVector per-puncture control');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 7: Spacing parameter validation (via plot)
disp('Test 7: Spacing parameters - PunctureGap validation');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);
  
  % Valid scalar gap
  h = plot(L,'PunctureGap',0.2);
  delete(h);
  
  % Invalid gap (negative)
  try
    h = plot(L,'PunctureGap',-0.1);
    delete(h);
    error('Should reject negative gap');
  catch ME
    assert(contains(ME.identifier,'MATLAB:'),'Should throw validation error');
  end
  
  disp('  PASS: PunctureGap validation');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 8: Spacing parameter - PunctureGapVector validation
disp('Test 8: Spacing parameters - PunctureGapVector validation');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);  % 4 punctures
  
  % Valid gap vector (4 elements)
  h = plot(L,'PunctureGapVector',[0.1; 0.2; 0.15; 0.1]);
  delete(h);
  
  % Invalid gap vector (wrong size - only 2 elements)
  try
    h = plot(L,'PunctureGapVector',[0.1; 0.2]);
    delete(h);
    error('Should reject wrong-size gap vector');
  catch ME
    % Should get assertion error about length
    assert(contains(ME.message,'length') || contains(ME.identifier,'BRAIDLAB:'),...
           'Should throw size error');
  end
  
  disp('  PASS: PunctureGapVector validation');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 9: Fill color auto-generation
disp('Test 9: Fill color auto-generation');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);
  
  % Blue edge with auto fill color
  h = plot(L,'LineColor','b','FillLoop',true);
  facecolor = get(h,'FaceColor');
  
  % Should be lighter than blue: [0 0 1] -> [0.5 0.5 1]
  assert(isequal(size(facecolor),[1 3]),'FaceColor should be RGB triplet');
  assert(facecolor(1) == 0.5,'Red component should be 0.5');
  assert(facecolor(2) == 0.5,'Green component should be 0.5');
  assert(facecolor(3) == 1,'Blue component should be 1');
  
  delete(h);
  disp('  PASS: Auto fill color generation');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 10: Fill color custom specification
disp('Test 10: Fill color custom specification');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);
  
  % Custom yellow fill
  h = plot(L,'FillLoop',true,'FillColor',[1 1 0]);
  facecolor = get(h,'FaceColor');
  
  assert(isequal(facecolor,[1 1 0]),'Custom fill color should be used');
  
  delete(h);
  disp('  PASS: Custom fill color');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 11: Fill alpha control
disp('Test 11: Fill alpha transparency control');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);
  
  % Test different alpha values
  alphas = [0,0.3,0.7,1];
  for i = 1:length(alphas)
    h = plot(L,'FillLoop',true,'FillAlpha',alphas(i));
    facealpha = get(h,'FaceAlpha');
    assert(facealpha == alphas(i),['Alpha should be ' num2str(alphas(i))]);
    delete(h);
  end
  
  disp('  PASS: Fill alpha control');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 12: Handle return type and count
disp('Test 12: Handle return - type and count');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);
  h = plot(L);
  
  % Check handle type
  assert(isa(h,'matlab.graphics.primitive.Patch'),'Should return patch object');
  
  % Check handle count (single component)
  assert(length(h) == 1,'Single component should return 1 handle');
  
  % Check column vector
  assert(size(h,2) == 1,'Should be column vector');
  
  delete(h);
  
  % Test multi-component
  L2 = loop([2 1 -1 0]);
  h2 = plot(L2);
  assert(length(h2) >= 1,'Should return at least 1 handle');
  assert(size(h2,2) == 1,'Should be column vector');
  
  delete(h2);
  disp('  PASS: Handle return type and count');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Test 13: Coordinate access via handles
disp('Test 13: Coordinate access via handles');
total_tests = total_tests + 1;
try
  L = loop([1 0 0 0]);
  h = plot(L);
  
  % Extract coordinates
  xdata = get(h,'XData');
  ydata = get(h,'YData');
  
  assert(isvector(xdata),'XData should be vector');
  assert(isvector(ydata),'YData should be vector');
  assert(length(xdata) == length(ydata),'X and Y same length');
  assert(length(xdata) > 100,'Should have many points (closed path)');
  
  % Verify closed path (first point == last point)
  assert(xdata(1) == xdata(end),'Path should be closed (X)');
  assert(ydata(1) == ydata(end),'Path should be closed (Y)');
  
  delete(h);
  disp('  PASS: Coordinate access via handles');
  passed_tests = passed_tests + 1;
catch ME
  disp(['  FAIL: ' ME.message]);
end
disp(' ');

%% Summary
disp('========================================');
disp('Unit Test Summary');
disp('========================================');
fprintf('Total tests: %d\n',total_tests);
fprintf('Passed: %d\n',passed_tests);
fprintf('Failed: %d\n',total_tests - passed_tests);
if passed_tests == total_tests
  disp(' ');
  disp('ALL TESTS PASSED!');
else
  disp(' ');
  disp('Some tests failed - review output above.');
end
disp(' ');
