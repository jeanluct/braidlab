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

#include <iostream>
#include <vector>
#include <list>
#include <deque>
#include <algorithm>
#include <cmath>
#include <ctime>
#include <sstream>
#include "mex.h"

using namespace std;

////////////////// DECLARATIONS  /////////////////////////

/*

From a set of trajectories defining a physical braid, compute the
algebraic braid corresponding to it based on the X coordinate.

IMPORTANT:
Trajectories are assumed to be sorted by values of the X coordinate at the first time step.

Arguments:
XYtraj -- (# timesteps) x 2 x (# trajectories/strings) matrix 
       -- "X" and "Y" coordinates correspond to indexing by the second dimension
t      -- (# timesteps) vector

 */
class Real3DMatrix;
class RealVector;
// pair< vector<int>, vector<double> >
void crossingsToGenerators( Real3DMatrix& XYtraj, RealVector& t);

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
  Real3DMatrix( const mxArray *in );

  // access matrix elements using matrix( r, c, s) syntax
  double operator()( mwSize row, mwSize col, mwSize spn );

  // access sizes
  mwSize R(void) { return _R; }
  mwSize C(void) { return _C; }
  mwSize S(void) { return _S; }

};

class RealVector {

  double *data;
  mwSize _N;

public:
  
  // constructor: takes MATLAB array as an argument
  RealVector( const mxArray *in );

  // access elements using vector( n ) syntax
  double operator()( mwSize n );

  // access size
  mwSize N(void) { return _N; }
  
};

// A pairwise crossing
class PWX {
public:
  double t;
  bool L_On_Top; // is left string on top
  size_t L; // index of the left string
  size_t R; // index of the right string
  
  PWX(double nt = 0, bool nSign = false, size_t nL=0, size_t nR=0) :
    t(nt), L_On_Top(nSign), L(nL), R(nR) {}

  // PWX1 < PWX2 if their times are in that order
  bool operator <(const PWX& rhs) const { return t < rhs.t; }

  // basic log to stdout
  void print();
  
}; 

// Strings -- class generating an algebraic braid
class Strings {

  /*
    color == location of the string at the time of initialization of the object
          -- provides the "natural" index
    location == location of the string at any later time
  */
public:
  
  // constructor -- number of strings
  // colors are assumed to be 1,2,...,Nstrings
  Strings( size_t Nstrings );

  // constructor -- X0 positions of strings at the initial time
  // colors are determined by location of elements X0
  // e.g., [-0.3, 7.2, 1] results in colors [1 3 2]
  Strings( vector<double> X0 );

  // applies a pairwise crossing to the strings
  void applyCrossing( PWX );

  // retrieve the braid
  pair< vector<int>, vector<double> > getBraid();

private:

  size_t Nstrings;

  // determine color (element value) of the string based on its current location (element index)
  vector<size_t> locationToColor;

  // determine current location (element value) of the string based on its color (element index)
  vector<size_t> colorToLocation;

  // storage for braid generators
  deque<double> t;
  deque<int> braid;

  // return true if colorToLocation and locationToColor vectors are
  // consistent
  void assertLocationColorSanity();
  
  // perform operation of exchanging braids of COLOR L and R
  // returns
  // .first == true if exchange was successful
  // .second == generator index if .first == true (otherwise generator == Nstrings) 
  pair<bool, size_t> switchByColor( size_t L, size_t R );


};

/*
  Function that checks whether trajectories I and J cross between time
  instances with indices ti and ti+1.

  The outputs are as follows:
  .first  - true if crossing occured
  .second  - crossing data containing crossing information
            
 */
pair<bool,PWX> isCrossing( size_t ti, size_t I, size_t J,
                           Real3DMatrix& XYtraj, RealVector& t);


// a simple tic-toc style timer for internal profiling
class Timer {

public: 
  clock_t tictime;
  void tic() { tictime = clock(); }
  double toc( const char* msg = "Process" );
};

