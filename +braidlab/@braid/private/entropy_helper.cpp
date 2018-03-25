#include <cmath>
#include <cstdio>
#include <algorithm>
#include "mex.h" // overloads printf -> mexPrintf

#include "update_rules.hpp"
// implementations of loop length calculations
#include "../../@loop/private/loop_helper.hpp"

// Helper function for entropy method
// Arguments:
// 0 - braid word
// 1 - loop Dynnikov coordinate vector
// 2 - maximum number of iterations
// 3 - number of consecutive time tolerance should be achieved
// 4 - tolerance

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

int BRAIDLAB_debuglvl = -1;

#define P_BRAID   prhs[0]
#define P_LOOP_IN prhs[1]
#define P_MAXIT prhs[2]
#define P_NCONVREQ prhs[3]
#define P_TOL prhs[4]

#define P_ENTROPY plhs[0]
#define P_ITERATES plhs[1]
#define P_LOOP_OUT plhs[2]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if (nlhs < 3)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:braid:entropy_helper:badarg",
                        "%d is not enough output arguments; need %d.",nrhs,3);
    }
  if (nrhs < 5)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:braid:entropy_helper:badarg",
                        "%d is not enough input arguments; need %d.",nrhs,5);
    }

  // Get debug level global variable.
  mxArray *isDebug = mexGetVariable("global", "BRAIDLAB_debuglvl");
  if (isDebug) {
    BRAIDLAB_debuglvl = (int) mxGetScalar(isDebug);
  }

  const int *braidword = (int *)mxGetData(P_BRAID); // P_BRAID contains int32's.
  const double *u = mxGetPr(P_LOOP_IN);

  const int maxit = (int)mxGetScalar(P_MAXIT);
  const int nconvreq = (int)mxGetScalar(P_NCONVREQ);
  const double tol = mxGetScalar(P_TOL);

  const mwSize Ngen = std::max(mxGetM(P_BRAID),mxGetN(P_BRAID));

  const mwSize N = mxGetN(P_LOOP_IN);
  if (mxGetM(P_LOOP_IN) != 1)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:braid:entropy_helper:badarg",
                        "Only one loop at a time.");
    }
  if (N % 2 != 0)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:braid:entropy_helper:badarg",
                        "loop argument should have even number of columns.");
    }

  // number of loop punctures (including boundary point)
  const int n = (int)(N/2 + 2);

  // Make 1-indexed arrays.
  std::vector<double> a_storage(N/2);
  std::vector<double> b_storage(N/2);

  double *a = a_storage.data() - 1;
  double *b = b_storage.data() - 1;

  for (mwIndex k = 1; k <= N/2; ++k)
    {
      a[k] = u[k-1];
      b[k] = u[k-1+N/2];
    }

  int it;
  int nconv = 0;
  double entr;
  double entr0 = -1;

  double currentLength = std::sqrt(l2norm2(N,a,b));

  for (it = 1; it <= maxit; ++it)
    {
      // Normalize coordinates by the loop length.
      for (mwIndex k = 1; k <= N/2; ++k)
        {
          a[k] /= currentLength;
          b[k] /= currentLength;
        }

      // Act with the braid sequence in braidword onto the coordinates a,b.
      update_rules(Ngen, n, braidword, a, b);

      currentLength = std::sqrt(l2norm2(N,a,b));

      entr = std::log(currentLength);

      if (BRAIDLAB_debuglvl >= 1)
        printf("  iteration %d  entr=%.10e  diff=%.4e\n",
                  it, entr, entr-entr0);

      if (fabs(entr - entr0) < tol)
        {
          // We've converged!
          ++nconv;
          if (nconv >= nconvreq)
            {
              // Only break if we converged enough times in a row.
              break;
            }
        }
      else if (nconv > 0)
        {
          // Reset consecutive convergence counter.
          if (BRAIDLAB_debuglvl >= 1)
            printf("Converged %d time(s) in a row (< %d)\n",nconv,nconvreq);
          nconv = 0;
        }

      entr0 = entr;
    }

  P_ENTROPY = mxCreateDoubleScalar(entr);
  P_ITERATES = mxCreateDoubleScalar(it);

  // Create an mxArray for the output data.
  P_LOOP_OUT = mxCreateDoubleMatrix(1, N, mxREAL);
  double *uo = mxGetPr(P_LOOP_OUT);
  // Copy final a and b to row of output array.
  for (mwIndex k = 1; k <= N/2; ++k) { uo[k-1] = a[k]; uo[k-1+N/2] = b[k]; }

  return;
}
