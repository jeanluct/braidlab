#include <math.h>
#include <stdio.h>
#include "mex.h"

/* Helper function for looplistsigma */

#define pos(x) (x > 0 ? x : 0)
#define neg(x) (x < 0 ? x : 0)
#define MAX(a,b)  (a > b ? a : b)

double loopinter(const int n, const double *a, const double *b)
{
  int i;
  double sumab = 0;

  for (i = 1; i <= n-2; ++i)
    {
      sumab += fabs(a[i]) + fabs(b[i]);
    }

  return sumab;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int i, j, k, l, m, n, N, Nr, nout, Ngen;
  bool grow;
  const mxArray *iiA;
  const double *ii, *umin, *umax;
  double *a, *b, *ap, *bp, *uo, *u;
  double c, d, Nrd, len, len0, maxgr;

  if (nrhs < 3)
    {
      mexErrMsgTxt("3 input arguments required.");
      exit(1);
    }

  iiA = prhs[0];
  ii = mxGetPr(iiA);
  umin = mxGetPr(prhs[1]);
  umax = mxGetPr(prhs[2]);
  maxgr = mxGetScalar(prhs[3]);

  Ngen = MAX(mxGetM(iiA),mxGetN(iiA));

  N = MAX(mxGetM(prhs[1]),mxGetN(prhs[1]));
  if (N != MAX(mxGetM(prhs[2]),mxGetN(prhs[2])))
    { mexErrMsgTxt("Inconsistent bounds"); exit(1); }

  if (N % 2 != 0)
    {
      mexErrMsgTxt("u argument should have even number of columns.");
      exit(1);
    }
  n = N/2 + 2;

  /* Compute the number of combinations */
  Nr = (int) (umax[0]-umin[0]+1);
  Nrd = (double) Nr;  /* Also compute a double version to check for overflow*/
  for (m = 1; m < N; ++m)
    {
      Nr *= (int) (umax[m]-umin[m]+1);
      Nrd *= (double) (umax[m]-umin[m]+1);
      if (Nrd > (double)INT_MAX)
	{ mexErrMsgTxt("Beyond integer range..."); exit(1); }
    }
  mexPrintf("%d loops\n",Nr);
  mexEvalString("drawnow;");

  /* Make 1-indexed arrays */
  a = (double *) malloc(N/2 * sizeof(double)) - 1;
  b = (double *) malloc(N/2 * sizeof(double)) - 1;
  ap = (double *) malloc(N/2 * sizeof(double)) - 1;
  bp = (double *) malloc(N/2 * sizeof(double)) - 1;
  /* 0-indexed array for loop */
  u = (double *) malloc(N * sizeof(double));

  for (m = 0; m < N; ++m) { u[m] = umin[m]; }

  /* Create an mxArray for the output data */
  nout = 0;
  plhs[0] = mxCreateDoubleMatrix(N, 0, mxREAL);
  uo = mxGetPr(plhs[0]);

  for (l = 0; l < Nr; ++l) /* Loop over loops */
    {
      grow = false;

      /* Copy initial loop u to a and b vectors */
      for (k = 1; k <= N/2; ++k)
	{
	  a[k] = u[(k-1)];
	  b[k] = u[(k-1)+N/2];
	  ap[k] = a[k];
	  bp[k] = b[k];
	}

      len0 = loopinter(n,a,b);

      for (j = 0; j < Ngen; ++j) /* Loop over generators */
	{
	  i = fabs(ii[j]);
	  if (ii[j] > 0)
	    {
	      if (i == 1)
		{
		  bp[1] = a[1] + pos(b[1]);
		  ap[1] = -b[1] + pos(bp[1]);
		}
	      else if (i == n-1)
		{
		  bp[n-2] = a[n-2] + neg(b[n-2]);
		  ap[n-2] = -b[n-2] + neg(bp[n-2]);
		}
	      else
		{
		  c = a[i-1] - a[i] - pos(b[i]) + neg(b[i-1]);
		  ap[i-1] = a[i-1] - pos(b[i-1]) - pos(pos(b[i]) + c);
		  bp[i-1] = b[i] + neg(c);
		  ap[i] = a[i] - neg(b[i]) - neg(neg(b[i-1]) - c);
		  bp[i] = b[i-1] - neg(c);
		}
	    }
	  else if (ii[j] < 0)
	    {
	      if (i == 1)
		{
		  bp[1] = -a[1] + pos(b[1]);
		  ap[1] = b[1] - pos(bp[1]);
		}
	      else if (i == n-1)
		{
		  bp[n-2] = -a[n-2] + neg(b[n-2]);
		  ap[n-2] = b[n-2] - neg(bp[n-2]);
		}
	      else
		{
		  d = a[i-1] - a[i] + pos(b[i]) - neg(b[i-1]);
		  ap[i-1] = a[i-1] + pos(b[i-1]) + pos(pos(b[i]) - d);
		  bp[i-1] = b[i] - pos(d);
		  ap[i] = a[i] + neg(b[i]) + neg(neg(b[i-1]) + d);
		  bp[i] = b[i-1] + pos(d);
		}
	    }

	  /* Check if the loop has grown too much */
	  if (len0) len = loopinter(n,a,b)/len0;
	  if (len > maxgr) { grow = true; break; }

	  for (k = 1; k <= N/2; ++k) { a[k] = ap[k]; b[k] = bp[k]; }
	}

      if (!(l % 10000))
	{
	  mexPrintf("loop %d has final length %.2f",l,len);
	  mexPrintf(" (%.1f\%)\n",100*(double)(l+1)/Nr);
	  mexEvalString("drawnow;");
	}

      if (!grow && len0 > 0) /* Skip null loop */
	{
	  /* Grow output array uo */
	  uo = mxRealloc(uo, ++nout*N*sizeof(double));
	  mxSetPr(plhs[0], uo);
	  mxSetN(plhs[0],nout);
	  for (m = 0; m < N; ++m) { uo[m+(nout-1)*N] = u[m]; }
	}

      /* Increment loop vector u */
      for (m = N-1; m >= 0; --m)
	{
	  /* The sequence that coefficients cycle through is
	     umin[m]...umax[m] for u[m], 0 <= m < N */
	  if (u[m] < umax[m])
	    {
	      /* Increment the coefficient */
	      u[m] = u[m] + 1;
	      break;
	    }
	  else
	    {
	      /* Otherwise reset coefficient at that position, and let
		 the loop move on to the next position. */
	      u[m] = umin[m];
	    }
	}
    }

  free(a+1);
  free(b+1);
  free(ap+1);
  free(bp+1);
  free(u);

  return;
}
