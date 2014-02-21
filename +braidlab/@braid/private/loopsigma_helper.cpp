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
//   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
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


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if (nrhs < 2)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:nargin",
                        "2 input arguments required.");
    }

  // Figure out the type in mxArray uA by calling Matlab's "class" function.
  const mxArray *uA = prhs[1];
  mxArray *lhs[1];
  mexCallMATLAB(1, lhs, 1, (mxArray **)(&uA), "class");
  std::string typ = mxArrayToString(lhs[0]);

  // Dimensions of uA.
  const mwSize N = mxGetN(uA), Nr = mxGetM(uA);

  const mxArray *iiA = prhs[0];
  const int *ii = (int *)mxGetData(iiA); // iiA contains int32's.
  const mwSize Ngen = std::max(mxGetM(iiA),mxGetN(iiA));

  mxArray *pnA = 0;
  if (nlhs > 1)
    {
      const int maxpn = 5;
      plhs[1] = mxCreateDoubleMatrix(Nr,maxpn*Ngen,mxREAL);
      pnA = plhs[1];
    }

  if (typ == "double")
    {
      plhs[0] = mxCreateNumericMatrix(Nr, N, mxDOUBLE_CLASS, mxREAL);
      loopsigma_helper_common<double>(Ngen,ii,uA,plhs[0],pnA);
    }
  else if (typ == "single")
    {
      plhs[0] = mxCreateNumericMatrix(Nr, N, mxSINGLE_CLASS, mxREAL);
      loopsigma_helper_common<float>(Ngen,ii,uA,plhs[0],pnA);
    }
  else if (typ == "int32")
    {
      plhs[0] = mxCreateNumericMatrix(Nr, N, mxINT32_CLASS, mxREAL);
      loopsigma_helper_common<int>(Ngen,ii,uA,plhs[0],pnA);
    }
  else if (typ == "int64")
    {
      plhs[0] = mxCreateNumericMatrix(Nr, N, mxINT64_CLASS, mxREAL);
      loopsigma_helper_common<long long int>(Ngen,ii,uA,plhs[0],pnA);
    }
#ifdef BRAIDLAB_USE_GMP
  else if (typ == "cell")
    {
      // Cell array of strings, to be converted to multiprecision objects.

      // Array for Matlab mxArray subscripts.
      mwSize nsubs = 2;
      mwIndex *subs = (mwIndex *)mxCalloc(nsubs,sizeof(mwIndex));

      // Pointer to input data.
      const mxArray *uA = prhs[1];

      // Allocate input and output GMP multiprecision array.
      mpz_class *u = new mpz_class[N*Nr];
      mpz_class *uo = new mpz_class[N*Nr];

      // Convert cell of mxArray strings to mpz_class objects.
      for (mwIndex l = 0; l < Nr; ++l)
        {
          for (mwIndex k = 0; k < N; ++k)
            {
              subs[0] = l; subs[1] = k;
              mwIndex idx = mxCalcSingleSubscript(uA,nsubs,subs);
              mxArray *cA = mxGetCell(uA,idx);
              u[k*Nr+l] = mpz_class(mxArrayToString(cA));
            }
        }

      // Act on coordinates with braid.
      loopsigma_helper_gmp(Ngen,ii,Nr,N,u,uo,pnA);

      // Vector of array dimensions.
      mwSize *dims = (mwSize *)mxCalloc(nsubs,sizeof(mwSize));
      dims[0] = Nr; dims[1] = N;
      // Allocate output cell array.
      plhs[0] = mxCreateCellArray(nsubs,dims);

      // Convert mpz_class objects back to strings, store in cell array.
      for (mwIndex l = 0; l < Nr; ++l)
        {
          for (mwIndex k = 0; k < N; ++k)
            {
              subs[0] = l; subs[1] = k;
              mwIndex idx = mxCalcSingleSubscript(plhs[0],nsubs,subs);
              mxArray *s = mxCreateString(uo[k*Nr+l].get_str().c_str());
              mxSetCell(plhs[0],idx,s);
            }
        }

      mxFree(dims);
      mxFree(subs);
      delete[] u;
      delete[] uo;
    }
#endif
  else
    {
      mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badtype",
                        "Unknown variable type '%s'.",typ.c_str());
    }
}
