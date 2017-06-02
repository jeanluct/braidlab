#include <cmath>
#include <cstdio>
#include <string>

#ifdef BRAIDLAB_USE_GMP
#include <iostream>
#include <vector>
#include <gmpxx.h>
#endif

#include "mex.h"

#include "loopsigma_helper_common.hpp"

// Helper function for loopsigma
//
// ** ASSUMES THAT LOOPS ARE STORED COLUMNWISE **

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

#define P_SIGMA_IDX prhs[0]
#define P_LOOP_IN prhs[1]
#define P_NPUNC prhs[2]
#define P_NTHREADS prhs[3]

#define P_LOOP_OUT plhs[0]
#define P_OPSIGN  plhs[1]

#ifdef BRAIDLAB_USE_GMP
void convertCellLoopToGMP( const mxArray* cellLoop, mpz_class * loopIn);
void convertGMPToCellLoop( mpz_class * loopOut, mxArray* cellLoop );
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // read off global debug level
  mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  if (isDebug) {
    BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  }

  if (nrhs < 4) {
    mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:nargin",
                      "4 input arguments required.");
  }

  const size_t Nthreads = static_cast<size_t>( mxGetScalar(P_NTHREADS) );
  const int Npunc = static_cast<int>( mxGetScalar( P_NPUNC ) );

  // Dimensions of P_LOOP_IN - loops stored column-wise
  const mwSize Ncoord = mxGetM(P_LOOP_IN);
  const mwSize Nloops = mxGetN(P_LOOP_IN);


  if ( Npunc > Ncoord/2+2 )
    mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:incompatible",
                      "Too many punctures in the braid." );

  const mwSize Ngen = mxGetNumberOfElements(P_SIGMA_IDX);

  mxArray *opSign = NULL;
  if (nlhs > 1) {
    const int maxOpSign = 5;
    P_OPSIGN = mxCreateDoubleMatrix(Nloops,maxOpSign*Ngen,mxREAL);
    opSign = P_OPSIGN;
  }
  else {
    P_OPSIGN = NULL; opSign = NULL;
  }

  // Allocate output cell array.
  P_LOOP_OUT = mxDuplicateArray(P_LOOP_IN);

  switch( mxGetClassID( P_LOOP_OUT ) ) {

  case mxDOUBLE_CLASS: {
    BraidInPlace<double> braid(P_LOOP_OUT, P_SIGMA_IDX, P_OPSIGN);
    braid.run(Nthreads);
    break; }
  case mxSINGLE_CLASS: {
    BraidInPlace<float> braid(P_LOOP_OUT, P_SIGMA_IDX, P_OPSIGN);
    braid.run(Nthreads);
    break; }
  case mxINT32_CLASS: {
    BraidInPlace<int> braid(P_LOOP_OUT, P_SIGMA_IDX, P_OPSIGN);
    braid.run(Nthreads);
    break; }
  case mxINT64_CLASS: {
    BraidInPlace<long long int> braid(P_LOOP_OUT, P_SIGMA_IDX, P_OPSIGN);
    braid.run(Nthreads);
    break; }
#ifdef BRAIDLAB_USE_GMP
  case mxCELL_CLASS: {

    // convert input to MultiPrecision class
    std::vector<mpz_class> loop (Ncoord*Nloops);
    convertCellLoopToGMP( P_LOOP_IN, loop.data() );
    BraidInPlace<mpz_class> braid(loop.data() , Nloops, Ncoord, P_SIGMA_IDX, P_OPSIGN);
    braid.run(Nthreads);

    convertGMPToCellLoop( loop.data(), P_LOOP_OUT );

    break; }
#endif
  default: {
    mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badtype",
                      "Unknown variable type '%s'.",mxGetClassName(P_LOOP_IN));
  }
  }
}

#ifdef BRAIDLAB_USE_GMP
void convertGMPToCellLoop( mpz_class * loopOut, mxArray* cellLoop ) {

  const mwSize Ncoord = mxGetM(cellLoop);
  const mwSize Nloops = mxGetN(cellLoop);

  mwIndex subs[2];
  mwIndex idx;
  mxArray* s;
  // Convert mpz_class objects back to strings, store in cell array.
  for (mwIndex l = 0; l < Nloops; ++l) {
    for (mwIndex k = 0; k < Ncoord; ++k) {
      subs[0] = k;
      subs[1] = l;
      idx = mxCalcSingleSubscript(cellLoop,2,subs);
      s = mxCreateString(loopOut[k+Ncoord*l].get_str().c_str());
      mxSetCell(cellLoop,idx,s);
    }
  }

}

void convertCellLoopToGMP( const mxArray* cellLoop, mpz_class * loopIn) {

  const mwSize Ncoord = mxGetM(cellLoop);
  const mwSize Nloops = mxGetN(cellLoop);

  // Array for Matlab mxArray subscripts.
  mwIndex subs[2];
  mwIndex idx;

  // Convert cell of mxArray strings to mpz_class objects.
  for (unsigned int l = 0; l < Nloops; l++) {
    for (unsigned int k = 0; k < Ncoord; k++) {
      // rows - coordinate, column - loop
      subs[0] = k; subs[1] = l;
      idx = mxCalcSingleSubscript(cellLoop,2,subs);
      loopIn[k+l*Ncoord] =
        mpz_class(mxArrayToString(mxGetCell(cellLoop,idx)));
    }
  }

}

#endif
