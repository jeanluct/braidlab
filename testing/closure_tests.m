addpath ..
addpath ../anisotropy
import braidlab.*

n = 6;
docompact = true;
dotntype = true;
permpregen = true;
paralyze = true;

%XY = readgranular('../anisotropy/parts2_20090406a',n);
rng(0); XY = randomwalk(n,300,.1);

if paralyze
  % Open pool of workers if it isn't already allocated.
  if matlabpool('size') == 0
    matlabpool open
  end
else
  % Close pool of workers.
  if matlabpool('size') > 0
    matlabpool close
  end
end

if paralyze
  pctRunOnAll warning('off','BRAIDLAB:braid:color_braiding:coincident')
  pctRunOnAll warning('off','BRAIDLAD:braid:entropy:noconv')
else
  warning('off','BRAIDLAB:braid:color_braiding:coincident')
  warning('off','BRAIDLAD:braid:entropy:noconv')
end

cl = {'r' 'g' 'b' 'm' 'c' 'y' 'k'};

figure(1)
for k = 1:size(XY,3)
  plot3(XY(:,1,k),XY(:,2,k),1:size(XY,1),cl{k}), hold on
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
h = bar(tn == 2,'b');
set(h,'EdgeColor',get(h,'FaceColor'));
hold on
h = bar(tn == 1,'r');
set(h,'EdgeColor',get(h,'FaceColor'));
h = bar(tn == 0,'w');
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
