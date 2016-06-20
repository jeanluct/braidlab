//
// Matlab MEX file
//
// INTERSEC_HELPER Compute intersection coordinates from Dynnikov
// coordinates of loops.
//
// First input is NCOORDINATES x NLOOPS matrix of Dynnikov coordinates.
// WARNING: This convention is currently chosen to accommodate both
// the way loops are stored and processed elsewhere. Please transpose
// the coordinate matrix externally if needed.
//
// References: Lemma 1 in
// [1] Hall, Toby, and S. Öykü Yurttaş. “On the Topological Entropy of
//     Families of Braids.” Topology and Its Applications 156, no. 8
//     (April 15, 2009): 1554–64.
//     doi:10.1016/j.topol.2009.01.005.

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2016  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic         <marko@math.wisc.edu>
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

// a[OFFSET] is always the first element in array
#ifndef BRAIDLAB_LOOP_ZEROINDEXED
#define OFFSET (1) // 1-based indexing
#else
#define OFFSET (0) // 0-based indexing
#endif

// type-dependent retrieval of coordinates and computation of
// loop length
template<class T>
void retrieveIntersect( const mxArray* inMx, mxArray *outMx,
                        mwSize nLoops, mwSize nCoordinates);

// INPUT:
// (1) matrix N x L where columns are Dynnikov coordinate vectors (a,b)
//     Number of punctures is computed as n = N/2 + 2
// OUTPUT:
// (1) matrix (3n-5) x L where columns are intersection coordinates

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // // read off global debug level
  // mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  // if (isDebug) {
  //   BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  // }

  if (nrhs != 1)
    mexErrMsgIdAndTxt("BRAIDLAB:loop:intersec_helper:badinput",
                      "Single input required: Ncoord x Nloops"
                      " coordinate matrix");

  // assumes each COLUMN is a loop
  mwSize nCoordinates = mxGetM(prhs[0]);
  mwSize nLoops = mxGetN(prhs[0]);
  mwSize nPunctures = nCoordinates/2 + 2;
  mwSize nIntersect = 3*nPunctures - 5;

  // create output
  mxArray* outval = mxCreateNumericMatrix(nIntersect,nLoops,
                                          mxGetClassID(prhs[0]),
                                          mxREAL);

  if (nlhs >= 1)
    plhs[0] = outval;

  // depending on input data, calculate length
  switch( mxGetClassID( prhs[0] ) ) {

  case mxDOUBLE_CLASS:
    retrieveIntersect<double>( prhs[0], outval,
                               nLoops, nCoordinates);
    break;

  case mxINT32_CLASS:
    retrieveIntersect<int32_T>( prhs[0], outval,
                                nLoops, nCoordinates);
    break;

  case mxINT64_CLASS:
    retrieveIntersect<int64_T>( prhs[0], outval,
                                nLoops, nCoordinates);
    break;

  default:
    mexErrMsgIdAndTxt( "BRAIDLAB:loop:intersec_helper:unsupportedtype",
                       "Type of the coordinate matrix has to be "
                       "double, int32 or int64.");
  }
}

template<class T>
void retrieveIntersect( const mxArray* inMx, mxArray *outMx,
                        mwSize nLoops, mwSize nCoordinates) {

  mwSize nPunctures = nCoordinates/2 + 2;
  mwSize nIntersect = 3*nPunctures - 5;

  // get pointer to output
  T * mu = static_cast<T *>( mxGetData( outMx ) ) - OFFSET;
  T * nu = static_cast<T *>( mxGetData( outMx ) ) - OFFSET
    + (2*nPunctures - 4);

  // pointers to input
  const T *a = static_cast<T *>(mxGetData( inMx )) - OFFSET;
  const T *b = static_cast<T *>(mxGetData( inMx )) - OFFSET
    + nCoordinates/2;

  for ( mwSize l = 0; l < nLoops; ++l ) {

    // use loop_helper/length to compute
    intersec<T>( nPunctures, a, b, mu, nu);

    // move to the next column
    a += nCoordinates;
    b += nCoordinates;
    mu += nIntersect;
    nu += nIntersect;

  }

  return;
}
