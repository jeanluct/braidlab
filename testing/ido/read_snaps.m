N = 1024;
Nreal = 1;
Nsub = 3:2:500;
period = inf;%4741;

plotalltrajs = true;
rereaddata = true;

if rereaddata
  % Load data: position of disks at each time step.
  fprintf('Reading data...\n')
  datadir = [getenv('HOME') '/tmp/ido/'];

  %dat = load([datadir mat2str(N) '/snaps.0.09.dat']); %snaps.0.15.dat

  strain = 122; % 115 to 130, 121 is the last limit-cycle before chaos.
  dat = load([datadir 'transition3/' mat2str(strain) '/snaps.dat']);

  fprintf('Converting to braidlab format...\n')
  tmax = size(dat,1)/N;
  % Convert to format required by braidlab.
  XY = zeros(tmax,2,N);
  for i = 1:tmax
    i0 = (i-1)*N+1;
    XY(i,:,:) = dat(i0:i0+N-1,:).';
  end

  % Fix the orbits that wrap around.
  %   (Instead of this find the 'radius' of each orbit.)
  fprintf('Fixing wraparound...\n')
  dXY = diff(XY);
  dX = squeeze(dXY(:,1,:)); dY = squeeze(dXY(:,2,:));
  Xsign = [zeros(1,N) ; cumsum(sign(dX).*(abs(dX) > .5),1)];
  X = squeeze(XY(:,1,:)) - Xsign;
  Ysign = [zeros(1,N) ; cumsum(sign(dY).*(abs(dY) > .5),1)];
  Y = squeeze(XY(:,2,:)) - Ysign;
  XY = reshape([X;Y],[tmax 2 N]);

  dXY = diff(XY);
  if any(abs(dX) > .5) | any(abs(dY) > .5)
    error('Something went wrong in fixing wraparound.')
  end

  if ~isinf(period)
    fprintf('Enforcing closure...\n')
    % Verify periodicity.
    XY = XY((end-period+1):end,:,:);
    gap = squeeze(abs(XY(end,:,:)-XY(1,:,:)));
    % Some orbits wrap around the horizontal periodic direction.
    bad = find(gap(1,:) > .1);
    gap = min(gap,1-gap);
    fprintf('  Max difference between start/end: %f\n',max(max(gap)))

    gap2 = squeeze(abs(XY(end,:,:)-XY(1,:,:)));
    max(max(gap2))

    % Force closure.
    XY(end,:,:) = XY(1,:,:);
  end
end

if plotalltrajs
  figure(101), hold off
  for i = 1:min(N,1024)
    plot(XY(:,1,i),XY(:,2,i),'-'), hold on
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
    XYsub = XY(:,:,perm(1:n));        % subset of trajectories
    b = braid(XYsub);                 % extract braid
    bc = compact(b);                  % compact braid
    entr = [entr;entropy(bc)];        % compute entropy
    fprintf('n = %d   entropy = %f',n,entr(end))
    fprintf('  braid length = %d',length(bc))
    fprintf(' (%d before compact)\n',length(b))
  end
  plot(Nsub,entr,'.-')
  hold on
end

xlabel('N')
ylabel('entropy')
hold off
