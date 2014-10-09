% Show how bad the loop class is compared to C function on array.

n = 8;
k = 10;
dynnmax = 1;  % Careful!  Increasing this even by 1 can cause Matlab to lock.

% Make loops as row-vectors of an array.
l = looplist(2*n-4,-dynnmax,dynnmax);

fprintf('Number of loops = %g\n',size(l,1));

% Make a long braid as vector.
b = int32((-1).^randi(2,1,k) .* randi(n-1,1,k));

fprintf('\naction of braid on loops (vectors)... ')
tic
l2 = loopsigma_helper(b,l);
t1 = toc;
fprintf(' (%f seconds)\n',t1)

fprintf('\nconverting to array of loops... ')
tic
l3 = loop(l);
t2 = toc;
fprintf(' (%f seconds)\n',t2)

b = braid(b);

fprintf('\naction of braid on array of loops (classes)... ')
tic
l4 = b*l3;
t3 = toc;
fprintf(' (%f seconds)\n',t3)

% Check equality of two results.
fprintf('\nverify equality... ')
tic
for i = 1:size(l,1)
  if any(l2(i,:) ~= l4(i).coords)
    error('Coordinates don''t match.')
  end
end
t4 = toc;
fprintf(' (%f seconds)\n',t4)

% Slowdown from array compared to conversion+action.
fprintf('\nSlowdown = %f\n',(t2+t3)/t1)
