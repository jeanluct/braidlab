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

#include "mex.h"

/*
Matrix_3D

Class that helps with access of elements in Matlab 3D matrices.
Constructed from Matlab matrix mxArray.

Implements operator() for easier access to elements in (row, column, span) notation (ZERO BASED INDEXING)
Implements functions R(), C(), S() to access individual dimensions.

*/
class Matrix_3D {

  const double *data;         // data matrix
  mwSize _R, _C, _S; // dimensions: rows, cols, spans
  
public:  

  Matrix_3D( const mxArray *in ) : data( mxGetPr(in) ) {

    if ( mxGetNumberOfDimensions(in) != 3 )
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:not3d","Requires 3d matrix.");

    data = mxGetPr(in);
    const mwSize* sizes = mxGetDimensions(in);
    _R = sizes[0];
    _C = sizes[1];
    _S = sizes[2];
  }

  // zero-based indexing
  double operator()( mwSize row, mwSize col, mwSize spn ) {
    if ( !( row < _R && col < _C && spn < _S ) ){
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:out_of_bounds","Index out of bounds");
    }
    mwSize index = (spn*_C + col)*_R + row;
    return data[index];
  }

  mwSize R(void) { return _R; }
  mwSize C(void) { return _C; }
  mwSize S(void) { return _S; }

};



#endif
