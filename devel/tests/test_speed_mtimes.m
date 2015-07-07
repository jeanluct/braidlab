dbmex on
global BRAIDLAB_debuglvl
BRAIDLAB_debuglvl = 0

braidlab.util.debugmsg('Initializing braid and loop')

Lcoord = [1,1; 0,1; 1, 0; 0,-1; 3,2];
Bcoord = [1,-2];

NGpoints = 10;
NLpoints = 5;
Generators = ceil(logspace(1,6,NGpoints));
Loops = ceil(logspace(1,5,NLpoints));

timeS = nan([NGpoints, NLpoints]);
timeM = timeS;

for g = 1:NGpoints
  for l = 1:NLpoints

    NL = Loops(l);
    NG = Generators(g);

    L = braidlab.loop(repmat(Lcoord,ceil([NL/size(Lcoord,1),1])));
    B = braidlab.braid(repmat(Bcoord, ceil([1, NG/numel(Bcoord)])));

    braidlab.util.debugmsg('Multiplying')

    clear getAvailableThreadNumber
    global BRAIDLAB_threads
    BRAIDLAB_threads = 1;
    tic; LU = B*L; timeS(g,l) = toc;

    clear getAvailableThreadNumber
    clear('global','BRAIDLAB_threads')
    tic; LT = B*L; timeM(g,l) = toc;

    fprintf('Done: Nloops %d \t Ngen %d\n', NL, NG );

  end
end
timeR = timeM ./ timeS;

h=plot( Generators(:), timeR );
labels = arrayfun( @(n)sprintf('Loops %d', n), Loops,'uniformoutput',false );
[h.DisplayName] = deal(labels{:});
xlabel('# generators');
ylabel('Multithreaded speedup');
legend('Location','Best');
