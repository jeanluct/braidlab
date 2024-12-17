#ifndef LOOP_HELPER_HPP
#define LOOP_HELPER_HPP

// Helper function for loop manipulations, to be used in MEX files.
// ALL ALGORITHMS ARE 1-INDEX BASED: a[1] is the first element of the array

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   https://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2024  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic          <mbudisic@gmail.com>
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
//   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
// LICENSE>

#include "mex.h"
#include <cmath>
#include <cstdlib>
#include <vector>
#include <utility>
#include <algorithm> // std::max
#include <iostream>

////////////////// DECLARATIONS  /////////////////////////

/* print loop

T - numerical type that has to allow additions and multiplications.
N - sum of lengths of coordinate vectors a,b - one-indexed vectors
*/
template <class T>
void printloop( const size_t N, T *a, T *b );

/*
Compute l2 norm of the Dynnikov coordinates stored in two coordinate vectors

T - numerical type that has to allow additions and multiplications.
N - sum of lengths of coordinate vectors a,b - one-indexed vectors
*/
template <class T>
T l2norm(const int N, const T *a, const T *b);

/*
Compute minimal topological length of a loop represented by Dynnikov
coordinate vectors.

Length is a sum of intersection numbers nu. Here, we don't explicitly
construct nu, rather, the computation of length was compounded into a
single loop.

T - numerical type that has to allow additions and multiplications.
N - sum of lengths of coordinate vectors a,b - one-indexed vectors
*/
template <class T>
T minlength(const int N, const T *a, const T *b);

/*
Compute number of intersections with real axis for a loop represented
by Dynnikov coordinate vectors.

Length is computed by formula (5) in Thiffeault, Chaos, 2010.

T - numerical type that has to allow additions and multiplications.
N - sum of lengths of coordinate vectors a,b - one-indexed vectors
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

// algorithm as written is 1-indexed
template <class T>
T l2norm(const int N, const T *a, const T *b)
{
#ifdef BRAIDLAB_OVERFLOWING_L2NORM
  T l2 = 0;

  for (size_t k = 1; k <= N/2; ++k)
    l2 += a[k]*a[k] + b[k]*b[k];

  return std::sqrt(l2);
#else
  // Find the maximum element in |a| and |b|.
  auto abscomp = [](T const& x, T const& y)
    { return (std::abs(x) < std::abs(y)); };
  T c = std::max(std::abs(*(std::max_element(a+1,a+1+N/2,abscomp))),
                 std::abs(*(std::max_element(b+1,b+1+N/2,abscomp))));
  if (c == 0) return 0;

  T l2 = 0;

  // Avoid overflow by dividing by c as we go.
  // Underflow is ok, since it means component doesn't contribute.
  for (size_t k = 1; k <= N/2; ++k)
    l2 += (a[k]/c)*(a[k]/c) + (b[k]/c)*(b[k]/c);

  return c*std::sqrt(l2);
#endif
}

// algorithm as written is 1-indexed
template <class T>
T minlength(const int N, const T *a, const T *b) {

  // keeps the last term of running sum of b-coordinates
  T sumB;

  // updates the max term
  T maxTerm;

  // computes the sum-of-sum term
  T scaledSum;

  size_t n = N/2 + 2; // number of punctures

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

// algorithm as written is 1-indexed
template <class T>
T intaxis(const int N, const T *a, const T *b) {
  // N - length(a) + length(b)
  // n - number of punctures =  N/2 + 2
  // a  - 1 x (n-2) == 1 x (N/2)
  // b  - 1 x (n-2) == 1 x (N/2)

  size_t n = N/2 + 2; // number of punctures

  // INITIALIZATION -- holders for running sums/maxes
  T sumDelA = static_cast<T>( 0 );
  T sumAbsB = static_cast<T>( 0 );
  T sumB = static_cast<T>( 0 );
  T maxTerm = std::abs( a[1] )
    + std::max<T>( b[1], 0  ) + sumB;

  // MAIN LOOP
  for ( size_t k = 1; k <= n-2; ++k ) {

    if ( k > 1 )
      sumB += b[k-1];

    if (k <= n-3)
      sumDelA += std::abs( a[k+1] - a[k] );

    sumAbsB += std::abs( b[k] );

    maxTerm = std::max<T>( maxTerm,
                           std::abs( a[k] )
                           + std::max<T>( b[k], 0  )
                           + sumB );
  }
  // last term in sumB is not used to maxTerm, but it is for total sum
  sumB += b[n-2];

  T retval = std::abs( a[1] ) + std::abs( a[n-2] ) +
    sumAbsB + sumDelA + maxTerm +
    std::abs( maxTerm - sumB  );

  return retval;

}

// algorithm as written is 1-indexed
template <class T>
void intersec(const int n, const T *a, const T *b, T* mu, T* nu) {
  // n - number of punctures
  // nu - 1 x (n-1)
  // mu - 1 x (2n - 4)
  // a  - 1 x (n-2)
  // b  - 1 x (n-2)

  // nu doubles as a cumulative storage of b so we don't have to
  // allocate another array
  T* sumB = nu;

  // First pass - cumulative sum and max
  sumB[1] = static_cast<T>( 0 );
  T maxTerm = std::abs( a[1] ) + std::max<T>( b[1], 0  ) + sumB[1];

  for ( size_t k = 2 ; k <= (n-2) ; k++ ){
    sumB[k] = sumB[k-1] + b[k-1];
    maxTerm = std::max<T>( maxTerm,
                           std::abs( a[k] )
                           + std::max<T>( b[k], 0  )
                           + sumB[k] );
  }
  // last term is not used to compute maxTerm but we need it for later
  sumB[n-1] = sumB[n-2] + b[n-2];

  // Second pass
  nu[1] = 2*(maxTerm - sumB[1]);
  size_t i;
  for ( size_t k = 1 ; k <= (n-2) ; k++ ){

    // update next nu to be able to use the formula below
    nu[k+1] = 2*(maxTerm - sumB[k+1]);

    // two-element loop 2k-1 and 2k
    for ( i = 2*k-1; i <= 2*k ; i++ ) {
      mu[i] = ( i % 2 == 0 ? a[k] : -a[k] ) +
        ( b[k] >= 0  ? nu[k]/2 : nu[k+1]/2 );
    }
  }
  return;

}

template <class T>
void printloop( const size_t N, T *a, T *b ) {
  printf("a: ");
  for (size_t k = 1; k <= N/2; k++)
    printf("%.2f ", a[k]);
  printf("\n");
  printf("b: ");
  for (size_t k = 1; k <= N/2; k++)
    printf("%.2f ", b[k]);
  printf("\n");

}


#endif
