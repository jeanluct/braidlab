N = 16384;
Nreal = 1;
Nsub = 3:2:100;
period = 5;

plotalltrajs = true;
rereaddata = true;

if rereaddata
  % Load data: position of disks at each time step.
  dat = load([mat2str(N) '/snaps.0.09.dat']); %snaps.0.15.dat
  tmax = size(dat,1)/N;
  % Convert to format required by braidlab.
  XY = zeros(tmax,2,N);
  for i = 1:tmax
    i0 = (i-1)*N+1;
    XY(i,:,:) = dat(i0:i0+N-1,:).';
  end

  % Verify periodicity.
  XYperiod = XY((end-period+1):end,:,:);
  gap = squeeze(abs(XYperiod(end,:,:)-XYperiod(1,:,:)));
  % Some orbits wrap around the horizontal periodic direction.
  bad = find(gap(1,:) > .1);
  gap = min(gap,1-gap);
  fprintf('Max difference between start/end: %f\n',max(max(gap)))

  % Fix the orbits that wrap around.
  %   (Instead of this find the 'radius' of each orbit.)
  badx = find(XYperiod(1,1,:) < .1 | XYperiod(1,1,:) > .95);
  for i = 1:size(badx,1)
    badpts = find(XYperiod(:,1,badx(i)) > .8);
    XYperiod(badpts,1,badx(i)) = XYperiod(badpts,1,badx(i))-1;
  end
  bady = find(XYperiod(1,2,:) < .1 | XYperiod(1,2,:) > .95);
  for i = 1:size(bady,1)
    badpts = find(XYperiod(:,2,bady(i)) > .8);
    XYperiod(badpts,2,bady(i)) = XYperiod(badpts,2,bady(i))-1;
  end

  gap2 = squeeze(abs(XYperiod(end,:,:)-XYperiod(1,:,:)));
  max(max(gap2))

  % Force closure.
  XYperiod(end,:,:) = XYperiod(1,:,:);
end

if plotalltrajs
  figure(101), hold off
  for i = 1:N
    plot(XYperiod(:,1,i),XYperiod(:,2,i),'-'), hold on
  end
  hold off
end

warning('off','BRAIDLAD:braid:entropy:noconv')
warning('off','BRAIDLAD:braid:entropy:smallentr')
warning('off','BRAIDLAB:braid:color_braiding:coincident')

figure(1), hold off

for r = 1:Nreal
  fprintf('realization %d\n',r)
  perm = randperm(Nsub(end));
  entr = [];
  for n = Nsub
    XYsub = XYperiod(:,:,perm(1:n));  % subset of trajectories
    b = compact(braid(XYsub))         % extract braid
    entr = [entr;entropy(b)];         % compute entropy
  end
  plot(Nsub,entr,'.-')
  hold on
end

xlabel('N')
ylabel('entropy')
hold off
