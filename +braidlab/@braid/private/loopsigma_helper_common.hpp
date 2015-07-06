#ifndef BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP
#define BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP

#undef BRAIDLAB_USE_GMP

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

////////////////// DECLARATIONS  /////////////////////////

template <class T>
class BraidInPlace {

public:

  BraidInPlace(mxArray *P_LOOP,
               const mxArray *P_SIGMA_IDX, mxArray *P_OPSIGN);
  ~BraidInPlace();
  void run();
  void applyToLoop(const mwIndex l);

private:
  // storage
  T *loop;
  double *opSign;

  // are we storing opSign or not?
  const bool isOpSignUsed;

  // dimension of Dynnikov coordinate vector
  const mwSize Ncoord;

  // number of loops
  const mwSize Nloops;

  // number of punctures
  const mwSize Npunc;

  // number of generators in the braid
  const int Ngen;
  const int* sigma_idx;

  // array used for storage of operation signs on a single loop
  mxArray* P_OPSIGN1;
  int *opSign1;

  const mwSize maxopSign;

};

//////////////////////////// DEFINITIONS  ////////////////////////////
template <class T>
BraidInPlace<T>::BraidInPlace(mxArray *P_LOOP,
                const mxArray *P_SIGMA_IDX,
                mxArray *P_OPSIGN) :
  //initializer lists
  loop( static_cast<T *>(mxGetData(P_LOOP)) ),
  Nloops(mxGetN(P_LOOP)),
  Ncoord(mxGetM(P_LOOP)),
  Npunc(Ncoord/2 + 2),
  sigma_idx( static_cast<const int *>(mxGetData(P_SIGMA_IDX)) ),
  Ngen(mxGetNumberOfElements(P_SIGMA_IDX)),
  isOpSignUsed(P_OPSIGN != NULL),
  opSign(NULL), opSign1(NULL),
  maxopSign(5){

  if (Ncoord % 2 != 0)
    mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badarg",
                      "input loop coordinates should have an"
                      "even number of columns.");

  // If P_OPSIGN has been allocated, we'll record the pos/neg operations.
  if (isOpSignUsed) {
    mwSize dims[2] = {maxopSign*Ngen,1};
    P_OPSIGN1 = mxCreateNumericArray( 2, dims, mxINT32_CLASS, mxREAL );
    opSign1 = static_cast<int *>(mxGetData(P_OPSIGN1));
    opSign = mxGetPr(P_OPSIGN);
  }

}

template <class T>
BraidInPlace<T>::~BraidInPlace( ) {

  if (isOpSignUsed && P_OPSIGN1 != NULL)
    mxDestroyArray(P_OPSIGN1);

}

template <class T>
void BraidInPlace<T>::applyToLoop(const mwIndex l) {

  // Create 1-indexed pointers to the appropriate place
  T* a = &loop[(0-1    )+l*Ncoord];
  T* b = &loop[(0-1+Ncoord/2)+l*Ncoord];

  // Act with the braid sequence in sigma_idx onto the coordinates a,b.
  update_rules<T>(Ngen, Npunc, sigma_idx, a, b, opSign1);

  // Copy the pos/neg results to output array.
  if (isOpSignUsed) {
    for (mwIndex k = 0; k < maxopSign; ++k) {
      for (mwIndex j = 0; j < Ngen; ++j) {
        opSign[k*Ngen*Nloops + j*Nloops + l] = static_cast<double>(opSign1[k*Ngen + j]);
      }
    }
  }
}

template <class T>
void BraidInPlace<T>::run() {

  // run through every loop
  for (mwIndex l = 0; l < Nloops; ++l) {
    applyToLoop(l);
  }
}


#ifdef BRAIDLAB_USE_GMP
inline void loopsigma_helper_gmp(const mwSize Ngen, const int *sigma_idx,
                                 const mwSize Nloops, const mwSize Ncoord,
                                 const mpz_class *loop_in,
                                 mpz_class *loop_out, mxArray *P_OPSIGN = 0)
{
  // Refers to generators, so don't need to be mwIndex/mwSize.
  const int n = (int)(Ncoord/2 + 2);

  // Make 1-indexed arrays.
  mpz_class *a = new mpz_class[Ncoord/2] - 1;
  mpz_class *b = new mpz_class[Ncoord/2] - 1;

  // If P_OPSIGN has been allocated, we'll record the pos/neg operations.
  int *opSign1 = 0;
  double *opSign = 0;
  const int maxopSign = 5;
  if (P_OPSIGN != 0)
    {
      opSign1 = new int[maxopSign*Ngen](); // Allocate and set to zero.
      opSign = (double *)mxGetPr(P_OPSIGN);
    }

  // this is where the parallelization should come in
  for (mwIndex l = 0; l < Nloops; ++l) // Loop over rows of u.
    {
      // Copy initial row data.
      for (mwIndex k = 1; k <= Ncoord/2; ++k)
        {
          a[k] = loop_in[(k-1    )*Nloops+l];
          b[k] = loop_in[(k-1+Ncoord/2)*Nloops+l];
        }

      // Act with the braid sequence in sigma_idx onto the coordinates a,b.
      update_rules(Ngen, n, sigma_idx, a, b, opSign1);

      for (mwIndex k = 1; k <= Ncoord/2; ++k)
        {
          // Copy final a and b to row of output array.
          loop_out[(k-1    )*Nloops+l] = a[k];
          loop_out[(k-1+Ncoord/2)*Nloops+l] = b[k];
        }

      // Copy the pos/neg results to output array.
      if (P_OPSIGN != 0)
        {
          for (mwIndex k = 0; k < maxopSign; ++k)
            {
              for (mwIndex j = 0; j < Ngen; ++j)
                {
                  opSign[k*Ngen*Nloops + j*Nloops + l] = opSign1[k*Ngen + j];
                }
            }
        }
    }

  delete[] (a+1);
  delete[] (b+1);

  if (P_OPSIGN != 0) delete[] opSign1;

  return;
}
#endif // BRAIDLAB_USE_GMP

#endif // BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP
