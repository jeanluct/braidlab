//
// Matlab MEX file
//
// COLORBRAIDING Construct a sequence of braid generators from a
// physical braid specified by a set of trajectories. These cpp
// functions are intended to speed up the colorbraiding Matlab code
// used by the braid constructor.
//
// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2017  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic          <marko@clarkson.edu>
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

#include "mex.h"
#include "cross2gen_helper.hpp"


/*
*** Inputs:
XY       - nT x 2 x nStrings matrix specifying the trajectory
t        - nT x 1            vector specifying the time vector
Nthreads - number of computational threads requested

*** Outputs:
gen      - nG x 1 vector of generators in the braid
tgen     - nG x 1 vector of timesteps ast which the generators were detected

*/

#define p_XY (prhs[0])
#define p_t (prhs[1])
#define p_AbsTol (prhs[2])
#define p_Nthreads (prhs[3])

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // read off global debug level
  mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  if (isDebug) {
    BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  }

  if (nrhs < 2)
    mexErrMsgIdAndTxt("BRAIDLAB:braid:cross2gen_helper:input",
                      "2 arguments required.");

#ifdef BRAIDLAB_NOTHREADING
  if (2 <= BRAIDLAB_debuglvl)  {
    printf("\nBRAIDLAB_NOTHREADING defined\n");
  }
#endif

  // read off number of threads that are requested
  size_t NThreadsRequested;
  if (nrhs >= 3) {
    NThreadsRequested = (size_t) mxGetScalar(p_Nthreads);
  }
  else {
    NThreadsRequested = 0;
  }

  if (1 <= BRAIDLAB_debuglvl)  {
    printf("cross2gen_helper: Number of threads requested %d\n",
           NThreadsRequested );
  }

#ifdef BRAIDLAB_NOTHREADING
  if (NThreadsRequested > 1) {
    mexWarnMsgIdAndTxt(
                 "BRAIDLAB:braid:cross2gen_helper:nothreadingsupport",
                 "You requested multithreaded execution, but "
                 "either your compiler does not support it or "
                 "MEX file was compiled with BRAIDLAB_NOTHREADING flag.  "
                 "Defaulting to single-threaded execution.");
    NThreadsRequested = 1;
  }
#else
  if (NThreadsRequested < 1) {
    mexErrMsgIdAndTxt(
                "BRAIDLAB:braid:cross2gen_helper:numthreadsnotpositive",
                "Number of threads requested must be positive"
                " when running in multithreaded mode");
  }
#endif

  double AbsTol;

  AbsTol = mxGetScalar(p_AbsTol);

  if ( AbsTol <= 0 )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:cross2gen_helper:abstolnonpositive",
                      "AbsTol must be a positive number.");


  Timer tictoc(1);

  Real3DMatrix trj = Real3DMatrix( p_XY );
  if ( trj.C() != 2 ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:cross2gen_helper:input",
                      "Trajectory should have 2 columns.");
  }

  RealVector t = RealVector( p_t );

  if ( trj.R() != t.N() ) {
    mexErrMsgIdAndTxt(
        "BRAIDLAB:braid:cross2gen_helper:input",
        "Trajectory matrix and time vector should have same number of rows.");
  }

  if (2 <= BRAIDLAB_debuglvl)  {
    printf("Trajectories:\n");
    trj.print();
  }


  tictoc.tic();
  std::pair< std::vector<int>, std::vector<double> >
  // apply pairwise crossing generator
    retval = cross2gen( trj, t, AbsTol, NThreadsRequested );
  tictoc.toc("Algorithm");

  tictoc.tic();

  // create the list of generators
  if (nlhs >= 1) {
    plhs[0] = mxCreateDoubleMatrix( retval.first.size(), 1, mxREAL );
    double* out = mxGetPr(plhs[0]);

    for ( std::vector<int>::iterator it = retval.first.begin();
          it != retval.first.end(); it++ ) {
      *out = (double) *it;
      out++;
    }
  }

  if (nlhs >= 2) {
    plhs[1] = mxCreateDoubleMatrix( retval.second.size(), 1, mxREAL );
    double* out = mxGetPr(plhs[1]);

    for ( std::vector<double>::iterator it = retval.second.begin();
          it != retval.second.end(); it++ ) {
      *out = (double) *it;
      out++;
    }
  }

  tictoc.toc("Copying the output");
}
