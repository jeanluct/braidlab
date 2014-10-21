% Test inclusion/exclusion formula for addition of loops.

n = 4;

rng('default')

l1 = loop(randi([-2 2],1,2*n-4)/2)
l2 = loop(randi([-2 2],1,2*n-4))

%l1 = loop([1 1 -1 1])
l1 = loop([0 0 -1 1])
l2 = loop([1 -2 -1 0])

subplot(2,1,1)
plot(l1,'PunctureSize',.02)
hold on
plot(l2,'LineColor','r','PunctureSize',0)
hold off
subplot(2,1,2)
plot(loop(l1.coords+l2.coords))
