//
// Matlab MEX file
//
// LENGTH_HELPER Compute different loop lengths.
//
// First input is NCOORDINATES x NLOOPS matrix of Dynnikov coordinates.
// WARNING: This convention is currently chosen to accommodate both
// the way loops are stored and processed elsewhere, and an efficient
// implementation of minlength in loop_helper.hpp. Please transpose
// the coordinate matrix externally if needed.
//
// Second input LFLAG selects the type of length computed.
//
// LFLAG == 1
// Compute the number of intersections of a loop with horizontal axis.
// [2,3]
//
// LFLAG == 2
// For each column, it computes minlength by formula derived by summing
// intersection numbers (see [1]).
//
// References:
// [1] Hall, Toby, and S. Öykü Yurttaş. “On the Topological Entropy of
//     Families of Braids.” Topology and Its Applications 156, no. 8
//     (April 15, 2009): 1554–64.
//     doi:10.1016/j.topol.2009.01.005.
//
// [2] Dynnikov, Ivan, and Bert Wiest. “On the Complexity of Braids.”
//     Journal of the European Mathematical Society, 2007, 801–40.
//     doi:10.4171/JEMS/98.
//
// [3] Thiffeault, Jean-Luc. “Braids of Entangled Particle Trajectories.”
//     Chaos (20), no. 1 (2010) 017516–017514.
//     doi:10.1063/1.3262494.

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

#include <iostream>
#include "loop_helper.hpp"
#include "mex.h"

// a[OFFSET] is always the first element in array
#ifndef BRAIDLAB_LOOP_ZEROINDEXED
#define OFFSET (1) // 1-based indexing
#else
#define OFFSET (0) // 0-based indexing
#endif


// type-dependent retrieval of coordinates and computation of
// loop length
template<class T>
void retrieveLength( const mxArray* input, mxArray *output,
                     mwSize nLoops, mwSize nCoordinates,
                     unsigned int lFlag);

// INPUT:
// (1) matrix N x L where columns are Dynnikov coordinate vectors (a,b)
// (2) flag that selects the type of distance
//     == 1 : number of axis intersections (default)
//     == 2 : sum of nu/ \mu{beta} intersection numbers
//
// OUTPUT:
//     L x 1 column of lengths of loops

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // // read off global debug level
  // mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  // if (isDebug) {
  //   BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  // }

  if (nrhs != 2)
    mexErrMsgIdAndTxt("BRAIDLAB:loop:length_helper:badinput",
                      "Two arguments required: "
                      "coordinate matrix and "
                      "flag that selects the distance");

  // retrieve the flag
  unsigned int lengthFlag = static_cast<unsigned int>( mxGetScalar(prhs[1]) );

  //printf("Lengthflag: %d\n", lengthFlag);

  // assumes each COLUMN is a loop
  mwSize nCoordinates = mxGetM(prhs[0]);
  mwSize nLoops = mxGetN(prhs[0]);

  // create output
  mxArray* outval = mxCreateNumericMatrix(nLoops,1,
                                          mxGetClassID(prhs[0]),
                                          mxREAL);

  if (nlhs >= 1)
    plhs[0] = outval;

  // depending on input data, calculate length
  switch( mxGetClassID( prhs[0] ) ) {

  case mxDOUBLE_CLASS:
    retrieveLength<double>( prhs[0], outval,
                            nLoops, nCoordinates, lengthFlag );
    break;

  case mxINT32_CLASS:
    retrieveLength<int32_T>( prhs[0], outval,
                             nLoops, nCoordinates, lengthFlag );
    break;

  case mxINT64_CLASS:
    retrieveLength<int64_T>( prhs[0], outval,
                             nLoops, nCoordinates, lengthFlag );
    break;

  default:
    mexErrMsgIdAndTxt( "BRAIDLAB:loop:length_helper:unsupportedtype",
                       "Type of the coordinate matrix has to be "
                       "double, int32 or int64.");
  }
}

template<class T>
void retrieveLength( const mxArray* input, mxArray *output,
                     mwSize nLoops, mwSize nCoordinates,
                     unsigned int lFlag) {

  // get pointer to output
  T * data = (T *) mxGetData(output);

  // pointers to input
  const T *a = static_cast<T *>(mxGetData( input ))
    - OFFSET;
  const T *b = static_cast<T *>(mxGetData( input )) + (nCoordinates/2)
    - OFFSET;

  for ( mwSize l = 0; l < nLoops; ++l ) {

    // use loop_helper/length to compute
    switch (lFlag) {
    case 1:
      *data = intaxis<T>(nCoordinates, a, b);
      break;
    case 2:
      *data = minlength<T>(nCoordinates, a, b);
      break;
    default:
      mexErrMsgIdAndTxt("BRAIDLAB:loop:length_helper:unsupportedflag",
                        "Only flags 1 (intaxis) and "
                        "2 (minlength) implemented.");
    }

    // move to the next column
    data++;
    a += nCoordinates;
    b += nCoordinates;

  }

  return;
}
