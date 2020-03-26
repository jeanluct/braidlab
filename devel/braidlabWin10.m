% BEFORE RUNNING SCRIPT
%
% Install MinGW-w64 with MSYS2 (here installed to C:\Apps).
%
% In braidlab/private/randomwalk_helper.cpp:
%     After #include <iostream> add:
%         #define _USE_MATH_DEFINES
%
% In braidlab/+braidlab/@braid/private/loopsigma_helper.cpp:
%     After #include "loopsigma_helper_common.hpp" add:
%         #include "update_rules.hpp"
%         #include "sumg.hpp"
%         #include "ThreadPool_nofuture.h"
%         #include "ThreadPool.h"
%
% In braidlab/+braidlab/@braid/private/cross2gen_helper.cpp:
%     After #include "cross2gen_helper.hpp" add:
%         #include "ThreadPool_nofuture.h"
%         #include "ThreadPool.h"
%
% In MinGW-w64:
%     cd braidlabWin10/extern/cbraid/lib
%     make -f ../../../Makefile.cbraid-mex CXX=g++ CC=cc
%     cd ../../trains
%     make CXX="g++ -fPIC" CC=cc
%
% Can also use Windows Subsystem for Linux:
%     cd braidlabWin10/extern/cbraid/lib
%     make -f ../../../Makefile.cbraid-mex CXX=x86_64-w64-mingw32-g++ CC=cc
%     cd ../../trains
%     make CXX="x86_64-w64-mingw32-g++ -fPIC" CC=cc

% getenv('MW_MINGW64_LOC')
setenv('MW_MINGW64_LOC', 'C:\Apps\msys64\mingw64');
warning('off', 'MATLAB:mex:MinGWVersion_link');

% Perform cd +braidlab/private; $(MAKE) all
cd braidlabWin10/+braidlab/private;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" randomwalk_helper.cpp;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" randomwalk_helper.cpp;

% Perform cd +braidlab/+util; $(MAKE) all
cd ../+util;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" ../../extern/assignmentoptimal/assignmentoptimal.c;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" ../../extern/assignmentoptimal/assignmentoptimal.c;

% Peform cd +braidlab/@braid/private; $(MAKE) all
cd ../@braid/private
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" compact_helper.cpp -I../../../extern/cbraid/include -L../../../extern/cbraid/lib -lcbraid-mex;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" compact_helper.cpp -I../../../extern/cbraid/include -L../../../extern/cbraid/lib -lcbraid-mex;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" loopsigma_helper.cpp -lgmpxx -lgmp;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" loopsigma_helper.cpp;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" entropy_helper.cpp -lgmpxx -lgmp;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" entropy_helper.cpp;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" train_helper.cpp -I../../../extern/trains -L../../../extern/trains/lib -ltrains;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" train_helper.cpp -I../../../extern/trains -L../../../extern/trains/lib -ltrains;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" cross2gen_helper.cpp -lgmpxx -lgmp;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" cross2gen_helper.cpp;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" subbraid_helper.cpp -I../../../extern/cbraid/include -L../../../extern/cbraid/lib -lcbraid-mex;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" subbraid_helper.cpp -I../../../extern/cbraid/include -L../../../extern/cbraid/lib -lcbraid-mex;

% Perform cd +braidlab/@loop/private; $(MAKE) all
cd ../../@loop/private;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" looplist_helper.c;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" looplist_helper.c;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" length_helper.cpp -lgmpxx -lgmp;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" length_helper.cpp;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" intersec_helper.cpp;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" intersec_helper.cpp;

% Perform cd +braidlab/@cfbraid/private; $(MAKE) all
cd ../../@cfbraid/private;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" cfbraid_helper.cpp -I../../../extern/cbraid/include -L../../../extern/cbraid/lib -lcbraid-mex;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" cfbraid_helper.cpp -I../../../extern/cbraid/include -L../../../extern/cbraid/lib -lcbraid-mex;
mex -largeArrayDims -O -DBRAIDLAB_USE_GMP CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" conjtest_helper.cpp -I../../../extern/cbraid/include -L../../../extern/cbraid/lib -lcbraid-mex;
% mex -largeArrayDims -O CFLAGS="-O -DMATLAB_MEX_FILE -fPIC" CXXFLAGS="-O -DMATLAB_MEX_FILE -fPIC -std=c++11" conjtest_helper.cpp -I../../../extern/cbraid/include -L../../../extern/cbraid/lib -lcbraid-mex;

cd ../../../..
addpath('C:\Users\dilab\Documents\MATLAB\braidlabWin10\');

cd braidlabWin10/testsuite
clc
test_braidlab
cd ../..

import braidlab.*;

% setenv('MW_MINGW64_LOC','C:\ProgramData\MATLAB\SupportPackages\R2019b\3P.instrset\mingw_w64.instrset');