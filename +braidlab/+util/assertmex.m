function assertmex(functionname)
%%ASSERTMEX Assert that MEX file exists
%
% ASSERTMEX(functionname) Checks that a mex file "functionname" exists. If
% it does not exist, function throws BRAIDLAB:noMEX error.

if nargin < 1
  [ST,I] = dbstack(1);
  functionname = ST(1).name;
end

assert(exist(functionname) == 3, 'BRAIDLAB:noMEX', ...
       ['MEX function ', functionname, ...
        ' is available only if braidlab is MEX-compiled.'] );
