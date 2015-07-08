Lcoord = [1,1; 0,1; 1, 0; 0,-1; 3,2];
Bcoord = [1,-2];

Generators = 10.^(1:.5:5);
Loops = 10.^(1:1:4);

NGpoints = numel(Generators);
NLpoints = numel(Loops);

timeS = nan([NGpoints, NLpoints]);
timeM = timeS;



for g = 1:NGpoints
  for l = 1:NLpoints

    NL = Loops(l);
    NG = Generators(g);
    fprintf('Running: #loops %8d \t braid length %8d\t...\t', int64(NL), int64(NG) );
    L = braidlab.loop(repmat(Lcoord,ceil([NL/size(Lcoord,1),1])));
    B = braidlab.braid(repmat(Bcoord, ceil([1, NG/numel(Bcoord)])));

    clear getAvailableThreadNumber
    global BRAIDLAB_threads
    BRAIDLAB_threads = 1;
    tic; LU = B*L; timeS(g,l) = toc;

    clear getAvailableThreadNumber
    clear global BRAIDLAB_threads
    tic; LT = B*L; timeM(g,l) = toc;

    fprintf('done.\n');
  end
end
timeR = timeS ./ timeM;

h=semilogx( Generators(:), timeR, '-o' );
labels = arrayfun( @(n)sprintf('%d loops', n), Loops,'uniformoutput',false );
[h.DisplayName] = deal(labels{:});
xlabel('Braid length');
ylabel('Single threaded/multi threaded exec. time');
legend('Location','Best');

clear getAvailableThreadNumber
clear global BRAIDLAB_threads
txt = sprintf('Multiplication speedup using the default number of %d threads', ...
        braidlab.util.getAvailableThreadNumber() );
title(txt);
