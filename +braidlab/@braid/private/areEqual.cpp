//
// MATLAB MEX file
//
// AREEQUAL
//
// Check equality of two vectors up to D float-representable numbers.
//
// For example, use
// A = rand(10,10);
// areEqual(A,A+5*eps(A),5)
// vs
// areEqual(A,A+5*eps(A),3)
// 
// As a crude test.
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


#include "areEqual.hpp"
#include "mex.h"

int BRAIDLAB_debuglvl = -1;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // read off global debug level
  mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  if (isDebug) {
    BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  }

  if ( nrhs < 2 ) {
      mexErrMsgIdAndTxt( "BRAIDLAB:braid:areequal:notenoughinputs",
                         "At least two inputs are required");
  }

  if (2 <= BRAIDLAB_debuglvl)  {
    printf("areEqual: cpp implementation\n");
    mexEvalString("pause(0.001);"); //flush
  }

  // retrieve precision argument
  size_t D;
  if ( nrhs < 3 ) {
    D = 1;
  }
  else {
    if( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) ||
        !(mxGetM(prhs[2])==1 && mxGetN(prhs[2])==1) ) {
      mexErrMsgIdAndTxt( "BRAIDLAB:braid:areequal:incorrectprecision",
                         "Precision must be a noncomplex scalar double.");
    }
    D = (size_t) mxGetScalar(prhs[2]);
  }

  mwSize nSizesA = mxGetNumberOfDimensions(prhs[0]);
  const mwSize* sizesA = mxGetDimensions(prhs[0]);
  mwSize nSizesB = mxGetNumberOfDimensions(prhs[1]);
  const mwSize* sizesB = mxGetDimensions(prhs[1]);


  // check that the sizes of inputs match
  if ( nSizesA != nSizesB ) {
      mexErrMsgIdAndTxt( "BRAIDLAB:braid:areequal:unmatchedinputs",
                         "First two inputs have to have same dimensions.");
  }

  mwSize totalN = 1;
  for ( size_t k = 0; k < nSizesA; k++ ) {
    if ( sizesA[k] != sizesB[k] ) {
      mexErrMsgIdAndTxt( "BRAIDLAB:braid:areequal:unmatchedinputs",
                         "First two inputs have to have same size.");
    }
    totalN *= sizesA[k];
  }

  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) )
      mexErrMsgIdAndTxt( "BRAIDLAB:braid:areequal:badinputs",
                         "First input has to be a real matrix.");
  double *A = mxGetPr( prhs[0] );

  if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) )
      mexErrMsgIdAndTxt( "BRAIDLAB:braid:areequal:badinputs",
                         "Second input has to be a real matrix.");
  double *B = mxGetPr( prhs[1] );

  // create logical matrix as output
  plhs[0] = mxCreateLogicalArray(nSizesA, sizesA);
  bool *R = mxGetLogicals( plhs[0] );

  // compare all elements
  for ( size_t k = 0; k < totalN; k++ ) {
    R[k] = areEqual( A[k], B[k], D );
  }

}
