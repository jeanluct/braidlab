//
// Matlab MEX file
//
// COLORBRAIDING Construct a sequence of braid generators from a
// physical braid specified by a set of trajectories. These cpp
// functions are intended to speed up the colorbrading Matlab code
// used by the braid constructor. Written by Marko Budisic.
//
// Responds to MATLAB global variables:
// BRAIDLAB_debuglvl  -- sets the level of logging output from the code
// BRAIDLAB_threads   -- sets max number of parallel threads of execution
//
// <LICENSE
//   Copyright (c) 2013, 2014 Jean-Luc Thiffeault, Marko Budisic
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

#ifndef BRAIDLAB_COLORBRAIDING_HELPER_HPP
#define BRAIDLAB_COLORBRAIDING_HELPER_HPP

#include <iostream>
#include <vector>
#include <list>
#include <algorithm>
#include <cmath>
#include <ctime>
#include <sstream>
#include <mutex>

#if (defined _NOFUTURE || ((defined __GNUC__) && (__GNUC__ == 4) && (__GNUC_MINOR__<6)))
#include "ThreadPool.h" // (c) Jakob Progsch https://github.com/progschj/ThreadPool
#else
#include "ThreadPool_nofuture.h" // (c) Jakob Progsch
                                 // https://github.com/progschj/ThreadPool
#endif

#include "mex.h"

using namespace std;

int BRAIDLAB_debuglvl = -1;
size_t BRAIDLAB_threads = 1;

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
//Strings crossingsToGenerators( Real3DMatrix& XYtraj, RealVector& t);

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
  void print(int debuglevel);
  
}; 

// simple wrapper around list<PWX> object to prevent it from being
// written concurrently by two threads
class ThreadSafeWrapper {

public:

  ThreadSafeWrapper( list<PWX>& s ) : storage(s) {}

  void push_back( PWX data ) {
    mtx.lock();
    storage.push_back(data);
    mtx.unlock();
  }

private:
  list<PWX>& storage;
  mutex mtx;

};

/*
  Class that detects pairwise crossings from 
  the trajectory data.

  Implemented as an object to facilitate multithreading computation.
 */
class PairCrossings {

public:

  // inputs: _XYtraj (trajectory) _t (time)
  // output: storage
  PairCrossings( Real3DMatrix& _XYtraj,
                 RealVector& _t,
                 list<PWX>& storage) : wrapper(storage), 
                                       XYtraj(_XYtraj),
                                       t(_t),
                                       Nstrings(_XYtraj.S()) {}

  // run the calculation on T threads
  void run( size_t T = 1 );

  // Detects crossings between string with color "anchor" and all subsequent strings
  void detectCrossings( size_t anchor );


private:
  ThreadSafeWrapper wrapper;
  Real3DMatrix& XYtraj;
  RealVector& t;
  size_t Nstrings;


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
  // colors are assumed to be 1,2,...,N
  Strings( size_t N);

  // constructor -- X0 positions of strings at the initial time
  // colors are determined by location of elements X0
  // e.g., [-0.3, 7.2, 1] results in colors [1 3 2]
  Strings( vector<double> X0 );

  // Apply a block of concurrent crossings to the list.
  // Returns true if the block was applied consistently
  // false otherwise.
  bool applyCrossings( list<PWX>::iterator start, list<PWX>::iterator end );

  // copy braid and time to PREALLOCATED double arrays
  size_t braidSize();
  void getBraid( vector<int>& data );
  void getTime( vector<double>& data );

private:

  size_t Nstrings;

  // determine color (element value) of the string based on its current location (element index)
  vector<size_t> locationToColor;

  // determine current location (element value) of the string based on its color (element index)
  vector<size_t> colorToLocation;

  // storage for braid generators
  list<double> t;
  list<int> braid;

  // return true if colorToLocation and locationToColor vectors are
  // consistent
  void assertLocationColorSanity();
  
  // perform operation of exchanging braids of COLOR L and R
  // returns
  // .first == true if exchange was successful
  // .second == generator index if .first == true (otherwise generator == Nstrings) 
  pair<bool, size_t> switchByColor( size_t L, size_t R );

  // Applies a single pairwise crossing to the strings.  Crossing can
  // be applied only if the strings (specified by color) were
  // neighbors by location, in which case the braid is updated and
  // true returned.
  // False if error.
  bool applyCrossing( const PWX& );

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

  Timer( int level ) : debuglevel(level) {}

