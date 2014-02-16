#include <cmath>
#include <cstdio>
#include <string>
#include "mex.h"
#include "loopsigma_helper_common.hpp"

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

  if (typ == "double")
    {
      plhs[0] = mxCreateNumericMatrix(Nr, N, mxDOUBLE_CLASS, mxREAL);
      loopsigma_helper_common<double>(Ngen,ii,uA,plhs[0]);
    }
  else if (typ == "single")
    {
      plhs[0] = mxCreateNumericMatrix(Nr, N, mxSINGLE_CLASS, mxREAL);
      loopsigma_helper_common<float>(Ngen,ii,uA,plhs[0]);
    }
  else if (typ == "int32")
    {
      plhs[0] = mxCreateNumericMatrix(Nr, N, mxINT32_CLASS, mxREAL);
      loopsigma_helper_common<int>(Ngen,ii,uA,plhs[0]);
    }
  else if (typ == "int64")
    {
      plhs[0] = mxCreateNumericMatrix(Nr, N, mxINT64_CLASS, mxREAL);
      loopsigma_helper_common<long long int>(Ngen,ii,uA,plhs[0]);
    }
  else
    {
      mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badtype",
                        "Unknown variable type.");
    }
}
