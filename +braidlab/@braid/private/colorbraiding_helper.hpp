//
// Matlab MEX file
//
// COLORBRAIDING Construct a sequence of braid generators from a
// physical braid specified by a set of trajectories. These cpp
// functions are intended to speed up the colorbrading Matlab code
// used by the braid constructor. Written by Marko Budisic.
//
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

// Use the group relations to shorten a braid word as much as
// possible.

#ifndef _COLORBRAIDING_HELPER_HPP
#define _COLORBRAIDING_HELPER_HPP

#include <ctime>
#include <sstream>
#include "mex.h"

/*
Real3DMatrix

Class that helps with access of REAL elements in Matlab 3D matrices.
Constructed from Matlab matrix mxArray.

Implements operator() for easier access to elements in (row, column, span) notation (ZERO BASED INDEXING)
Implements functions R(), C(), S() to access individual dimensions.

*/
class Real3DMatrix {

  const double *data;         // data matrix
  mwSize _R, _C, _S; // dimensions: rows, cols, spans
  
public:  

  // use MATLAB mxArray as input, check number of dimensions
  // and store reference to its real part for easier access
  Real3DMatrix( const mxArray *in ) : data( mxGetPr(in) ) {
    if ( mxGetNumberOfDimensions(in) != 3 )
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:not3d",
                        "Requires 3d matrix.");
    const mwSize* sizes = mxGetDimensions(in);
    _R = sizes[0];
    _C = sizes[1];
    _S = sizes[2];
  }

  // acces  matrix using matrix( r, c, s) syntax
  double operator()( mwSize row, mwSize col, mwSize spn ) {
    if ( !( row < _R) )
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:out_of_bounds",
                        "Row index out of bounds");
    if ( !( col < _C) )
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:out_of_bounds",
                        "Column index out of bounds");
    if ( !( spn < _S) )
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:out_of_bounds",
                        "Span index out of bounds");
    
    return data[(spn*_C + col)*_R + row];
  }

  // access sizes
  mwSize R(void) { return _R; }
  mwSize C(void) { return _C; }
  mwSize S(void) { return _S; }

};

class RealVector {

  const double *data;
  mwSize _N;

public:
  
  RealVector( const mxArray *in ) : data( mxGetPr(in) ) {
    if ( mxGetNumberOfDimensions(in) != 2 )
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:not1d",
                        "Requires 1d matrix (array).");

    _N = mxGetDimensions(in)[0] > 1 ? mxGetDimensions(in)[0] : mxGetDimensions(in)[1];
    
  }

  // acces  matrix using matrix( n ) syntax
  double operator()( mwSize n ) {
    if ( !( n < _N) )
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:out_of_bounds",
                        "Index out of bounds");
    return data[n];
  }

  // access sizes
  mwSize N(void) { return _N; }
  

};


// a simple tic-toc style timer for internal profiling
class Timer {

public: 
  clock_t tictime;

  void tic() { 
    tictime = clock();
  }

  void toc( const char* msg = "Process" ) {
    clock_t t = clock() - tictime;
    printf("%s took %f msec.\n", msg, (1000.*t)/CLOCKS_PER_SEC );
  }
};

// check if a and b are within D-th representable number of each other
bool areEqual( double a, double b, int D = 10 );



#endif
