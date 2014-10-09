close all; clear classes

l = loop

clear l
l = loop(zeros(5,4))
l(2) = loop(3)
l(2).n

l(2).plot

l2(2) = loop(3)
l2(1) = loop(3)
l2(2)  % this should return something

l2(2).coords
l2(2).coords = [1 2 3 4]
%l2(2).coords = [1 2] % errors (ok)

l2(3:4).coords = [6 7 8 9;-6 -7 -8 -9]

l2(3).coords(1) = 1
l2(4).coords(3:end) = [inf inf]
l2(2).coords(2:3) = NaN
%l2(1:2).coords(1:2,3:end) = 0 % errors (ok)

% This returns an error, since we can no longer create matrix of loops.
%l = zeros(3,2,'braidlab.loop')

% This also returns an error, for the same reason.
%l = zeros(3,2,'like',loop)

%l = zeros(1,2,'braidlab.loop')

%l = zeros(2,1,'braidlab.loop')
