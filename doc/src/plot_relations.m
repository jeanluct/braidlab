fsize = 40;
lw = 3;

subplot(1,2,1)
plot(braid([1 3]),'k','LineWidth',lw)
text(363,158,'=','FontSize',fsize)
subplot(1,2,2)
plot(braid([3 1]),'k','LineWidth',lw)
print -dpdf 13is31.pdf

subplot(1,2,1)
plot(braid([1 2 1]),'k','LineWidth',lw)
text(248,230,'=','FontSize',fsize)
subplot(1,2,2)
plot(braid([2 1 2]),'k','LineWidth',lw)
print -dpdf 121is212.pdf
