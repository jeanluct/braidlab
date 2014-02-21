#ifndef BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP
#define BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP

#include "mex.h"
#include "update_rules.hpp"

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


template <class T>
inline void loopsigma_helper_common(const mwSize Ngen, const int *ii,
                                    const mxArray *uA, mxArray *uoA)
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
      update_rules(Ngen, n, ii, a, b);

      for (mwIndex k = 1; k <= N/2; ++k)
        {
          // Copy final a and b to row of output array.
          uo[(k-1    )*Nr+l] = a[k];
          uo[(k-1+N/2)*Nr+l] = b[k];
        }
    }

  delete[] (a+1);
  delete[] (b+1);

  return;
}

#endif // BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP
