load issue82

slice1 = XY(:,:,1);
slice2 = XY(:,:,2);
slice3 = XY(:,:,4);

disp('first two particles are the same');
XY = cat(3, slice1, slice1, slice2, slice3 );

global BRAIDLAB_braid_nomex;
try
    disp('With MEX');
    BRAIDLAB_braid_nomex = 0;
    braidlab.braid(XY)
catch me
    disp(me)
end
    
try
    disp('Without MEX');
    BRAIDLAB_braid_nomex = 1;
    braidlab.braid(XY)
catch me
    disp(me)
end

disp('first and third particles are the same')
XY = cat(3, slice1, slice2, slice1, slice3 );

global BRAIDLAB_braid_nomex;
try
    disp('With MEX');
    BRAIDLAB_braid_nomex = 0;
    braidlab.braid(XY)
catch me
    disp(me)
end
    
try
    disp('Without MEX');
    BRAIDLAB_braid_nomex = 1;
    braidlab.braid(XY)
catch me
    disp(me)
end