  int debuglevel;
  clock_t tictime;
  void tic() { tictime = clock(); }
  double toc( const char* msg = "Process", bool reset=false );
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
pair< vector<int>, vector<double> > crossingsToGenerators( Real3DMatrix& XYtraj, RealVector& t) {

  Timer tictoc( 1 );
  tictoc.tic();
  
  size_t Nstrings = XYtraj.S();
  bool anyXCoinc = false;

  // return braid information
  pair< vector<int>, vector<double> > retval;

  list<PWX> crossings;

  PairCrossings pairCrosser( XYtraj, t, crossings );

  pairCrosser.run(BRAIDLAB_threads);
  tictoc.toc("colorbraiding_helper: pairwise crossing detection", true);

  crossings.sort();
  tictoc.toc("colorbraiding_helper: sorting crossdat", true);
  
  if (1 <= BRAIDLAB_debuglvl)  {
    printf("colorbraiding_helper: Number of crossings %d\n", crossings.size() );
    mexEvalString("pause(0.001);"); //flush
  }

  // Determine generators from ordered crossing data
  if (1 <= BRAIDLAB_debuglvl)  {
    printf("colorbraiding_helper: Convert crossings to generator sequence\n");
    mexEvalString("pause(0.001);");
  }

  Strings stringSet(Nstrings);

  //  return retval;

  // Cycle through all crossings, apply them to the strands
  bool notcrossed;
  list<PWX>::iterator blockStart = crossings.begin();
  list<PWX>::iterator blockEnd;

  size_t cnt = 0;
  while (blockStart != crossings.end() ) {

    // determine the block of crossings that happen
    // at the same time
    blockEnd = blockStart;
    blockEnd++;
    while ( areEqual( blockStart->t,blockEnd->t,2 ) ) {// within 2-float numbers
      blockEnd++;
    }

    // apply the crossings to the permutation vector and update the braid
    bool success = stringSet.applyCrossings(blockStart, blockEnd);

    if ( success ) {
      blockStart = blockEnd;     // advance through crossings list
    }
    else {
      // error handling - determine exactly where we failed.
      size_t startN = distance( crossings.begin(), blockStart );
      size_t endN = distance( crossings.begin(), blockEnd );
      double blockTime = blockStart->t;

      stringstream msg;
      msg << "Attempting to apply crossings resulted in inconsistency. ";
      msg << "Concurrent block at time " << blockTime << ", ";
      msg << distance( blockStart, blockEnd );
      msg << " crossings between " << startN << " and " << endN << " cannot be resolved.";
      mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:badcrossing", msg.str().c_str());
    }
  }

  tictoc.toc("colorbraiding_helper: generating the braid", true);

  stringSet.getBraid( retval.first );
  stringSet.getTime ( retval.second );
  tictoc.toc("colorbraiding_helper: copying output");

  return retval;

}

// access elements
Real3DMatrix::Real3DMatrix( const mxArray *in ) : data( mxGetPr(in) ) {
  if ( mxGetNumberOfDimensions(in) != 3 )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:not3d",
                      "Requires 3d matrix.");
  const mwSize* sizes = mxGetDimensions(in);
  _R = sizes[0];
  _C = sizes[1];
  _S = sizes[2];
}

// access elements
double Real3DMatrix::operator()( mwSize row, mwSize col, mwSize spn ) {
  if ( !( row < _R) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:out_of_bounds",
                      "Row index out of bounds");
  if ( !( col < _C) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:out_of_bounds",
                      "Column index out of bounds");
  if ( !( spn < _S) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:out_of_bounds",
                      "Span index out of bounds");
    
  return data[(spn*_C + col)*_R + row];
}

// constructor from MATLAB
RealVector::RealVector( const mxArray *in ) {
  if ( mxGetNumberOfDimensions(in) != 2 )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:not1d",
                      "Requires 1d matrix (array).");
  _N = mxGetDimensions(in)[0] > 1 ? mxGetDimensions(in)[0] : mxGetDimensions(in)[1];
  data = mxGetPr(in);
}

// access elements using vector( n ) syntax
double RealVector::operator()( mwSize n ) {
  if ( !( n < _N) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:out_of_bounds",
                      "Index out of bounds");
  return data[n];
}



// retrieve and print elapsed time
double Timer::toc( const char* msg, bool reset ) {

  clock_t t = clock() - tictime;

  if (debuglevel <= BRAIDLAB_debuglvl) {
    printf("%s took %f msec.\n", msg, (1000.*t)/CLOCKS_PER_SEC );
    mexEvalString("pause(0.001);");//flush
  }
  if (reset)
    tic();
  return t;
}

// print basic information about PWX
void PWX::print(int debuglevel = 0) {
  if (debuglevel <= BRAIDLAB_debuglvl) {
    printf("%2f \t %c \t %d \t %d\n", t, L_On_Top ? '+' : '-', L, R);
    mexEvalString("pause(0.001);");
  }
}

void PairCrossings::detectCrossings( size_t I ) {

    for (size_t J = I+1; J < Nstrings; J++) {
      /*
        Determine times at which coordinates change order.
        is_I_on_Left records whether the strings are in order
        ...I...J...  J is_I_on_Left changes between two steps, it's
        an indication that the crossing happened.
      */
      // loop over rows      
      for (size_t ti = 0; ti < XYtraj.R()-1; ti++) {

        // Check that coordinates do not coincide.
        assertNotCoincident( XYtraj, ti, I, J );

        // does a crossing occur at time-index ti between trajectories I and J?
        // interpolated crossing stored in PWX structure interpCross
        pair<bool, PWX> interpCross = isCrossing( ti, I, J, XYtraj, t );
        if (interpCross.first)
          wrapper.push_back(interpCross.second);
      }
    }
}

