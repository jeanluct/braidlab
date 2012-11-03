load testdata

cl = {'r' 'g' 'b' 'm'};

ii = 1:length(ti);
XY = XY(ii,:,:); ti = ti(ii);

figure(1)
clf
for k =1:4
  plot(XY(:,1,k),ti,cl{k}), hold on
end
xlabel('X')
ylabel('t')
pbaspect([.75 1 1])
axis tight
hold off
print -dpdf testdata_trajs

figure(2)
clf
for k =1:4
  plot3(XY(:,1,k),XY(:,2,k),ti,cl{k}), hold on
end
xlabel('X')
ylabel('Y')
zlabel('t')
pbaspect([.75 .75 1])
axis tight
hold off
print -dpdf testdata_trajs3
