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
#include "colorbraiding_helper.hpp"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  Matrix_3D trj = Matrix_3D( prhs[0] );

  if ( trj.C() != 2 )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:input","2 columns required for trajectory");

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
