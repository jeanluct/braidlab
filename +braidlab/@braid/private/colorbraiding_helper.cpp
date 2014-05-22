//
// Matlab MEX file
//
// COLORBRAIDING Construct a sequence of braid generators from a
// physical braid specified by a set of trajectories. These cpp
// functions are intended to speed up the colorbraiding Matlab code
// used by the braid constructor. Written by Marko Budisic.
//
// <LICENSE
//   Copyright (c) 2013, 2014 Jean-Luc Thiffeault, Marko Budisic
//
//   This file is part of Braidlab.
//
//   Braidlab is free software: you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation, either version 3 of the License, or
//   (at your option) any later version.
//
//   Braidlab is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
// LICENSE>

// Use the group relations to shorten a braid word as much as
// possible.

#include "colorbraiding_helper.hpp"
#include "mex.h"

/*
*** Inputs:
XY       - nT x 2 x nStrings matrix specifying the trajectory
t        - nT x 1            vector specifying the time vector
Nthreads - number of computational threads requested

*** Outputs:
gen      - nG x 1 vector of generators in the braid
tgen     - nG x 1 vector of timesteps ast which the generators were detected

*/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // read off global debug level
  mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  if (isDebug) {
    BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  }

  // read off global number of threads that should be used
  size_t NThreadsRequested;
  if (nrhs >= 3) {
    if( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) ||
        !(mxGetM(prhs[2])==1 && mxGetN(prhs[2])==1) ) {
      mexErrMsgIdAndTxt( "BRAIDLAB:braid:colorbraiding_helper:threadsinput",
                         "Number of threads must be "
                         "noncomplex scalar double.");
    }

    NThreadsRequested = (size_t) mxGetScalar(prhs[2]);
    if (1 <= BRAIDLAB_debuglvl)  {
      printf("colorbraiding_helper: Number of threads requested %d\n",
             NThreadsRequested );
    }
  }
  else {
    NThreadsRequested = 0;
  }

#ifdef BRAIDLAB_NOTHREADING
  if (2 <= BRAIDLAB_debuglvl)  {
    printf("\nBRAIDLAB_NOTHREADING defined\n");
  }
#endif

#ifdef BRAIDLAB_NOTHREADING
  if (NThreadsRequested > 1) {
  mexWarnMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:nothreadingsupport",
    "You requested multithreaded execution, but "
    "either your compiler does not support it or "
    "MEX file was compiled with BRAIDLAB_NOTHREADING flag.  "
    "Defaulting to single-threaded execution.");
  NThreadsRequested = 0;
  }
#endif
    
  Timer tictoc(1);

  if (nrhs < 2)
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:input",
                      "2 arguments required.");
  
  Real3DMatrix trj = Real3DMatrix( prhs[0] );
  if ( trj.C() != 2 ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:input",
                      "Trajectory should have 2 columns.");
  }

  RealVector t = RealVector( prhs[1] );

  if ( trj.R() != t.N() ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:input",
                      "Trajectory matrix and time vector should have same number of rows.");
  }

  tictoc.tic();
  pair< vector<int>, vector<double> > retval = crossingsToGenerators( trj, t, NThreadsRequested );  
  tictoc.toc("Algorithm");

  tictoc.tic();
  //  return;
  
  // create the list of generators 
  if (nlhs >= 1) {
    plhs[0] = mxCreateDoubleMatrix( retval.first.size(), 1, mxREAL );
    double* out = mxGetPr(plhs[0]);
    
    for ( vector<int>::iterator it = retval.first.begin(); it != retval.first.end(); it++ ) {
      *out = (double) *it;
      out++;
    }
  }

  if (nlhs >= 2) {
    plhs[1] = mxCreateDoubleMatrix( retval.second.size(), 1, mxREAL );
    double* out = mxGetPr(plhs[1]);
    
    for ( vector<double>::iterator it = retval.second.begin(); it != retval.second.end(); it++ ) {
      *out = (double) *it;
      out++;
    }
  }

  tictoc.toc("Copying the output");

}