// check if a and b are within D-th representable number of each other
bool areEqual( double a, double b, int D);

/*
  Check that coordinates of trajectories I and J do not coincide at time-index ti. Throws MATLAB errors if they do.
    
  If only X coordinates coincide for a pair of strings, this means a
  different projection angle will fix things.

  If both X and Y coordinates coincide, then this is a true trajectory
  intersection, which means that the braid is undefined.

  Equality is checked by a custom areEqual function checks equality within 10 float-representable increments.
  (or as set by the last argument)
*/
void assertNotCoincident( Real3DMatrix& XYtraj, double ti, size_t I, size_t J, int precision=10 );

// signum function
template <typename T> int sgn(T val);



//////////////////////////// DEFINITIONS  ////////////////////////////
void crossingsToGenerators( Real3DMatrix& XYtraj, RealVector& t) {

  Timer tictoc;
  tictoc.tic();
  
  size_t Nstrings = XYtraj.S();
  bool anyXCoinc = false;

  list<PWX> crossings;

  // (I,J) is a triangular double loop over pairs of trajectories
  for (size_t I = 0; I < Nstrings; I++) {
    for (size_t J = I+1; J < Nstrings; J++) {


      /*
        Determine times at which coordinates change order.
        is_I_on_Left records whether the strings are in order ...I...J...
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
  tictoc.toc("colorbraiding_helper: sorting crossdat");
  
  printf("colorbraiding_helper: Number of crossings %d\n", crossings.size() );

  // Determine generators from ordered crossing data
  mexEvalString("braidlab.debugmsg('colorbraiding_helper Part 3: Convert crossings to generator sequence')");

  Strings StringSet(Nstrings);

  // Cycle through all crossings, apply them to the strands
  bool notcrossed;
  for ( list<PWX>::it crossings.begin(); it != crossings.end(); it++) {

    // NEED TO LOOK FOR SIMULTANEOUS CROSSINGS AHEAD OF TIME
    unimplemented

    StringSet.applyCrossing( *it );

  }

  

  

}

// access elements
Real3DMatrix::Real3DMatrix( const mxArray *in ) : data( mxGetPr(in) ) {
    if ( mxGetNumberOfDimensions(in) != 3 )
      mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:not3d",
                        "Requires 3d matrix.");
    const mwSize* sizes = mxGetDimensions(in);
    _R = sizes[0];
    _C = sizes[1];
    _S = sizes[2];
}

// access elements
double Real3DMatrix::operator()( mwSize row, mwSize col, mwSize spn ) {
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

// constructor from MATLAB
RealVector::RealVector( const mxArray *in ) {
  if ( mxGetNumberOfDimensions(in) != 2 )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:not1d",
                      "Requires 1d matrix (array).");
  _N = mxGetDimensions(in)[0] > 1 ? mxGetDimensions(in)[0] : mxGetDimensions(in)[1];
  data = mxGetPr(in);
}

// access elements using vector( n ) syntax
double RealVector::operator()( mwSize n ) {
  if ( !( n < _N) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:out_of_bounds",
                      "Index out of bounds");
  return data[n];
}

// retrieve and print elapsed time
double Timer::toc( const char* msg ) {
  clock_t t = clock() - tictime;
  printf("%s took %f msec.\n", msg, (1000.*t)/CLOCKS_PER_SEC );
  return t;
}

// print basic information about PWX
void PWX::print() {
  printf("%2f \t %c \t %d \t %d\n", t, L_On_Top ? '+' : '-', L, R);
}

// default location
Strings::Strings( size_t _N ) : Nstrings(_N), locationToColor(0, _N), colorToLocation(0, _N) {

  for (size_t i = 0; i < _N; i++ ) {
    locationToColor[i] = i;
    colorToLocation[i] = i;
  }

}

// location given by X0
Strings::Strings( vector<double> X0 ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:notimplemented",
                      "Strings custom color constructor not implemented");
}

// ensures that the locationToColor and colorToLocation are inverse
void Strings::assertLocationColorSanity() {

  mxAssert( locationToColor.size() == Nstrings,
            "locationToColor is not of correct size" );
  mxAssert( colorToLocation.size() == Nstrings,
            "colorToLocation is not of correct size" );
  for (size_t i = 0; i < Nstrings; i++ ) {
    mxAssert( locationToColor[ colorToLocation[i] ] == i, "locationToColor . colorToLocation != Id" );
    mxAssert( colorToLocation[ locationToColor[i] ] == i, "colorToLocation . locationToColor != Id" );    
  }

}

// applies a pairwise crossing to the strings
bool Strings::applyCrossing( PWX cross ) {

  pair<bool, size_t> success = switchByColor( cross.L, cross.R );
  if (success.first) {
    braid.push_back( cross.L_On_Top ? success.second : (-success.second) );
    t.push_back( cross.t );
  }

  return success.first;
  
}

// applies a pairwise crossing to the strings
bool Strings::applyCrossing( vector<PWX> crossBlock ) {

  unimplemented
  
}



pair<bool, size_t> Strings::switchByColor( size_t L, size_t R ) {

  // find locations of the string
  size_t oL = colorToLocation[L];
  size_t oR = colorToLocation[R];

  // if the higher string is in fact the next string to the right,
  // apply the crossing
  pair<bool, size_t> result(false, Nstrings);  
  if ( oL < Nstrings && (oL + 1 == oR ) ) {

    // swap the locations
    locationToColor[oL] = R;
    locationToColor[oR] = L;

    // swap the colors
    colorToLocation[R] = oL;
    colorToLocation[L] = oR;

    // assert that the swap was performed correctly
    assertLocationColorSanity();
    
    result.first = true;
    result.second = oL;
  }
  
  return result;

}

// check and interpolate a crossing between strings I and J at time index ti,
// i.e., between times t(ti) and t(ti+1)
pair<bool,PWX> isCrossing( size_t ti, size_t I, size_t J,
                           Real3DMatrix& XYtraj, RealVector& t) {

  // printf(" %.1e   %.1e \t %.1e   %.1e\n", XYtraj(ti, 0, I), XYtraj(ti, 0, J), XYtraj(ti+1, 0, I), XYtraj(ti+1, 0, J));

  bool I_On_Left = ( XYtraj(ti, 0, I) < XYtraj(ti, 0, J) );

  // NO CROSSING: order is the same -- exit the function
  if ( I_On_Left == (XYtraj(ti+1, 0, I) < XYtraj(ti+1, 0, J)) ) {
    return pair<bool, PWX>( false, PWX() );
  }
  
  // CROSSING == order of strings changes

  // calculate indices of the Left and Right string
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

  // fraction of the time interval at which the points meet
  double delta = - ( XYtraj(ti, 0, R) - XYtraj(ti, 0, L) ) / ( dXR - dXL );

  if ( sgn<double>(delta) != sgn<double>(T) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:interpolation",
                      "Interpolation error - interval increment of incorrect sign.");    

  // interpolation
  double tc = t(ti) + delta * T;
  double YLc = XYtraj(ti, 1, L) + delta * dYL;
  double YRc = XYtraj(ti, 1, R) + delta * dYR;

  // left string is on top? important for direction of the generator
  bool leftOnTop = YLc > YRc;

  return pair<bool, PWX>( true, PWX(tc, leftOnTop, L, R) );

}

// signum function
template <typename T> int sgn(T val) {
    return (T(0) < val) - (val < T(0));
}

// check for equality taking float precision into account
bool areEqual( double a, double b, int D ) {

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

// assert that trajectories I and J are not coincident at time step ti
void assertNotCoincident( Real3DMatrix& XYtraj, double ti, size_t I, size_t J, int precision ) {
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



#endif
