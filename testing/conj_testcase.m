load ../testsuite/testdata

% Verify independence on projection line.
% Braids should be conjugate.

addpath ..
import braidlab.*

cl = {'r' 'g' 'b' 'm'};

ii = 1:length(ti);
XY = XY(ii,:,:); ti = ti(ii);

% Close the braid.
XY = closure(XY);

for k =1:4
  plot(XY(:,1,k),1:size(XY,1),cl{k}), hold on
end
xlabel('X')
ylabel('t')
hold off

gen1 = braid(XY);

fprintf('      Number of crossings in raw form: %d\n',length(gen1))
gen1c = compact(gen1);
fprintf('Number of crossings in compacted form: %d\n',length(gen1c))

if gen1c ~= gen1
  error('Something went wrong when compacting...')
end

% ROTATE
disp('Now rotate...')

gen2 = braid(XY,-pi/4);

fprintf('      Number of crossings in raw form: %d\n',length(gen2))
gen2c = compact(gen2);
fprintf('Number of crossings in compacted form: %d\n',length(gen2c))

if gen2c ~= gen2
  error('Something went wrong when compacting...')
end

[conj,C] = conjtest(gen1,gen2);

if conj
  disp('Braids are conjugate!  Conjugating braid:')
  C
else
  warning('Braids are not conjugate...')
end
