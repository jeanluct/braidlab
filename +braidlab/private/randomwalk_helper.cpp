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

#define PLANE  0
#define SQUARE 1
#define DISK   2

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;

  const double *X0 = mxGetPr(prhs[0]);
  const mwSize n = mxGetN(prhs[0]);
  const mwSize N = (mwSize) mxGetScalar(prhs[1]);
  const double eps = mxGetScalar(prhs[2]);
  const int domain = (int) mxGetScalar(prhs[3]);

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
  mxArray *thetaA, *prhs2[2];
  prhs2[0] = mxCreateDoubleScalar(N);
  prhs2[1] = mxCreateDoubleScalar(n);
  mexCallMATLAB(1,&thetaA,2,prhs2,"rand");
  double *theta = mxGetPr(thetaA);

  /*
  // Nonuniform step size.
  mxArray *eps2A;
  mexCallMATLAB(1,&eps2A,2,prhs2,"rand");
  double *eps2 = mxGetPr(eps2A);
  */

  //
  // Add up the displacements, reflect at boundaries.
  //
  for (mwIndex p = 0; p < n; ++p)
    {
      for (mwIndex i = 1; i <= N; ++i)
        {
          // Update particle position.
          int idx = i-1 + p*N;
          /*
          // Nonuniform step size.
          double dx = eps*sqrt(eps2[idx])*cos(2*M_PI*theta[idx]);
          double dy = eps*sqrt(eps2[idx])*sin(2*M_PI*theta[idx]);
          */
          double dx = eps*cos(2*M_PI*theta[idx]);
          double dy = eps*sin(2*M_PI*theta[idx]);
          int ix = i + 0*(N+1) + p*2*(N+1);
          int iy = i + 1*(N+1) + p*2*(N+1);
          X[ix] = X[ix-1] + dx;
          X[iy] = X[iy-1] + dy;

          //
          // Reflect if walk leaves domain.
          //
          // Note: this requires a small step size to avoid
          // "double-reflections".
          //
          // (Could insert extra point at reflection location?)
          if (domain == SQUARE)
            {
              if (X[ix] > 1) X[ix] = 2-X[ix];
              if (X[ix] < 0) X[ix] = -X[ix];
              if (X[iy] > 1) X[iy] = 2-X[iy];
              if (X[iy] < 0) X[iy] = -X[iy];
            }
          else if (domain == DISK)
            {
              double r = hypot(X[ix],X[iy]);
              if (r > 1)
                {
                  double th = atan2(X[iy],X[ix]);
                  r = 2-r; // Cheap reflection: just reflect radius.
                  X[ix] = r*cos(th); X[iy] = r*sin(th);
                }
            }
        }
    }

  mxDestroyArray(thetaA);
  /*
  // Nonuniform step size.
  mxDestroyArray(eps2A);
  */
  mxDestroyArray(prhs2[0]);
  mxDestroyArray(prhs2[1]);
}
