N = 1000000;
T = 20000; Tkeep = 2000;
eps = .025;

fonttype = 'Times';
fsize = 20; fcsize = 15; lw = 2;
txtattrib = {'FontName',fonttype,'FontSize',fsize,...
	     'FontWeight','normal'};
txtattrib2 = {txtattrib{:},'Interpreter','Latex'};

rng(0); wind = zeros(N,floor(T/Tkeep));
for i = 1:N
  X = randomwalk(1,T,eps,'disk');
  th = atan2(X(:,2),X(:,1));
  th2 = th(1:end-1); th2(find(abs(diff(th)) <= pi)) = 0;
  th = th-th(1) + 2*pi*[0;cumsum(sign(th2))];
  wind(i,:) = th(Tkeep:Tkeep:end);
  if ~mod(i,1000), fprintf('realization %d...\n',i); end
end

figure(1), clf
bins = 300;
for it = 1:2:floor(T/Tkeep)
  [P,w] = hist(wind(:,it),min(wind(:,it)):max(wind(:,it)),bins);
  P = P./trapz(w,P);
  semilogy(w,P,'b','LineWidth',lw)
  hold on
  t = Tkeep*it;
  %a = .425/eps/sqrt(t);% N =  50000; T =  10000; Tkeep =  2000; eps = .05;
  a = .39/eps/sqrt(t);  % N = 100000; T = 100000; Tkeep = 20000; eps = .01;
  Pf = .5*a*sech(.5*a*pi*w);
  minP = min(P(find(P~=0))); ii = find(Pf>minP);
  semilogy(w(ii),Pf(ii),'r','LineWidth',lw);
end
hold off
axis([-30 30 1e-4 .3])
return

a = .105; % T=100000, N=50000, eps=.05 (?)
%a = .05; % T=1000000, N=50000, eps=.01 (bad)
a = .19;  % T=10000, N=50000, eps=.05

a = 1.9e-5 * T;
Pf = .5*a*sech(a*pi*w/2); %Pf = Pf./trapz(w,Pf);
semilogy(w,Pf,'r','LineWidth',lw);

a = 1.9e-5 * 8000;
a = .15;
Pf = .5*a*sech(a*pi*w/2); %Pf = Pf./trapz(w,Pf);
semilogy(w,Pf,'r','LineWidth',lw);

hold off
set(gca, txtattrib{:})
