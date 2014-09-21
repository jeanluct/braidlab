xy = zeros(npts,2,5);

period = 12*pi; nperiods = 50;
n = 5; tmax = period; npts = 1000;

XY = zeros(nperiods*(npts-1),2,n);
XY1 = zeros(npts,2,n);

XY0 = [[0 0.5];[-.1 -.9];[1 .67];[-.6 -.2];[.3 .3]];

cmp = [];

for p = 1:nperiods
  fprintf('period %d\n',p)

  for i = 1:size(XY0,1)
    [t,xy] =  ode45(@drive_simple, linspace(0, tmax, npts)', XY0(i,:));
    XY1(:,1,i) = xy(:,1); XY1(:,2,i) = xy(:,2);
  end

  XY((p-1)*(npts-1) + (1:npts-1),:,:) = XY1(1:end-1,:,:);
  XY0 = squeeze(XY1(end,:,:))';

  b = braid(XY(1:p*(npts-1),:,:));
  cmp = [cmp complexity(b)];
end

figure(1)
plot(1:nperiods,cmp,'.-')
xlabel('period'), ylabel('total braid complexity')

figure(2)
plot(1:nperiods,cmp./(1:nperiods),'.-')
xlabel('period'), ylabel('entropy (unit of inverse periods)')

fprintf('After %d periods, entropy per period=%f, ', ...
	nperiods, entropy(b)/ nperiods)
fprintf('complexity per period=%f\n', complexity(b)/ nperiods)
