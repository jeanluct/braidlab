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


#include <iostream>
#include <vector>
#include <algorithm>
#include "mex.h"

class XY_3D {

  const double *data;         // data matrix
  mwSize _R, _C, _S; // dimensions: rows, cols, spans
  
public:  

  XY_3D( const mxArray *in ) : data( mxGetPr(in) ) {
    data = mxGetPr(in);
    const mwSize* sizes = mxGetDimensions(in);
    _R = sizes[0];
    _C = sizes[1];
    _S = sizes[2];
  }

  // zero-based indexing
  double operator()( mwSize row, mwSize col, mwSize spn ) {
    if ( !( row < _R && col < _C && spn < _S ) ){
      mexErrMsgTxt("Index out of bounds");
    }
    mwSize index = (spn*_C + col)*_R + row;
    return data[index];
  }

  mwSize R(void) { return _R; }
  mwSize C(void) { return _C; }
  mwSize S(void) { return _S; }

};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  XY_3D trj = XY_3D( prhs[0] );

  for ( int s = 0; s < trj.S(); s++ ) {
    printf("Span: %d\n",s);
    for ( int r = 0; r < std::min<mwSize>(trj.R(),5); r++ ) {
      printf("[ ");          
      for ( int c = 0; c < trj.C(); c++ ) {
        printf("\t%.1e\t", trj(r,c,s) );                  
      }      
      printf(" ]\n");    
      }
  }


}
