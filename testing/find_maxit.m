% Find the maximum number of iterations required to find the entropy of
% the minimum braids.

% This is used to set a value for maxit in entropy.m

n = [5:2:45];

maxit = [];
entr = [];
entr2 = [];
for i = n
  i
  [en,mx] = entropy(hironakakin(i));
  entr = [entr en];
  maxit = [maxit length(mx)];
  en2 = entropy(hironakakin(i),'trains');
  entr2 = [entr2 en2];
end

figure(1)
plot(n,maxit,'.-')
f = @(x) max(min(90*x-500,4100),100); % This works if conv not consecutive.
f2 = @(x) .47*x.^2.62 + 400;          % For consecutive conv (harder).
hold on
plot(n,f(n),'r')
plot(n,f2(n),'r')
hold off

figure(2)
plot(n,entr)
hold on
plot(n,entr2,'r')
plot(n,2*log(2+sqrt(3))./(n-1),'g')  % upper bound
hold off

figure(3)
plot(n,log10(abs(entr-entr2)),'g')
