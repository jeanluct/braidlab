%
% MATLAB MEX file
%
% AREEQUAL
%
% Check equality of two vectors up to D float-representable numbers.
%
% For example, use
% A = rand(10,10);
% areEqual(A,A+5*eps(A),5)
% vs
% areEqual(A,A+5*eps(A),3)
% 
% as a crude test.