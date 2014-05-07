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
#include <list>
#include <deque>
#include <algorithm>
#include <cmath>
#include "mex.h"
#include "colorbraiding_helper.hpp"



using namespace std;

// A pairwise crossing
class PWX {
public:
  double t;
  bool L_On_Top; // is left string on top
  size_t L; // index of the left string
  size_t R; // index of the right string

  PWX(double nt = 0, bool nSign = false, size_t nL=0, size_t nR=0) :
    t(nt), L_On_Top(nSign), L(nL), R(nR) {}

  bool operator <(const PWX& rhs) const {
    return t < rhs.t;
  }

  void print() {
    printf("%2f \t %c \t %d \t %d\n", t, L_On_Top ? '+' : '-', L, R);
  }
  
}; 

/*
  Function that checks whether trajectories I and J cross between time instances
  with indices ti and ti+1.

  The outputs are as follows:
  .first  - true if crossing occured
  .second  - crossing data containing crossing information
            
 */
pair<bool,PWX> isCrossing( size_t ti, size_t I, size_t J,
                           Real3DMatrix& XYtraj, RealVector& t) {

  // not implemented

  // printf(" %.1e   %.1e \t %.1e   %.1e\n", XYtraj(ti, 0, I), XYtraj(ti, 0, J), XYtraj(ti+1, 0, I), XYtraj(ti+1, 0, J));

  bool I_On_Left = ( XYtraj(ti, 0, I) < XYtraj(ti, 0, J) );

  // NO CROSSING: order is the same -- exit the function
  if ( I_On_Left == (XYtraj(ti+1, 0, I) < XYtraj(ti+1, 0, J)) ) {
    return pair<bool, PWX>( false, PWX() );
  }
  
  // CROSSING: order changes

  // indices of left and right string
  size_t L, R;
  if (I_On_Left) {
    L = I;
    R = J;
  }
  else {
    L = J;
    R = I;
  }

  // INTERPOLATE CROSSING POINT

  // length of time interval
  double T = t(ti+1) - t(ti);

  // differences between two endpoints
  double dXL = XYtraj(ti+1, 0, L) - XYtraj(ti, 0, L);
  double dXR = XYtraj(ti+1, 0, R) - XYtraj(ti, 0, R);
  double dYL = XYtraj(ti+1, 1, L) - XYtraj(ti, 1, L);
  double dYR = XYtraj(ti+1, 1, R) - XYtraj(ti, 1, R);

  // fraction of the interval at which the points meet
  double delta = - ( XYtraj(ti, 0, R) - XYtraj(ti, 0, L) ) / ( dXR - dXL );


  if ( sgn<double>(delta) != sgn<double>(T) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:interpolation",
                      "Interpolation error - interval increment of incorrect sign.");    

  // interpolation
  double tc = t(ti) + delta * T;
  double YLc = XYtraj(ti, 1, L) + delta * dYL;
  double YRc = XYtraj(ti, 1, R) + delta * dYR;

  bool leftOnTop = YLc > YRc;

  return pair<bool, PWX>( true, PWX(tc, leftOnTop, L, R) );

}

  /*
    Check that coordinates of trajectories I and J do not coincide at time-index ti. Throws MATLAB errors if they do.
    
    If only X coordinates coincide for a pair of strands, this means a
    different projection angle will fix things.

    If both X and Y coordinates coincide, then this is a true trajectory
    intersection, which means that the braid is undefined.

    Equality is checked by a custom areEqual function checks equality within 10 float-representable increments.
    (or as set by the last argument)
  */
inline void assertNotCoincident( Real3DMatrix& XYtraj, double ti, size_t I, size_t J, int precision=10 );

void crossingsToGenerators( Real3DMatrix& XYtraj, RealVector& t) {

  Timer tictoc;
  tictoc.tic();
  
  size_t Nstrands = XYtraj.S();
  bool anyXCoinc = false;

  list<PWX> crossings;

  // (I,J) is a triangular double loop over pairs of trajectories
  for (size_t I = 0; I < Nstrands; I++) {
    for (size_t J = I+1; J < Nstrands; J++) {


      /*
        Determine times at which coordinates change order.
        is_I_on_Left records whether the strands are in order ...I...J...
        When is_I_on_Left changes between two steps, it's an indication that the crossing happened.
       */
      // loop over rows      
      for (size_t ti = 0; ti < XYtraj.R()-1; ti++) {

        // Check that coordinates do not coincide.
        assertNotCoincident( XYtraj, ti, I, J );

        // does a crossing occur at time-index ti between trajectories I and J?
        // interpolated crossing stored in PWX structure interpCross
        pair<bool, PWX> interpCross = isCrossing( ti, I, J, XYtraj, t );
        if (interpCross.first)
          crossings.push_back(interpCross.second);

      }
    }
  }


  tictoc.tic();
  crossings.sort();
  tictoc.toc("colorbraiding_helper: computing sorted crossdat");
  printf("colorbraiding_helper: Number of crossings %d\n", crossings.size() );

  // Determine generators from ordered crossing data
  mexEvalString("braidlab.debugmsg('colorbraiding_helper Part 3: Convert crossings to generator sequence')");  

}

inline void assertNotCoincident( Real3DMatrix& XYtraj, double ti, size_t I, size_t J, int precision ) {
  if ( areEqual(XYtraj(ti, 0, I), XYtraj(ti, 0, J), precision ) ) { // X coordinate
    if ( areEqual(XYtraj(ti, 1, I), XYtraj(ti, 1, J), precision ) ) { // Y coordinate
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:coincidentparticles",
                        "Coincident particles: Braid not defined.");
    }
    else {
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:coincidentproj",
                        "Coincident projection coordinate: change projection angle.");
    }
  }
}

inline bool areEqual( double a, double b, int D ) {

  // ensure a < b
  if (b < a) {
    double tmp = b;
    b = a;
    a = tmp;
  }
  // compute the D-th representable number larger than a
  double bnd = a;
  for (int i = 0; i < D; i++)
    bnd = nextafter(bnd, 1.0);
  // check if b is between a and bnd
  return b <= bnd;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {


  if (nrhs != 2)
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:input",
                      "2 arguments required.");
  
  Real3DMatrix trj = Real3DMatrix( prhs[0] );
  if ( trj.C() != 2 ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:input",
                      "Trajectory should have 2 columns.");
  }

  RealVector t = RealVector( prhs[1] );

  if ( trj.R() != t.N() ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:input",
                      "Trajectory matrix and time vector should have same number of rows.");
  }
  crossingsToGenerators( trj, t);

}

