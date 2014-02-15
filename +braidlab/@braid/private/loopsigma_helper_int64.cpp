#include <math.h>
#include <stdio.h>
#include "mex.h"
#include "update_rules.hpp"

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

#define MAX(a,b)  (a > b ? a : b)

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  typedef long long int loop_type;
  int n; // Refers to generators, so don't need to be mwIndex/mwSize.
  mwIndex k, l;
  mwSize N, Nr, Ngen;
  const mxArray *iiA, *uA;
  const int *ii;
  const loop_type *u;
  loop_type *a, *b, *uo;

  if (nrhs < 2)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:nargin",
                        "2 input arguments required.");
    }

  iiA = prhs[0];
  ii = (int *)mxGetData(iiA); // iiA contains int32's.
  uA = prhs[1];
  u = (loop_type *)mxGetPr(uA);

  Ngen = MAX(mxGetM(iiA),mxGetN(iiA));

  N = mxGetN(uA);
  Nr = mxGetM(uA);
  if (N % 2 != 0)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badarg",
                        "u argument should have even number of columns.");
    }
  n = (int)(N/2 + 2);

  // Make 1-indexed arrays.
  a = (loop_type *) malloc(N/2 * sizeof(loop_type)) - 1;
  b = (loop_type *) malloc(N/2 * sizeof(loop_type)) - 1;

  // Create an mxArray for the output data.
  plhs[0] = mxCreateNumericMatrix(Nr, N, mxINT64_CLASS, mxREAL);
  uo = (loop_type *)mxGetPr(plhs[0]);

  for (l = 0; l < Nr; ++l) // Loop over rows of u.
    {
      // Copy initial row data.
      for (k = 1; k <= N/2; ++k)
        {
          a[k] = u[(k-1    )*Nr+l];
          b[k] = u[(k-1+N/2)*Nr+l];
        }

      // Act with the braid sequence in ii onto the coordinates a,b.
      update_rules(Ngen, n, ii, a, b);

      for (k = 1; k <= N/2; ++k)
        {
          // Copy final a and b to row of output array.
          uo[(k-1    )*Nr+l] = a[k];
          uo[(k-1+N/2)*Nr+l] = b[k];
        }
    }

  free(a+1);
  free(b+1);

  return;
}
