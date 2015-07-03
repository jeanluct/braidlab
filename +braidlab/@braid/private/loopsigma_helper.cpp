#include <cmath>
#include <cstdio>
#include <string>
#include "mex.h"
#include "loopsigma_helper_common.hpp"
#ifdef BRAIDLAB_USE_GMP
#include <iostream>
#include <gmpxx.h>
#endif

// Helper function for loopsigma

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

#define P_SIGMA_IDX prhs[0]
#define P_LOOP prhs[1]

#define P_LOOPOUT plhs[0]
#define P_OPSIGN  plhs[1]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  if (nrhs < 2) {
    mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:nargin",
                      "2 input arguments required.");
  }

  // Dimensions of P_LOOP.
  const mwSize Ncoord = mxGetN(P_LOOP), Nloops = mxGetM(P_LOOP);

  const int *sigma_idx = (int *)mxGetData(P_SIGMA_IDX); // P_SIGMA_IDX contains int32's.
  const mwSize Ngen = std::max(mxGetM(P_SIGMA_IDX),mxGetN(P_SIGMA_IDX));

  mxArray *opSign = 0;
  if (nlhs > 1) {
    const int maxOpSign = 5;
    P_OPSIGN = mxCreateDoubleMatrix(Nloops,maxOpSign*Ngen,mxREAL);
    opSign = P_OPSIGN;
  }

  switch( mxGetClassID( P_LOOP ) ) {

  case mxDOUBLE_CLASS: {
    P_LOOPOUT = mxCreateNumericMatrix(Nloops, Ncoord, mxDOUBLE_CLASS, mxREAL);
    loopsigma_helper_common<double>(Ngen,sigma_idx,P_LOOP,P_LOOPOUT,opSign);
    break; }
  case mxSINGLE_CLASS: {
    P_LOOPOUT = mxCreateNumericMatrix(Nloops, Ncoord, mxSINGLE_CLASS, mxREAL);
    loopsigma_helper_common<float>(Ngen,sigma_idx,P_LOOP,P_LOOPOUT,opSign);
    break; }
  case mxINT32_CLASS: {
    P_LOOPOUT = mxCreateNumericMatrix(Nloops, Ncoord, mxINT32_CLASS, mxREAL);
    loopsigma_helper_common<int>(Ngen,sigma_idx,P_LOOP,P_LOOPOUT,opSign);
    break; }
  case mxINT64_CLASS: {
    P_LOOPOUT = mxCreateNumericMatrix(Nloops, Ncoord, mxINT64_CLASS, mxREAL);
    loopsigma_helper_common<long long int>(Ngen,sigma_idx,P_LOOP,P_LOOPOUT,opSign);
    break; }
#ifdef BRAIDLAB_USE_GMP
  case mxCELL_CLASS: {
    // Cell array of strings, to be converted to multiprecision objects.

    // Array for Matlab mxArray subscripts.
    mwSize nsubs = 2;
    mwIndex *subs = (mwIndex *)mxCalloc(nsubs,sizeof(mwIndex));

    // Pointer to input data.
    const mxArray *loop = prhs[1];

    // Allocate input and output GMP multiprecision array.
    mpz_class *loopIn = new mpz_class[Ncoord*Nloops];
    mpz_class *loopOut = new mpz_class[Ncoord*Nloops];

    // Convert cell of mxArray strings to mpz_class objects.
    for (mwIndex l = 0; l < Nloops; ++l) {
      for (mwIndex k = 0; k < Ncoord; ++k) {
        subs[0] = l;
        subs[1] = k;
        mwIndex idx = mxCalcSingleSubscript(P_LOOP,nsubs,subs);
        loopIn[k*Nloops+l] =
          mpz_class(mxArrayToString(mxGetCell(P_LOOP,idx)));
      }
    }

    // Act on coordinates with braid.
    loopsigma_helper_gmp(Ngen,sigma_idx,Nloops,Ncoord,loopIn,loopOut,opSign);

    // Vector of array dimensions.
    mwSize *dims = (mwSize *)mxCalloc(nsubs,sizeof(mwSize));
    dims[0] = Nloops;
    dims[1] = Ncoord;
    // Allocate output cell array.
    P_LOOPOUT = mxCreateCellArray(nsubs,dims);

    // Convert mpz_class objects back to strings, store in cell array.
    for (mwIndex l = 0; l < Nloops; ++l) {
      for (mwIndex k = 0; k < Ncoord; ++k) {
        subs[0] = l;
        subs[1] = k;
        mwIndex idx = mxCalcSingleSubscript(P_LOOPOUT,nsubs,subs);
        mxArray *s = mxCreateString(loopOut[k*Nloops+l].get_str().c_str());
        mxSetCell(P_LOOPOUT,idx,s);
      }
    }
    mxFree(dims);
    mxFree(subs);
    delete[] loopIn;
    delete[] loopOut;
    break; }
#endif
  default: {
    mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badtype",
                      "Unknown variable type '%s'.",mxGetClassName(P_LOOP) );
  }
  }
}
