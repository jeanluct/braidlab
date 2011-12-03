load color_braiding_bug_testcase_data

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

fprintf(1,'Number of crossings in J-LT''s code: %d\n',length(gen1))
fprintf(1,' Number of crossings in MRA''s code: %d\n',length(gen2))
fprintf(1,'          Length of canonical form: %d\n',length(braidlcf(gen2)))
