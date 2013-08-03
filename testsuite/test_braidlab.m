% Unit Testing Framework not implemented prior to 2013a.
minver =  '8.1.0'; minrel = '2013a';
if verLessThan('matlab', minver)
  error('BRAIDLAB:test_braidlab:minver',...
	'Testsuite requires Matlab version >= %s (%s).',minver,minrel)
end

import matlab.unittest.*

%suite = TestSuite.fromFolder(pwd);
suite = TestSuite.fromClass(?braidTest);
runner = TestRunner.withTextOutput;
res = runner.run(suite)
