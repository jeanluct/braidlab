load color_braiding_bug_testcase_data

addpath ..
addpath ../unused % for old gencross
import braidlab.*

cl = {'r' 'g' 'b' 'm'};

ii = 1:length(ti);

for k =1:4
  plot(XY(ii,1,k),ti(ii),cl{k}), hold on
end
hold off

% J-LT's old method
tic
[gen1,tcr1] = gencross(ti(ii),squeeze(XY(ii,1,:)),squeeze(XY(ii,2,:)));
toc

% MRA's new method
tic
[gen2,tcr2,cross_cell] = color_braiding(XY(ii,:,:),ti(ii));
toc

if length(gen1) ~= length(gen2)
  error('Lengths do not match.')
end

fprintf('Number of crossings in raw form: %d\n',length(gen1))
lcf1 = canform(gen1);
lcf2 = canform(gen2.word);
fprintf('       Length of canonical form: %d\n',cflength(lcf1))

if ~cfequal(lcf1,lcf2)
  error('Braids do not match.')
else
  disp('Braids match!')
end