void PairCrossings::run( size_t T ) {

  // each tasks is one "row" of the (I,J) pairing matrix
  // ensure that we do not call more workers than we have tasks
  T = min( T, Nstrings ); 

  // std::bind creates a function reference to a member function
  // needed here b/c passing references to member functions
  // requires explicit object to be referred
  //
  // I'm using it in both threaded and unthreaded version to 
  // clarify the difference in calling the threaded version.
  auto ptrDetectCrossings = bind(&PairCrossings::detectCrossings,
                                 this, placeholders::_1);

  // unthreaded version
  if ( T == 0 ) {
    if (1 <= BRAIDLAB_debuglvl)  {
      printf("colorbraiding_helper: pairwise crossings running UNTHREADED.\n" );
      mexEvalString("pause(0.001);"); //flush
    }
  
    for (size_t I = 0; I < Nstrings; I++) {
      // could be just detectCrossings(I)
      ptrDetectCrossings(I);
    }  
  }
  // threaded version
  else {
    ThreadPool pool(T); // (c) Jakob Progsch

    if (1 <= BRAIDLAB_debuglvl)  {
      printf("colorbraiding_helper: pairwise crossings running on %d threads.\n",T );
      mexEvalString("pause(0.001);"); //flush
    }

    for (size_t I = 0; I < Nstrings; I++) {
      pool.enqueue( ptrDetectCrossings, I);
    }  
  }

}

// initial locations are equal to colors of strings
Strings::Strings( size_t _N ) {
  
  Nstrings = _N;
  locationToColor.reserve(_N);
  colorToLocation.reserve(_N);

  for (size_t i = 0; i < _N; i++ ) {
    locationToColor[i] = i;
    colorToLocation[i] = i;
  }

}

// location given by X0
Strings::Strings( vector<double> X0 ) {
  mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:notimplemented",
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

// Applies a block of pairwise crossings which all have the same
// time to strings. Iterator end is the first element NOT in the block
bool Strings::applyCrossings( list<PWX>::iterator start, list<PWX>::iterator end ) {

  // single crossing was sent -- if it cannot be applied successfuly,
  // there is no way to figure out what went wrong
  if ( distance(start, end) <= 1) {
    return applyCrossing(*start);
  }

  double blockTime = start->t; // check that all crossings do have the same time

  // Multiple crossings were sent -- cycle through all of them and try
  // to apply them sequentially and whittle the block to size zero.
  // Every time we successfully apply a crossing, remove it from the list
  // and re-start the application from the beginning. 
  // Reaching the end of the list means that in that pass, no applications
  // were successful, so the list is inconsistent.
  list<PWX> concurrentBlock( start, end );
  list<PWX>::iterator it = concurrentBlock.begin();
  while ( it != concurrentBlock.end() ) {

    mxAssert(areEqual(blockTime,it->t,2),
             "The block of crossings should have the same time (up to 2 representable doubles).");    

    if ( applyCrossing( *it ) ) { // success -- remove crossing and restart
      concurrentBlock.erase(it); 
      it = concurrentBlock.begin();
    }
    else { // not successful -- try the next
      it++;
    }
  }
  
  // only empty list is a success
  return !concurrentBlock.empty();

}

// copy braid and time to PREALLOCATED double arrays

size_t Strings::braidSize() {
  
  mxAssert(braid.size() == t.size(), "Braid and time vector have inconsistent sizes" );
  return braid.size();

}
void Strings::getBraid( vector<int>& data ) {

  data.clear();
  std::copy(braid.begin(), braid.end(), std::back_inserter(data));

}
void Strings::getTime( vector<double>& data ) {  

  data.clear();
  std::copy(t.begin(), t.end(), std::back_inserter(data));

}


// Attempt to apply a pairwise crossing to the list 
// Successful if two strings were next to each other
bool Strings::applyCrossing( const PWX& cross ) {
  
  //  printf("Crossing time: %f\n", cross.t);

  pair<bool, size_t> success = switchByColor( cross.L, cross.R );
  if (success.first) {
    // generator has a positive sign if left string crosses above the right string
    braid.push_back( cross.L_On_Top ? (success.second+1) : (-(success.second+1)) );
    t.push_back( cross.t );
  }
  return success.first;
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

  mxAssert(sgn<double>(delta) == sgn<double>(T),
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
      mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:coincidentparticles",
                        "Coincident particles: braid not defined.");
    }
    else {
      mexErrMsgIdAndTxt("BRAIDLAB:braid:color_braiding:coincidentproj",
                        "Coincident projection coordinate; change projection angle (type help braid.braid).");
    }
  }
}



#endif // BRAIDLAB_COLORBRAIDING_HELPER_HPP
