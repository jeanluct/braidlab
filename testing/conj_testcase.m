load color_braiding_bug_testcase_data

% Verify independence on projection line.
% Braids should be conjugate.

addpath ..
import braidlab.*

cl = {'r' 'g' 'b' 'm'};

ii = 1:length(ti);
XY = XY(ii,:,:); ti = ti(ii);

% Close the braid.
[XY,ti] = closure(XY,ti);

for k =1:4
  plot(XY(:,1,k),ti,cl{k}), hold on
end
hold off

gen1 = braid(XY,ti);

fprintf('      Number of crossings in raw form: %d\n',length(gen1))
gen1c = compact(gen1);
fprintf('Number of crossings in compacted form: %d\n',length(gen1c))

cf1 = cfbraid(gen1c);

if cfbraid(gen1) ~= cf1
  error('Something went wrong when compacting...')
end

fprintf('             Length of canonical form: %d\n',length(cf1))

% ROTATE
disp('Now rotate...')

XYr = [XY(:,2,:) -XY(:,1,:)];

gen2 = braid(XYr,ti);

fprintf('      Number of crossings in raw form: %d\n',length(gen2))
gen2c = compact(gen2);
fprintf('Number of crossings in compacted form: %d\n',length(gen2c))

cf2 = cfbraid(gen2c);

if cfbraid(gen2) ~= cf2
  error('Something went wrong when compacting...')
end

fprintf('             Length of canonical form: %d\n',length(cf2))

[conj,C] = conjtest(cf1,cf2);

if conj
  disp('Braids are conjugate!')
  C
else
  warning('Braids are not conjugate...')
end
