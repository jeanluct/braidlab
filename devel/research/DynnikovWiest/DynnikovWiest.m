function DynnikovWiest

import braidlab.*

b1 = braid([-2 1]);

kmax = 7;

[ia1,comp1] = actoncurve(b1,kmax);

% The formula in DW is wrong: they claim 2(F[k+2]-1), where F[0]=1, F[1]=1,
% etc.  I think the right formula is 2(F[2k+2]-1).  Then for k=0 we have
% 2(F[2]-1)=2, k=1 is 2(F[4]-1)=8, etc.
F = fibo(2*kmax+2);
ia1ex = [2 2*(F(2*(1:kmax)+2) - 1)];
if any(ia1-ia1ex), error('Analytic expression is wrong.'); end

b2 = braid([2 1]);
[ia2,comp2] = actoncurve(b2,kmax);

ia2ex = 2*floor((4*(0:kmax)-1)/3)+4;
if any(ia2-ia2ex), error('Analytic expression is wrong.'); end


plot(comp1,'.-'), hold on
plot(comp2,'r.-'), hold off

% =====================================================================
function [ia,comp] = actoncurve(b,kmax)

E = braidlab.loop(3);  % canonical loops
ia = E.intaxis-2;
comp = [0];
L = E;
for k = 1:kmax
  L = b*L;
  comp = [comp log2(intaxis(L)-2) - log2(intaxis(E)-2)];
  ia = [ia L.intaxis-2];
end

% =====================================================================
function f = fibo(n)

f = zeros(1,n); f(1) = 1; f(2) = 2;
for k = 3:n, f(k) = f(k-1) + f(k-2); end
