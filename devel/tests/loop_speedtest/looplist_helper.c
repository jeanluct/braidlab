#include <math.h>
#include <stdio.h>
#include "mex.h"

/*  */

#define MAX(a,b)  (a > b ? a : b)

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int m, r, n, nr, nrd;
  const double *amin, *amax;
  double *a;

  if (nrhs < 2)
    { mexErrMsgTxt("2 input arguments required"); exit(1); }

  n = MAX(mxGetM(prhs[0]),mxGetN(prhs[0]));
  if (n != MAX(mxGetM(prhs[1]),mxGetN(prhs[1])))
    { mexErrMsgTxt("Inconsistent bounds"); exit(1); }

  /* TODO: write wrapper to allow for scalar */
  amin = mxGetPr(prhs[0]);
  amax = mxGetPr(prhs[1]);

  /* Compute the number of combinations */
  nr = (int) (amax[0]-amin[0]+1);
  nrd = (double) nr;  /* Also compute a double version to check
				for overflow*/
  for (m = 1; m < n; ++m)
    {
      nr *= (int) (amax[m]-amin[m]+1);
      nrd *= (double) (amax[m]-amin[m]+1);
      if (nrd > (double)INT_MAX)
	{ mexErrMsgTxt("Beyond integer range..."); exit(1); }
    }

  /* Create an mxArray for the output data */
  plhs[0] = mxCreateDoubleMatrix(nr, n, mxREAL);
  a = mxGetPr(plhs[0]); /* a[col*nrows + row] */
  for (m = 0; m < n; ++m) { a[m*nr + 0] = amin[m]; }

  for (r = 1; r < nr; ++r)
    {
      /* Set coefficients to previous entry */
      for (m = 0; m < n; ++m) { a[m*nr + r] = a[m*nr + r-1]; }

      /*
	Increment elements of the vector a (from the last element),
	resetting each position a[m] to amin[m] if it passes amax[m].
      */
      for (m = n-1; m >= 0; --m)
	{
	  /* The sequence that coefficients cycle through is
	     amin[m]...amax[m] for a[m], 0 <= m < n */
	  if (a[m*nr+r] < amax[m])
	    {
	      /* Increment the coefficient */
	      a[m*nr+r] = a[m*nr+r] + 1;
	      break;
	    }
	  else
	    {
	      /* Otherwise reset coefficient at that position, and let
		 the loop move on to the next position. */
	      a[m*nr+r] = amin[m];
	    }
	}
    }

  return;
}
