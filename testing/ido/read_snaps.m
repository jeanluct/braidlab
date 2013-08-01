if false
  dat = load('16384/snaps.0.09.dat'); %snaps.0.15.dat

  N = 4096;
  tmax = size(dat,1)/N;

  XY = zeros(tmax,2,N);
  for i = 1:tmax
    i0 = (i-1)*N+1;
    XY(i,:,:) = dat(i0:i0+N-1,:).';
  end
end

Nreal = 1;
Nsub = 3:25:1003;

warning('off','BRAIDLAD:braid:entropy:noconv')
warning('off','BRAIDLAB:braid:color_braiding:coincident')

figure(1), hold off

for r = 1:Nreal
  fprintf('realization %d\n',r)
  p = randperm(Nsub(end));
  entr = [];
  for n = Nsub
    XYsub = XY(:,:,p(1:n));
    XYperiod = XYsub(end-4:end,:,:);

    %norm(squeeze(XYperiod(end,:,:)-XYperiod(1,:,:)))

    %b = compact(braid(XYperiod)); % this is buggy!
    b = braid(closure(XYperiod,'mindist'));

    entr = [entr;entropy(b)];
  end
  plot(Nsub,entr./Nsub','.-')
  hold on
end

xlabel('N')
ylabel('entropy')
hold off
