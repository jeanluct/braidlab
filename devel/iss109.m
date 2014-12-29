XY = zeros(2,2,3);

XY(1,:,1) = [0 1];
XY(2,:,1) = [1 3];
XY(1,:,2) = [1 0];
XY(2,:,2) = [1 0];
XY(1,:,3) = [2 0];
XY(2,:,3) = [2 0];

figure(1)
for i = 1:3
  plot(XY(:,1,i),1:2,'.-')
  hold on
end
hold off

figure(2)
for i = 1:3
  plot(XY(:,2,i),1:2,'.-')
  hold on
end
hold off

figure(3)
for i = 1:3
  plot3(XY(:,1,i),XY(:,2,i),1:2,'.-')
  hold on
end
hold off

global BRAIDLAB_braid_nomex
global BRAIDLAB_debuglvl

BRAIDLAB_debuglvl=1;
try
  BRAIDLAB_braid_nomex=true;
  braidlab.braid(XY)
  warning('NOMEX did not catch an error');
catch me

  if isempty( regexpi(me.identifier, 'coincidentprojection') )
    rethrow(me);
  end  
  disp('NOMEX ran into');
  disp(me.message)
end

try
  BRAIDLAB_braid_nomex=false;
  braidlab.braid(XY)
  warning('MEX did not catch an error');
catch me

  if isempty( regexpi(me.identifier, 'coincidentprojection') )
    rethrow(me);
  end  
  disp('MEX ran into');
  disp(me.message)
end

