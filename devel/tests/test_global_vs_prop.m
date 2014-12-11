function test_global_vs_prop(tt)

Ntests = 30000;

tic
switch lower(tt)
 case 'global'
  global testglob
  testglob = 1;
  for i = 1:Ntests
    test_global
  end
 case 'prop'
  for i = 1:Ntests
    a = braidlab.prop('GenRotDir');
    % Don't test setting the property: it's not done often anyways.
    % It's very slow, though.
    %braidlab.prop('GenRotDir',-1*a);
  end
end
toc

%=======================================================================
function test_global

global testglob

testglob = testglob*-1;
