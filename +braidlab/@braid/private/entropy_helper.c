#include <math.h>
#include <stdio.h>
#include "mex.h"

/* Helper function for entropy method */

/*
 <LICENSE
   Copyright (c) 2013, 2014 Jean-Luc Thiffeault

   This file is part of Braidlab.

   Braidlab is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Braidlab is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
 LICENSE>
*/

#define MAX(a,b)  (a > b ? a : b)

__inline__
void update_rules(const int Ngen, const int n, const int *ii,
                  double *a, double *b);

__inline__
double l2norm(const int N, const double *a, const double *b)
{
  int k;
  double l2;

  l2 = 0;
  for (k = 1; k <= N/2; ++k) l2 += a[k]*a[k] + b[k]*b[k];
  return sqrt(l2);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int it, maxit, nconv, nconvreq, dbglvl;
  int n; /* Refer to generators, so don't need to be mwIndex/mwSize. */
  mwIndex k, l;
  mwSize N, Ngen;
  const mxArray *iiA, *uA;
  mxArray *dbglvl_ptr;
  const int *ii;
  const double *u;
  double entr, entr0, tol, l2, *a, *b, *uo;

  /* Get debug level global variable */
  dbglvl_ptr = mexGetVariable("global", "BRAIDLAB_debuglvl");
  dbglvl = 0;
  if (dbglvl_ptr != NULL)
    if (mxGetM(dbglvl_ptr) != 0)
      dbglvl = (int)mxGetPr(dbglvl_ptr)[0];

  iiA = prhs[0];
  ii = (int *)mxGetData(iiA); /* iiA contains int32's. */
  uA = prhs[1];
  u = mxGetPr(uA);

  maxit = (int)mxGetScalar(prhs[2]);
  nconvreq = (int)mxGetScalar(prhs[3]);
  tol = mxGetScalar(prhs[4]);

  Ngen = MAX(mxGetM(iiA),mxGetN(iiA));

  N = mxGetN(uA);
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
  n = (int)(N/2 + 2);

  /* Make 1-indexed arrays */
  a = (double *) malloc(N/2 * sizeof(double)) - 1;
  b = (double *) malloc(N/2 * sizeof(double)) - 1;

  for (k = 1; k <= N/2; ++k) { a[k] = u[k-1]; b[k] = u[k-1+N/2]; }

  nconv = 0; entr0 = -1;
  for (it = 1; it <= maxit; ++it)
    {
      /* Normalize coordinates */
      l2 = l2norm(N,a,b);
      for (k = 1; k <= N/2; ++k) { a[k] /= l2; b[k] /= l2; }

      /* Act with the braid sequence in ii onto the coordinates a,b. */
      update_rules(Ngen, n, ii, a, b);

      entr = log(l2norm(N,a,b));

      if (dbglvl >= 2)
	mexPrintf("  iteration %d  entr=%.10e\n",it,entr);

      if (fabs(entr - entr0) < tol)
	{
	  /* We've converged! */
	  ++nconv;
	  if (nconv >= nconvreq)
	    {
	      /* Only break if we converged enough times in a row. */
	      break;
	    }
	}
      else if (nconv > 0)
	{
	  /* Reset consecutive convergence counter. */
	  if (dbglvl >= 1)
	    mexPrintf("Converged %d time(s) in a row (< %d)\n",nconv,nconvreq);
	  nconv = 0;
	}

      entr0 = entr;
    }

  plhs[0] = mxCreateDoubleScalar(entr);
  plhs[1] = mxCreateDoubleScalar(it);

  /* Create an mxArray for the output data */
  plhs[2] = mxCreateDoubleMatrix(1, N, mxREAL);
  uo = mxGetPr(plhs[2]);
  /* Copy final a and b to row of output array */
  for (k = 1; k <= N/2; ++k) { uo[k-1] = a[k]; uo[k-1+N/2] = b[k]; }

  free(a+1);
  free(b+1);
  if (dbglvl_ptr != NULL)
    if (mxGetM(dbglvl_ptr) != 0)
      mxDestroyArray(dbglvl_ptr);

  return;
}
