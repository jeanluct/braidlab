% Debug test for the cyan component issue
addpath(genpath('.'));
import braidlab.*

% The problematic loop
L = loop([3 2 1 0 -1 -2]);

figure(1); clf;
h = plot(L,'Components',true);
title('Loop [3 2 1 0 -1 -2] with components');

% Check each component
for i = 1:length(h)
  xd = get(h(i),'XData');
  yd = get(h(i),'YData');
  color = get(h(i),'Color');
  
  fprintf('Component %d (color: [%.2f %.2f %.2f]):\n', i, color(1), color(2), color(3));
  fprintf('  Points: %d\n', length(xd));
  fprintf('  Start: (%.4f, %.4f)\n', xd(1), yd(1));
  fprintf('  End:   (%.4f, %.4f)\n', xd(end), yd(end));
  fprintf('  Distance between start/end: %.6f\n', sqrt((xd(1)-xd(end))^2 + (yd(1)-yd(end))^2));
  fprintf('  Closed: %s\n\n', mat2str(abs(xd(1)-xd(end)) < 1e-6 && abs(yd(1)-yd(end)) < 1e-6));
end

saveas(gcf,'debug_components.png');
