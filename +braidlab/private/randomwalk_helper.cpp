//
// Matlab MEX file
//
// RANDOMWALK_HELPER
//

// Helper file for randomwalk.m.

#include <iostream>
#include <vector>
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

  cout << "n=" << n << " N=" << N << " eps=" << eps << endl;

  // Particles are uniformly distributed in [0,1]^2.
  // X0 = rand(1,2,n);
  mxArray *X0A, *prhs2[3];
  prhs2[0] = mxCreateDoubleScalar(1);
  prhs2[1] = mxCreateDoubleScalar(2);
  prhs2[2] = mxCreateDoubleScalar(n);
  mexCallMATLAB(1,&X0A,3,prhs2,"rand");
  double *X0 = mxGetPr(X0A);

  mwSize dim[3];
  dim[0] = N+1; dim[1] = 2; dim[2] = n;
  plhs[0] = mxCreateNumericArray(3,dim,mxDOUBLE_CLASS,mxREAL);
  double *X = mxGetPr(plhs[0]);
  for (mwIndex p = 0; p < n; ++p)
    {
      // cout << "X0 = (" << X0[0 + p*2] << "," << X0[1 + p*2] << ")\n";
      X[0 + 0*(N+1) + p*2*(N+1)] = X0[0 + p*2];
      X[0 + 1*(N+1) + p*2*(N+1)] = X0[1 + p*2];
    }
  // mexCallMATLAB(0,NULL,1, &X0A, "disp");
  // mexCallMATLAB(0,NULL,1, &plhs[0], "disp");

  // Generate the displacements.
  mxArray *thetaA;
  prhs2[0] = mxCreateDoubleScalar(N);
  prhs2[1] = mxCreateDoubleScalar(1);
  prhs2[2] = mxCreateDoubleScalar(n);
  mexCallMATLAB(1,&thetaA,3,prhs2,"rand");
  double *theta = mxGetPr(thetaA);
  for (mwIndex p = 0; p < n; ++p)
    {
      for (mwIndex i = 1; i <= N; ++i)
	{
	  int idx = i-1 + p*N;
	  int ix = i + 0*(N+1) + p*2*(N+1);
	  int iy = i + 1*(N+1) + p*2*(N+1);
	  double dx = eps*cos(2*M_PI*theta[idx]);
	  double dy = eps*sin(2*M_PI*theta[idx]);
	  X[ix] = X[ix-1] + dx;
	  X[iy] = X[iy-1] + dy;
	  // Reflect if walk leaves interval.
	  // Note: this requires a small step size.
	  if (X[ix] > 1) X[ix] = 2-X[ix];
	  if (X[iy] > 1) X[iy] = 2-X[iy];
	  if (X[ix] < 0) X[ix] = -X[ix];
	  if (X[iy] < 0) X[iy] = -X[iy];
	}
    }

  // mexCallMATLAB(0,NULL,1, &plhs[0], "disp");
  // mexCallMATLAB(0,NULL,1, &X0A, "disp");
  // mexCallMATLAB(0,NULL,1, &thetaA, "disp");
}
