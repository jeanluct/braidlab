//
// Matlab MEX file
//
// RANDOMWALK_HELPER
//

// Helper file for randomwalk.m.

#include <iostream>
#include <cmath>
#include "mex.h"

extern void _main();

//
//
//

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;

  mwSize n = (mwSize) mxGetScalar(prhs[0]);
  mwSize N = (mwSize) mxGetScalar(prhs[1]);
  double eps = mxGetScalar(prhs[2]);

  // Particles are uniformly distributed in [0,1]^2.
  // Execute Matlab command "X0 = rand(2,n);"
  mxArray *X0A, *prhs2[2];
  prhs2[0] = mxCreateDoubleScalar(2);
  prhs2[1] = mxCreateDoubleScalar(n);
  mexCallMATLAB(1,&X0A,2,prhs2,"rand");
  double *X0 = mxGetPr(X0A);

  // Allocate memory for particle paths and copy initial conditions.
  const mwSize dim[3] = {N+1,2,n};
  plhs[0] = mxCreateNumericArray(3,dim,mxDOUBLE_CLASS,mxREAL);
  double *X = mxGetPr(plhs[0]);
  for (mwIndex p = 0; p < n; ++p)
    {
      for (mwIndex ixy = 0; ixy < 2; ++ixy)
	X[0 + ixy*(N+1) + p*2*(N+1)] = X0[ixy + p*2];
    }

  //
  // Generate the displacements.
  //
  // Execute Matlab command "theta = rand(N,n);"
  //
  mxArray *thetaA;
  prhs2[0] = mxCreateDoubleScalar(N);
  prhs2[1] = mxCreateDoubleScalar(n);
  mexCallMATLAB(1,&thetaA,2,prhs2,"rand");
  double *theta = mxGetPr(thetaA);

  //
  // Add up the displacements, reflect at boundaries.
  //
  for (mwIndex p = 0; p < n; ++p)
    {
      for (mwIndex i = 1; i <= N; ++i)
	{
	  int idx = i-1 + p*N;
	  double d[2] = {eps*cos(2*M_PI*theta[idx]),eps*sin(2*M_PI*theta[idx])};
	  for (mwIndex ixy = 0; ixy < 2; ++ixy)
	    {
	      int iixy = i + ixy*(N+1) + p*2*(N+1);
	      X[iixy] = X[iixy-1] + d[ixy];
	      // Reflect if walk leaves interval.
	      // Note: this requires a small step size.
	      if (X[iixy] > 1) X[iixy] = 2-X[iixy];
	      if (X[iixy] < 0) X[iixy] = -X[iixy];
	    }
	}
    }

  mxDestroyArray(X0A);
  mxDestroyArray(thetaA);
  mxDestroyArray(prhs2[0]);
  mxDestroyArray(prhs2[1]);
}
