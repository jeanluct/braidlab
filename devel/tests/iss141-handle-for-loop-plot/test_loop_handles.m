addpath ~/Projects/articles/braidlab
import braidlab.*

l = loop([0 0 1 -1]);

%figure(1)
%plot(l,'Components',false)

figure(2)
plot(l,'Components',true)
