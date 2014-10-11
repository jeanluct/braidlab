//
// Matlab MEX file
//
// MINLENGTH Compute topological length of the loop.
//
// As input it takes NCOORDINATES x NLOOPS matrix of Dynnikov coordinates.
// For each column, it computes minlength by formula derived by summing 
// intersection numbers (see [1]).
//
// WARNING: This convention is currently chosen to accommodate both
// the way loops are stored and processed elsewhere, and an efficient
// implementation of minlength in loop_helper.hpp. Please transpose
// the coordinate matrix externally if needed.
//
// [1] Hall, Toby, and S. Öykü Yurttaş. “On the Topological Entropy of
// Families of Braids.” Topology and Its Applications 156, no. 8
// (April 15, 2009): 1554–64. 
// doi:10.1016/j.topol.2009.01.005.

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

#include "loop_helper.hpp"
#include "mex.h"
 
#ifndef BRAIDLAB_LOOP_ZEROINDEXED
#define OFFSET (-1)
#else
#define OFFSET (0)
#endif


// type-dependent retrieval of coordinates and computation of 
// loop length
template<class T>
void retrieveLength( const mxArray* input, mxArray *output, 
                     mwSize nLoops, mwSize nCoordinates);

// INPUT: single row vector of Dynnikov coordinates (a,b) (double, int32, or int64)
// OUTPUT: sum of nu/ \mu{beta} intersection numbers
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // // read off global debug level
  // mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  // if (isDebug) {
  //   BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  // }

  if (nrhs != 1) 
    mexErrMsgIdAndTxt("BRAIDLAB:loop:minlength_helper:badinput",
                      "Single argument (coordinate vector) is required.");

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
    retrieveLength<double>( prhs[0], outval, nLoops, nCoordinates );
    break;

  case mxINT32_CLASS:
    retrieveLength<int32_T>( prhs[0], outval, nLoops, nCoordinates );
    break;

  case mxINT64_CLASS:
    retrieveLength<int64_T>( prhs[0], outval, nLoops, nCoordinates );
    break;

  default:
    mexErrMsgIdAndTxt( "BRAIDLAB:loop:minlength_helper:unsupportedtype",
                       "Input has to be double, int32 or int64 type");
  }
}

template<class T>
void retrieveLength( const mxArray* input, mxArray *output, 
                     mwSize nLoops, mwSize nCoordinates) {

  // get pointer to output
  T * data = (T *) mxGetData(output);

  // pointers to input
  const T *a = static_cast<T *>(mxGetData( input )) + OFFSET;
  const T *b = static_cast<T *>(mxGetData( input )) + nCoordinates/2 + OFFSET;

  for ( mwSize l = 0; l < nLoops; ++l ) {
  
    // use loop_helper/length to compute
    *data = length<T>(nCoordinates, a, b);

    // move to the next column
    data++;
    a += nCoordinates;
    b += nCoordinates;

  }

  return;
}
