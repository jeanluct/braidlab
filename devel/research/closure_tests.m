import braidlab.*

% Try all ways to close a braid of trajectories by drawing straight
% segments to the initial points.

% Compute TN class and entropy.

n = 6;
docompact = true;
dotntype = true;
permpregen = true;
paralyze = true;

% Should try a random braid obtained from duffing or something similar,
% to have a coherent structure.
rng(0); XY = randomwalk(n,300,.1);

poolobj = gcp('nocreate'); % If no pool, do not create new one.
if paralyze
  % Open pool of workers if it isn't already allocated.
  if isempty(poolobj)
    parpool('local');
  end
else
  % Close pool of workers.
  if ~isempty(poolobj)
    delete(poolobj)
  end
end

if paralyze
  pctRunOnAll warning('off','BRAIDLAB:braid:colorbraiding:coincident')
  pctRunOnAll warning('off','BRAIDLAB:braid:entropy:noconv')
else
  warning('off','BRAIDLAB:braid:colorbraiding:coincident')
  warning('off','BRAIDLAB:braid:entropy:noconv')
end

cl = {'r' 'g' 'b' 'm' 'c' 'y' 'k'};

figure(1)
for k = 1:size(XY,3)
  plot3(XY(:,1,k),XY(:,2,k),1:size(XY,1),cl{mod(k-1,length(cl))+1}), hold on
end
hold off

N = factorial(n);
tn = zeros(1,N);
entr = zeros(1,N);
tntext = cell(1,N);

P = permheap(n);  % pre-generate the permutations.

parfor i = 1:N
  disp(i)
  XYc = braidlab.closure(XY,P(i,:));
  b = braidlab.braid(XYc);
  if docompact, b = compact(b); end
  try
    [tntext{i},entr(i)] = tntype(b);
  catch err
    entr(i) = 0;
    tntext{i} = 'error';
  end
  switch tntext{i}
   case 'pseudo-Anosov'
    tn(i) = 2;
   case 'reducible'
    tn(i) = 1;
    if entr(i) == 0, entr(i) = entropy(b); end
   case 'finite-order'
    tn(i) = 0;
   case 'error'
    tn(i) = -1;
    entr(i) = entropy(b);
   otherwise
    error
  end
end

fprintf('\nFinal count:\n\n')
fprintf('pseudo-Anosov %d\n',length(find(tn == 2)))
fprintf('reducible     %d\n',length(find(tn == 1)))
fprintf('finite-order  %d\n',length(find(tn == 0)))
fprintf('error         %d\n',length(find(tn == -1)))
fprintf('-------------\n')
fprintf('total         %d\n',length(tn))
fprintf('\n')
entrnz = entr(find(entr ~= 0));
fprintf('entropy mean:  %f  (%f for nonzeros)\n',mean(entr),mean(entrnz))
fprintf('entropy std:   %f  (%f for nonzeros)\n',std(entr),std(entrnz))

% Sort according to type.
[tn,itn] = sort(tn);
entr = entr(itn);
P(:,:) = P(itn,:);

figure(2)
clf
subplot(2,1,1)
h = bar(entr,'b');
set(h,'EdgeColor',get(h,'FaceColor'));
axis tight
ylabel('entropy')

subplot(2,1,2)
h = bar(double(tn == 2),'b');
set(h,'EdgeColor',get(h,'FaceColor'));
hold on
h = bar(double(tn == 1),'r');
set(h,'EdgeColor',get(h,'FaceColor'));
h = bar(double(tn == 0),'w');
set(h,'EdgeColor',get(h,'FaceColor'));
hold off
axis tight
xlabel('permutation')
ylabel('TN type')
title('white - finite-order     red - reducible     blue - pA')

entrmindist = entropy(braid(closure(XY,'mindist')));
entrxproj = entropy(braid(closure(XY,'Xproj')));
entryproj = entropy(braid(closure(XY,'Yproj')));

figure(3)
hist(entr,20)
hold on
aa = axis;
plot(entrmindist*[1 1],[0 aa(4)],'r-','LineWidth',2)
plot(entrxproj*[1 1],[0 aa(4)],'g--','LineWidth',2)
plot(entryproj*[1 1],[0 aa(4)],'c--','LineWidth',2)
hold off
xlabel('entropy')
ylabel('count')
legend('','mindist','Xproj','Yproj','Location','NorthWest')
