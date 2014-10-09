//
// Matlab MEX file
//
// MINLENGTH Compute topological length of the loop.
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

#include "loop_helper.hpp"
#include "mex.h"

#ifndef BRAIDLAB_loop_zeroindexed
#define OFFSET (-1)
#else
#define OFFSET (0)
#endif


// type-dependent retrieval of coordinates and computation of 
// loop length
template<class T>
void retrieveLength( const mxArray* input, mxArray *outval );

// INPUT: single row vector of Dynnikov coordinates (a,b) (double, int32, or int64)
// OUTPUT: sum of nu/ \mu{beta} intersection numbers
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // // read off global debug level
  // mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  // if (isDebug) {
  //   BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  // }

  mexWarnMsgIdAndTxt("BRAIDLAB:loop:minlength_helper",
                     "Using MEX to compute minlength");

  if (nrhs != 1) 
    mexErrMsgIdAndTxt("BRAIDLAB:loop:minlength_helper:badinput",
                      "Single argument (coordinate vector) is required.");

  if ( !(mxGetM(prhs[0]) == 1) ) 
    mexErrMsgIdAndTxt( "BRAIDLAB:braid:minlength_helper:badinput",
                       "Input has to be a single 1x(2n-4) row "
                       "vector (n - number of punctures).");

  // create output
  mxArray* outval = mxCreateNumericMatrix(1,1, mxGetClassID(prhs[0]), mxREAL);

  if (nlhs >= 1)
    plhs[0] = outval;

  // depending on input data, calculate length
  switch( mxGetClassID( prhs[0] ) ) {

  case mxDOUBLE_CLASS:
    retrieveLength<double>( prhs[0], outval );
    break;

  case mxINT32_CLASS:
    retrieveLength<int32_T>( prhs[0], outval );
    break;

  case mxINT64_CLASS:
    retrieveLength<int64_T>( prhs[0], outval );
    break;

  default:
    mexErrMsgIdAndTxt( "BRAIDLAB:loop:minlength_helper:unsupportedtype",
                       "Input has to be double, int32 or int64 type");
  }
}

template<class T>
void retrieveLength( const mxArray* input, mxArray *output ) {

  mwSize N = mxGetNumberOfElements( input );

  // get pointers to sub-vectors
  const T *a = static_cast<T *>(mxGetData( input )) + OFFSET;
  const T *b = static_cast<T *>(mxGetData( input )) + N/2 + OFFSET;

  // get pointer to output
  T * data = (T *) mxGetData(output);

  // use loop_helper/length to compute
  *data = length<T>(N, a, b);

  return;

}

