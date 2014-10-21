#ifndef LOOP_HELPER_HPP
#define LOOP_HELPER_HPP

// Helper function for loop manipulations, to be used in MEX files.
// ALL ALGORITHMS ARE 1-INDEX BASED: a[1] is the first element of the array

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

#include "mex.h"
#include <cmath>
#include <cstdlib>
#include <vector>
#include <utility>
#include <algorithm> // std::max
#include <iostream>

// // a[OFFSET] is always the first element in array
// #ifndef BRAIDLAB_LOOP_ZEROINDEXED
// #define OFFSET (0)
// #else
// #define OFFSET (1)
// #endif

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
Compute minimal topological length of a loop represented by Dynnikov
coordinate vectors.

Length is a sum of intersection numbers nu. Here, we don't explicitly
construct nu, rather, the computation of length was compounded into a
single loop.

T - numerical type that has to allow additions and multiplications.
N - sum of lengths of coordinate vectors a,b - one-indexed vectors
(#define BRAIDLAB_LOOP_ZEROINDEXED to switch to zero-based indexing)
*/
template <class T>
T minlength(const int N, const T *a, const T *b);

/* 
Compute number of intersections with real axis for a loop represented
by Dynnikov coordinate vectors.

Length is computed by formula (5) in Thiffeault, Chaos, 2010.

T - numerical type that has to allow additions and multiplications.
N - sum of lengths of coordinate vectors a,b - one-indexed vectors
(#define BRAIDLAB_LOOP_ZEROINDEXED to switch to zero-based indexing)
*/
template <class T>
T intaxis(const int N, const T *a, const T *b);

/* 
Convert a Dynnikov coordinate pair (a,b) into 
intersection number pair (mu, nu).

See Lemma 1 in:
Hall, Toby, and S. Öykü Yurttaş. “On the Topological Entropy of
Families of Braids.” Topology and Its Applications 156, no. 8
(April 15, 2009): 1554–64. 
doi:10.1016/j.topol.2009.01.005.

T - numerical type that has to allow additions and multiplications.
n - number of punctures
*a, *b - Dynnikov vectors 
*mu, *nu - Preallocated intersection vectors
         - mu has 2n - 4 elements
         - nu has n-1 elements
*/
template <class T>
void intersec(const int n, const T *a, const T *b, T* mu, T* nu);

////////////////// IMPLEMENTATIONS  /////////////////////////
template <class T>
T l2norm2(const int N, const T *a, const T *b)
{
  T l2 = 0;

  for (size_t k = 1; k <= N/2; ++k) 
    l2 += a[k]*a[k] + b[k]*b[k];

  return l2;
}

template <class T>
T minlength(const int N, const T *a, const T *b) {

  // keeps the last term of running sum of b-coordinates
  T sumB;

  // updates the max term
  T maxTerm;

  // computes the sum-of-sum term 
  T scaledSum;

  size_t n = N/2 + 2; // number of punctures

  // printf("a:");
  // for (size_t k = 1; k <= n-2; ++k )
  //   printf(" %d ", static_cast<int>(a[k]));
  // printf(" \n");

  // printf("b:");
  // for (size_t k = 1; k <= n-2; ++k )
  //   printf(" %d ", static_cast<int>(b[k]));
  // printf(" \n");

  // INITIALIZATION 
  sumB = static_cast<T>( 0 );
  maxTerm = std::abs( a[1] ) 
    + std::max<T>( b[1], 0  ) + sumB;
  scaledSum = (n-2) * b[1];

  // MAIN LOOP
  for ( size_t k = 2; k <= n-2; ++k ) {
    sumB += b[k-1];
    maxTerm = std::max<T>( maxTerm, 
                           std::abs( a[k] ) 
                           + std::max<T>( b[k], 0  ) 
                           + sumB );
    scaledSum += (n-1-(k)) * b[k];
  }

  return 2*(n-1)*maxTerm - 2*scaledSum;
}

template <class T>
void intersec(const int n, const T *a, const T *b, T* mu, T* nu) {
  // n - number of punctures
  // nu - 1 x (n-1)
  // mu - 1 x (2n - 4)
  // a  - 1 x (n-2)
  // b  - 1 x (n-2)

  // algorithm as written is 1-based
  
  // nu as cumulative storage of b
  T* C = nu;

  C[1] = 0;
  for ( size_t k = 1 ; k < (n-1) ; k++ ){
    C[k] = C[k-1] + b[k];
  }

  return;

}


#endif
