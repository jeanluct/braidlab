% areEqual(A, B, precision)
%
% AREEQUAL
%
% Checks if elements of A and B are within precision (int)
% float-representable numbers.
%
% Returns a logical matrix of size equal to A and B containing results of
% tests.
% 
% AREEQUAL is implemented as a MATLAB MEX file. This file holds only its
% documentation.
%
% Ex.
% A = rand(10,10);
% areEqual(A,A+5*eps(A),5)
% vs
% areEqual(A,A+5*eps(A),3)
% 
% as a crude test.

% <LICENSE
%   Copyright (c) 2013, 2014 Marko Budisic
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>
function result = areEqual(A, B, precision)

warning('BRAIDLAB:braid:areEqual:notcompiled',...
    ['areEqual MEX file not detected. Attempting to compile ' ...
    'from inside MATLAB.' ...
    'If you repeatedly get this message, please check your braidlab ' ...
    'distribution has been MEX-compiled correctly.']);

try
    filename = [mfilename('fullpath') '.cpp'];
    [pathstr,~,~] = fileparts(filename);
    whereami = pwd;
    cd(pathstr);
    mex('areEqual.cpp');
    cd(whereami);
catch me
    error('BRAIDLAB:braid:areEqual:notcompiled',...
        ['Matlab MEX compilation failed. Please check that '...
        'braidlab was installed and MEX-compiled properly']);
end
error('BRAIDLAB:braid:areEqual:notcompiled',...
    ['Matlab MEX compilation successful. Please re-run '...
    'your code']);

        