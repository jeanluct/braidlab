#include "mex.h"

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

#define pos(x) (x > 0 ? x : 0)
#define neg(x) (x < 0 ? x : 0)

template <class T>
inline void update_rules(const int Ngen, const int n, const int *ii,
			 T *a, T *b)
{
  T c, d;
  T *ap, *bp;
  const int N = 2*(n-2);

  // Make 1-indexed arrays.
  ap = (T *) malloc(N/2 * sizeof(T)) - 1;
  bp = (T *) malloc(N/2 * sizeof(T)) - 1;

  // Copy initial row data
  for (mwIndex k = 1; k <= N/2; ++k) { ap[k] = a[k]; bp[k] = b[k]; }

  for (int j = 0; j < Ngen; ++j) /* Loop over generators */
    {
      int i = abs(ii[j]);
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
      for (mwIndex k = 1; k <= N/2; ++k) { a[k] = ap[k]; b[k] = bp[k]; }
    }

  free(ap+1);
  free(bp+1);
}


template <class T>
inline void loopsigma_helper_common(const mwSize Ngen, const int *ii,
				    const mxArray *uA, mxArray *uoA)
{
  int n; // Refers to generators, so don't need to be mwIndex/mwSize.
  mwIndex k, l;
  const T *u;
  T *a, *b, *uo;
  mwSize N, Nr;

  u = (T *)mxGetPr(uA);

  N = mxGetN(uA);
  Nr = mxGetM(uA);
  if (N % 2 != 0)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badarg",
                        "u argument should have even number of columns.");
    }
  n = (int)(N/2 + 2);

  // Make 1-indexed arrays.
  a = (T *) malloc(N/2 * sizeof(T)) - 1;
  b = (T *) malloc(N/2 * sizeof(T)) - 1;

  // Create an mxArray for the output data.
  uo = (T *)mxGetPr(uoA);

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
