#ifndef LOOP_HELPER_HPP
#define LOOP_HELPER_HPP

// Helper function for loop manipulations, to be used in MEX files.
// define BRAIDLAB_LOOP_ZEROINDEXED to enforce 0-indexed arrays.
// Otherwise, arrays are assumed to be 1-indexed.

// <LICENSE
//   Copyright (c) 2014 Jean-Luc Thiffeault, Marko Budisic
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

#include <cmath>
#include <cstdlib>
#include <vector>
#include <utility>
#include <algorithm> // std::max
#include <iostream>

////////////////// DECLARATIONS  /////////////////////////

/*
Compute l2 norm of the Dynnikov coordinates stored in two coordinate vectors

T - numerical type that has to allow additions and multiplications.
N - sum of lengths of coordinate vectors a,b - one-indexed vectors
(#define BRAIDLAB_LOOP_ZEROINDEXED to switch to zero-based indexing)
*/
template <class T>
T l2norm2(const int N, const T *a, const T *b);

/* 
Compute loop length of a loop represented by Dynnikov coordinate vectors.

Length is a sum of intersection numbers nu. Here, we don't explicitly
construct nu, rather, the computation of length was compounded into a
single loop.

T - numerical type that has to allow additions and multiplications.
N - sum of lengths of coordinate vectors a,b - one-indexed vectors
(#define BRAIDLAB_LOOP_ZEROINDEXED to switch to zero-based indexing)
*/
template <class T>
T length(const int N, const T *a, const T *b);

////////////////// IMPLEMENTATIONS  /////////////////////////
template <class T>
T l2norm2(const int N, const T *a, const T *b)
{
  T l2 = 0;

#ifndef BRAIDLAB_LOOP_ZEROINDEXED
  for (size_t k = 1; k <= N/2; ++k) l2 += a[k]*a[k] + b[k]*b[k];
#else
  for (size_t k = 0; k < N/2; ++k) l2 += a[k]*a[k] + b[k]*b[k];
#endif

  return l2;
}

template <class T>
T length(const int N, const T *a, const T *b) {

  size_t offset;
#ifndef BRAIDLAB_LOOP_ZEROINDEXED
  offset = 0;
#else
  offset = 1;
#endif

  // keeps the last term of running sum of b-coordinates
  T sumB;

  // updates the max term
  T maxTerm;

  // computes the sum-of-sum term 
  T scaledSum;

  size_t n = N/2 + 2; // number of punctures

  // INITIALIZATION (corresponds to k = 1 in 1-based index)
  sumB = static_cast<T>( 0 );
  maxTerm = std::abs( a[1 - offset] ) 
    + std::max<T>( b[1-offset], 0  ) + sumB;
  scaledSum = (n-2) * b[1-offset];

  // MAIN LOOP
  for ( size_t k = 2-offset; k <= n-2-offset; ++k ) {
    sumB += b[k-1-offset];
    maxTerm = std::max<T>( maxTerm, 
                           std::abs( a[k - offset] ) 
                           + std::max<T>( b[k - offset], 0  ) 
                           + sumB );
    scaledSum += (n-1-(k-offset)) * b[k-offset];
  }

  return 2*(n-1)*maxTerm - 2*scaledSum;
}


#endif
