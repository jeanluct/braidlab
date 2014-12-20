XY = zeros(2,2,3);

XY(1,:,1) = [0 1];
XY(2,:,1) = [1 3];
XY(1,:,2) = [1 0];
XY(2,:,2) = [1 0];
XY(1,:,3) = [2 0];
XY(2,:,3) = [2 0];

figure(1)
for i = 1:3
  plot(XY(:,1,i),1:2,'.-')
  hold on
end
hold off

figure(2)
for i = 1:3
  plot(XY(:,2,i),1:2,'.-')
  hold on
end
hold off

figure(3)
for i = 1:3
  plot3(XY(:,1,i),XY(:,2,i),1:2,'.-')
  hold on
end
hold off
