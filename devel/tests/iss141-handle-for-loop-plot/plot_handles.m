x1 = linspace(0,pi,100);
x2 = linspace(pi,2*pi,100);

h1 = plot(x1,sin(x1),'r-')
hold on
h2 = plot(x2,sin(x2),'r-')
hold off

h = h1;
h.XData = [h.XData h2.XData];
h.YData = [h.YData h2.YData];
h.ZData = [h.ZData h2.ZData];

set(h,'Color','g')
