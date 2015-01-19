#ifndef BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP
#define BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP

#include "mex.h"
#include "update_rules.hpp"

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic         <marko@math.wisc.edu>
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

template <class T>
inline void loopsigma_helper_common(const mwSize Ngen, const int *ii,
                                    const mxArray *uA,
                                    mxArray *uoA, mxArray *pnA = 0)
{
  const T *u = (T *)mxGetPr(uA);

  const mwSize N = mxGetN(uA);
  const mwSize Nr = mxGetM(uA);
  if (N % 2 != 0)
    {
      mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badarg",
                        "u argument should have even number of columns.");
    }
  // Refers to generators, so don't need to be mwIndex/mwSize.
  const int n = (int)(N/2 + 2);

  // Make 1-indexed arrays.
  T *a = new T[N/2] - 1;
  T *b = new T[N/2] - 1;

  // If pnA has been allocated, we'll record the pos/neg operations.
  int *pn1 = 0;
  double *pn = 0;
  const int maxpn = 5;
  if (pnA != 0)
    {
      pn1 = new int[maxpn*Ngen](); // Allocate and set to zero.
      pn = (double *)mxGetPr(pnA);
    }

  // Create an mxArray for the output data.
  T *uo = (T *)mxGetPr(uoA);

  for (mwIndex l = 0; l < Nr; ++l) // Loop over rows of u.
    {
      // Copy initial row data.
      for (mwIndex k = 1; k <= N/2; ++k)
        {
          a[k] = u[(k-1    )*Nr+l];
          b[k] = u[(k-1+N/2)*Nr+l];
        }

      // Act with the braid sequence in ii onto the coordinates a,b.
      update_rules(Ngen, n, ii, a, b, pn1);

      for (mwIndex k = 1; k <= N/2; ++k)
        {
          // Copy final a and b to row of output array.
          uo[(k-1    )*Nr+l] = a[k];
          uo[(k-1+N/2)*Nr+l] = b[k];
        }

      // Copy the pos/neg results to output array.
      if (pnA != 0)
        {
          for (mwIndex k = 0; k < maxpn; ++k)
            {
              for (mwIndex j = 0; j < Ngen; ++j)
                {
                  pn[k*Ngen*Nr + j*Nr + l] = pn1[k*Ngen + j];
                }
            }
        }
    }

  delete[] (a+1);
  delete[] (b+1);

  if (pnA != 0) delete[] pn1;

  return;
}


#ifdef BRAIDLAB_USE_GMP
inline void loopsigma_helper_gmp(const mwSize Ngen, const int *ii,
                                 const mwSize Nr, const mwSize N,
                                 const mpz_class *u,
                                 mpz_class *uo, mxArray *pnA = 0)
{
  // Refers to generators, so don't need to be mwIndex/mwSize.
  const int n = (int)(N/2 + 2);

  // Make 1-indexed arrays.
  mpz_class *a = new mpz_class[N/2] - 1;
  mpz_class *b = new mpz_class[N/2] - 1;

  // If pnA has been allocated, we'll record the pos/neg operations.
  int *pn1 = 0;
  double *pn = 0;
  const int maxpn = 5;
  if (pnA != 0)
    {
      pn1 = new int[maxpn*Ngen](); // Allocate and set to zero.
      pn = (double *)mxGetPr(pnA);
    }

  for (mwIndex l = 0; l < Nr; ++l) // Loop over rows of u.
    {
      // Copy initial row data.
      for (mwIndex k = 1; k <= N/2; ++k)
        {
          a[k] = u[(k-1    )*Nr+l];
          b[k] = u[(k-1+N/2)*Nr+l];
        }

      // Act with the braid sequence in ii onto the coordinates a,b.
      update_rules(Ngen, n, ii, a, b, pn1);

      for (mwIndex k = 1; k <= N/2; ++k)
        {
          // Copy final a and b to row of output array.
          uo[(k-1    )*Nr+l] = a[k];
          uo[(k-1+N/2)*Nr+l] = b[k];
        }

      // Copy the pos/neg results to output array.
      if (pnA != 0)
        {
          for (mwIndex k = 0; k < maxpn; ++k)
            {
              for (mwIndex j = 0; j < Ngen; ++j)
                {
                  pn[k*Ngen*Nr + j*Nr + l] = pn1[k*Ngen + j];
                }
            }
        }
    }

  delete[] (a+1);
  delete[] (b+1);

  if (pnA != 0) delete[] pn1;

  return;
}
#endif // BRAIDLAB_USE_GMP

#endif // BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP
