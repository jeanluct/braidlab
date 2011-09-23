load color_braiding_bug_testcase_data

% Verify independence on projection line.
% Braids should be conjugate.

addpath ..
import braidlab.*

cl = {'r' 'g' 'b' 'm'};

ii = 1:length(ti);

% Close the braid.
XY(ii(end),:,:) = XY(ii(1),:,:);

for k =1:4
  plot(XY(ii,1,k),ti(ii),cl{k}), hold on
end
hold off

[gen1,tcr1] = color_braiding(XY(ii,:,:),ti(ii));

fprintf('      Number of crossings in raw form: %d\n',length(gen1))
gen1c = compact(gen1);
fprintf('Number of crossings in compacted form: %d\n',length(gen1c))

if ~cfequal(canform(gen1.word),canform(gen1c.word))
  error('Something went wrong when compacting...')
end

lcf1 = canform(gen1c.word);
fprintf('             Length of canonical form: %d\n',cflength(lcf1))

% ROTATE
disp('Now rotate...')

XYr = [XY(:,2,:) -XY(:,1,:)];

[gen2,tcr2] = color_braiding(XYr(ii,:,:),ti(ii));

fprintf('      Number of crossings in raw form: %d\n',length(gen2))
gen2c = compact(gen2);
fprintf('Number of crossings in compacted form: %d\n',length(gen2c))

if ~cfequal(canform(gen2.word),canform(gen2c.word))
  error('Something went wrong when compacting...')
end

lcf2 = canform(gen2c.word);
fprintf('             Length of canonical form: %d\n',cflength(lcf2))

[conj,C] = conjtest(lcf1,lcf2);

if conj
  disp('Braids are conjugate!')
  cfword(C)
else
  warning('Braids are not conjugate...')
end
