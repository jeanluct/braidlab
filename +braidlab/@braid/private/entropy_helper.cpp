#include <cmath>
#include <cstdio>
#include <algorithm>
#include "mex.h" // overloads printf -> mexPrintf
#include "update_rules.hpp"
// implementations of loop length calculations
#include "../../@loop/private/loop_helper.hpp"

// Helper function for entropy method

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://bitbucket.org/jeanluc/braidlab/
//
//   Copyright (C) 2013--2014  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                             Marko Budisic         <marko@math.wisc.edu>
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

// function that switches the type of length computation
// throws BRAIDLAB:entropy_helper:badlengthflag if
// passed length flag is unsupported
double looplength( mwSize N, double *a, double *b, char lengthFlag );

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // Get debug level global variable.
  mxArray *dbglvl_ptr = mexGetVariable("global", "BRAIDLAB_debuglvl");
  int dbglvl = 0;
  if (dbglvl_ptr != NULL)
    if (mxGetM(dbglvl_ptr) != 0)
      dbglvl = (int)mxGetPr(dbglvl_ptr)[0];

  const mxArray *iiA = prhs[0];
  const int *ii = (int *)mxGetData(iiA); // iiA contains int32's.
  const mxArray *uA = prhs[1];
  const double *u = mxGetPr(uA);

  const int maxit = (int)mxGetScalar(prhs[2]);
  const int nconvreq = (int)mxGetScalar(prhs[3]);
  const double tol = mxGetScalar(prhs[4]);

  const char lengthFlag =
    static_cast<char>( mxGetScalar(prhs[5]) );

  const mwSize Ngen = std::max(mxGetM(iiA),mxGetN(iiA));

  const mwSize N = mxGetN(uA);
  if (mxGetM(uA) != 1)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:entropy_helper:badarg",
                        "Only one loop at a time.");
    }
  if (N % 2 != 0)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:entropy_helper:badarg",
                        "u argument should have even number of columns.");
    }
  // Refers to generators, so don't need to be mwIndex/mwSize.
  const int n = (int)(N/2 + 2);

  // Make 1-indexed arrays.
  double *a = new double[N/2] - 1;
  double *b = new double[N/2] - 1;

  for (mwIndex k = 1; k <= N/2; ++k) { a[k] = u[k-1]; b[k] = u[k-1+N/2]; }

  int it, nconv = 0; double entr, entr0 = -1;
  for (it = 1; it <= maxit; ++it)
    {
      // Normalize coordinates.
      double l2 = looplength(N,a,b,lengthFlag);
      for (mwIndex k = 1; k <= N/2; ++k) { a[k] /= l2; b[k] /= l2; }

      // Act with the braid sequence in ii onto the coordinates a,b.
      update_rules(Ngen, n, ii, a, b);

      entr = log(looplength(N,a,b,lengthFlag));

      if (dbglvl >= 2)
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
          if (dbglvl >= 1)
            printf("Converged %d time(s) in a row (< %d)\n",nconv,nconvreq);
          nconv = 0;
        }

      entr0 = entr;
    }

  plhs[0] = mxCreateDoubleScalar(entr);
  plhs[1] = mxCreateDoubleScalar(it);

  // Create an mxArray for the output data.
  plhs[2] = mxCreateDoubleMatrix(1, N, mxREAL);
  double *uo = mxGetPr(plhs[2]);
  // Copy final a and b to row of output array.
  for (mwIndex k = 1; k <= N/2; ++k) { uo[k-1] = a[k]; uo[k-1+N/2] = b[k]; }

  delete[] (a+1);
  delete[] (b+1);

  if (dbglvl_ptr != NULL)
    if (mxGetM(dbglvl_ptr) != 0)
      mxDestroyArray(dbglvl_ptr);

  return;
}

double looplength( mwSize N, double *a, double *b, char lengthFlag ) {

  double retval = -1;

  switch( lengthFlag ) {

  case 0:
    retval = sqrt(l2norm2(N,a,b));
    break;

  case 1:
    retval = intaxis<double>(N,a,b);
    break;

  case 2:
    retval = minlength<double>(N,a,b);
    break;

  default:
    mexErrMsgIdAndTxt("BRAIDLAB:entropy_helper:badlengthflag",
                      "Supported flags: 0 (l2), 1 (intaxis), 2 (minlength).");
    break;
  }

  return retval;

}
