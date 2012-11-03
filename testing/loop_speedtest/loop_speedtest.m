n = 7;
k = 10;
dynnmax = 1;

% Make loops as vectors.
l = looplist(2*n-4,-dynnmax,dynnmax);
% Make a long braid as vector.
b = int32((-1).^randi(2,1,k) .* randi(n-1,1,k));

fprintf('\naction of braid on loops (vectors)... ')
tic
l2 = loopsigma_helper(b,l);
toc

fprintf('\nconverting to array of loops... ')
tic
l3 = loop(l);
toc

b = braid(b);

fprintf('\naction of braid on array of loops (classes)... ')
tic
b*l3;
toc
