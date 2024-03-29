//
// Matlab MEX file
//
// COLORBRAIDING Construct a sequence of braid generators from a
// physical braid specified by a set of trajectories. These cpp
// functions are intended to speed up the colorbrading Matlab code
// used by the braid constructor. Written by Marko Budisic.
//
// Responds to MATLAB global variable:
// BRAIDLAB_debuglvl  -- sets the level of logging output from the code
//

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2021  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic          <marko@clarkson.edu>
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

#ifndef BRAIDLAB_CROSS2GEN_HELPER_HPP
#define BRAIDLAB_CROSS2GEN_HELPER_HPP


// real GCC feature list:
// https://gcc.gnu.org/projects/cxx0x.html
#if ( (defined __GNUC__) && (!defined __clang__) )

#define GCCVERSION (__GNUC__ * 10000            \
                    + __GNUC_MINOR__ * 100      \
                    + __GNUC_PATCHLEVEL__)

# if ( (!defined BRAIDLAB_NOTHREADING) &&           \
       ( GCCVERSION < 40600) ) // less than GCC 4.5
# define BRAIDLAB_NOTHREADING
# endif
#endif // gcc

// CLANG: feature list:
// http://clang.llvm.org/cxx_status.html
#if (defined __clang__)

#define CLANGVERSION (__clang_major__ * 10000   \
                      + __clang_minor__ * 100   \
                      + __clang_patchlevel__)

# if ( (!defined BRAIDLAB_NOTHREADING) &&               \
       (CLANGVERSION < 30300) ) // less than Clang 3.3
# define BRAIDLAB_NOTHREADING
# endif

#endif // clang

// The printf code for printing a size_t or mwSize (unsigned).
// On GCC this is a long unsigned int.
// The z stands for a variable width (C99, imported by C++11).
// However, this may not be portable to other compilers.
// See
// https://stackoverflow.com/questions/1546789/clean-code-to-printf-size-t-in-c-or-nearest-equivalent-of-c99s-z-in-c
// https://stackoverflow.com/questions/3209909/how-to-printf-unsigned-long-in-c
#define BRAIDLAB_PRINTF_SIZE_T "%zu"

#include <iostream>
#include <vector>
#include <list>
#include <algorithm>
#include <cmath>
#include <ctime>
#include <sstream>
#include <stdexcept>

#ifndef BRAIDLAB_NOTHREADING
#include <mutex>
#include "ThreadPool.h" // (c) Jakob Progsch, Václav Zeman
                        // https://github.com/progschj/ThreadPool
#endif

#define ABSTOL_TIME (1e-14)

#include "mex.h"

int BRAIDLAB_debuglvl = -1;

////////////////// DECLARATIONS  /////////////////////////

/*

  From a set of trajectories defining a physical braid, compute the
  algebraic braid corresponding to it based on the X coordinate.

  IMPORTANT:
  Trajectories are assumed to be sorted by values of the X coordinate
  at the first time step.

  Arguments:
  XYtraj -- (# timesteps) x 2 x (# trajectories/strings) matrix
         "X" and "Y" coordinates correspond to indexing by the second dimension
  t      -- (# timesteps) vector

*/

class Real3DMatrix;
class RealVector;

/*
  Real3DMatrix

  Class that helps with access of REAL elements in Matlab 3D matrices.
  Constructed from Matlab matrix mxArray.

  Implements operator() for easier access to elements in (row, column,
  span) notation (ZERO BASED INDEXING)

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
  double operator()( const mwIndex row, const mwIndex col, const mwIndex lay )
    const;

  // print 3D matrix, each 2D slice at a time
  void print() {
    for ( size_t s = 0; s < S(); s++ ) {
      printf("Slice " BRAIDLAB_PRINTF_SIZE_T ": \n",s);
      for ( size_t r = 0; r < R(); r++ ) {
        for ( size_t c = 0; c < C(); c++ )
          printf("%.3f\t", (*this)(r, c, s) );
        printf("\n");
      }
    }
  }

  // access sizes
  mwSize R(void) const { return _R; }
  mwSize C(void) const { return _C; }
  mwSize S(void) const { return _S; }

};

class RealVector {

  const double *data;
  mwSize _N;

public:

  // constructor: takes MATLAB array as an argument
  RealVector( const mxArray *in );

  // access elements using vector( n ) syntax
  double operator()( const mwIndex n ) const;

  // access size
  mwSize N(void) const { return _N; }

};

// A pairwise crossing
class PWX {
public:
  double t;
  bool L_On_Top; // is left string on top
  mwIndex L; // index of the left string
  mwIndex R; // index of the right string

  PWX(double nt = 0, bool nSign = false, mwIndex nL=0, mwIndex nR=0) :
    t(nt), L_On_Top(nSign), L(nL), R(nR) {}

  // PWX1 < PWX2 if their times are in that order
  bool operator <(const PWX& rhs) const { return t < rhs.t; }

  // basic log to stdout
  void print(int debuglevel);

};

// simple wrapper around list<PWX> object to prevent it from being
// written concurrently by two threads
class ThreadSafePWXList {

public:

  ThreadSafePWXList( std::list<PWX>& s ) : storage(s) {}

  void push_back( PWX data ) {
#ifndef BRAIDLAB_NOTHREADING
    mtx.lock();
#endif
    storage.push_back(data);
#ifndef BRAIDLAB_NOTHREADING
    mtx.unlock();
#endif
  }

private:
  std::list<PWX>& storage;
#ifndef BRAIDLAB_NOTHREADING
  std::mutex mtx;
#endif
};

// Exception used for thread-safe error reporting in pairwise detection part
class PWXexception : public std::logic_error
{
public:
  // The next line is for gcc >= 4.8 (c++11 I think).
  // using std::logic_error::logic_error;
  // Explicitly declare and define the constructor instead.
  PWXexception(const std::string& __arg, mwIndex I, mwIndex J) :
    std::logic_error(__arg), L(I), R(J) {};

  int code;

  mwIndex L, R; // particles causing the error

  // return code of the Matlab error that should be reported
  const char* id() {
    switch (code) {
    case 1:
      return "BRAIDLAB:braid:colorbraiding:interpolationerror";
    case 2:
      return "BRAIDLAB:braid:colorbraiding:coincidentprojection";
    case 3:
      return "BRAIDLAB:braid:colorbraiding:coincidentparticles";
    default:
      return "BRAIDLAB:braid:colorbraiding:UNKNOWN";
    }
  }

};

class ThreadSafeExceptionList {

public:

  ThreadSafeExceptionList( std::list<PWXexception>& s ) : externalStorage(s) {}

  void push_back( PWXexception data ) {
#ifndef BRAIDLAB_NOTHREADING
    mtx.lock();
#endif
    externalStorage.push_back(data);
#ifndef BRAIDLAB_NOTHREADING
    mtx.unlock();
#endif
  }

private:
  std::list<PWXexception>& externalStorage;
#ifndef BRAIDLAB_NOTHREADING
  std::mutex mtx;
#endif
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
                 std::list<PWX>& crossingStorage,
                 std::list<PWXexception>& errorStorage,
                 const double aAbsTol)
    : listOfCrossings(crossingStorage),
      listOfErrors(errorStorage),
      XYtraj(_XYtraj),
      t(_t),
      Nstrings(_XYtraj.S()),
      AbsTol(aAbsTol) {}

  // run the calculation on T threads
  void run( size_t T = 1 );

  // Detects crossings between string with color "anchor" and all
  // subsequent strings
  void detectCrossings( mwIndex anchor );

private:
  ThreadSafePWXList listOfCrossings;
  ThreadSafeExceptionList listOfErrors;
  Real3DMatrix& XYtraj;
  RealVector& t;
  mwSize Nstrings;
  double AbsTol;

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
  Strings( mwSize N);

  // constructor -- X0 positions of strings at the initial time
  // colors are determined by location of elements X0
  // e.g., [-0.3, 7.2, 1] results in colors [1 3 2]
  Strings( std::vector<double> X0 );

  // Apply a block of concurrent crossings to the list.
  // Returns true if the block was applied consistently
  // false otherwise.
  bool applyCrossings( std::list<PWX>::iterator start,
                       std::list<PWX>::iterator end );

  // copy braid and time to PREALLOCATED double arrays
  mwSize braidSize();
  void getBraid( std::vector<int>& data );
  void getTime( std::vector<double>& data );

private:

  mwSize Nstrings;

  // determine color (element value) of the string based on its
  // current location (element index)
  std::vector<mwIndex> locationToColor;

  // determine current location (element value) of the string based on
  // its color (element index)
  std::vector<mwIndex> colorToLocation;

  // storage for braid generators
  std::list<double> t;
  std::list<int> braid;

  // return true if colorToLocation and locationToColor vectors are
  // consistent
  void assertLocationColorSanity();

  // perform operation of exchanging braids of COLOR L and R
  // returns
  // .first == true if exchange was successful
  // .second == generator index if .first == true (otherwise generator
  // == Nstrings)
  std::pair<bool, mwIndex> switchByColor( mwIndex L, mwIndex R );

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

  Throws PWXexception in case input trajectories
  overlap in X or XY coordinates.
*/
std::pair<bool,PWX> isCrossing( mwIndex ti, mwIndex I, mwIndex J,
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


/*
  Check that coordinates of trajectories I and J do not coincide at
  time-index ti.

  Returns 0 if
  X coordinates do not coincide (everything is OK).

  Returns 1 if
  only X coordinates coincide for a pair of strings. This means a
  different projection angle will fix things.

  Returns 2 if
  both X and Y coordinates coincide, this is a true trajectory
  intersection, which means that the braid is undefined.
*/
void assertNotCoincident(const Real3DMatrix& XYtraj, const mwIndex ti,
                         const mwIndex I, const mwIndex J,
                         const double AbsTol);

// signum function
template <typename T> int sgn(T val);



//////////////////////////// DEFINITIONS  ////////////////////////////

std::pair< std::vector<int>, std::vector<double> >
cross2gen( Real3DMatrix& XYtraj, RealVector& t,
           const double AbsTol, size_t Nthreads )
{
  Timer tictoc( 1 );
  tictoc.tic();

  mwSize Nstrings = XYtraj.S();
  bool anyXCoinc = false;

  // return braid information
  std::pair< std::vector<int>, std::vector<double> > retval;

  std::list<PWX> crossings;
  std::list<PWXexception> crossingErrors;

  PairCrossings pairCrosser( XYtraj, t, crossings, crossingErrors, AbsTol );

  pairCrosser.run(Nthreads);
  tictoc.toc("cross2gen_helper: pairwise crossing detection", true);

  // there were crossingErrors in pairwise detection
  if (! crossingErrors.empty() ) {
    int count  = 1;
    // output individual errors
    if (2 <= BRAIDLAB_debuglvl)  {
      mexPrintf("List of all crossingErrors encountered:\n");
      for( std::list<PWXexception>::iterator e = crossingErrors.begin();
           e != crossingErrors.end();
           e++, count++ ) {
        mexPrintf("Error %d: ", count);
        mexPrintf( e->what() );
        mexPrintf("\n");
      }
    }

    // first error is invoked as a MATLAB error
    std::stringstream report;

    report << "[";
    report << crossingErrors.begin()->L << " ";
    report << crossingErrors.begin()->R << "] | ";
    report << crossingErrors.begin()->what();

    mexErrMsgIdAndTxt(crossingErrors.begin()->id(), report.str().c_str() );
  }

  crossings.sort();
  tictoc.toc("cross2gen_helper: sorting crossdat", true);

  if (2 <= BRAIDLAB_debuglvl)  {
    printf("cross2gen_helper: Number of crossings " BRAIDLAB_PRINTF_SIZE_T "\n", crossings.size() );
    mexEvalString("pause(0.001);"); //flush
  }

  // Determine generators from ordered crossing data
  if (2 <= BRAIDLAB_debuglvl)  {
    printf("cross2gen_helper: Convert crossings to generator sequence\n");
    mexEvalString("pause(0.001);");
  }

  Strings stringSet(Nstrings);

  // Cycle through all crossings, apply them to the strands
  bool notcrossed;
  std::list<PWX>::iterator blockStart = crossings.begin();
  std::list<PWX>::iterator blockEnd;

  size_t cnt = 0;
  while (blockStart != crossings.end() ) {

    // determine the block of crossings that happen
    // at the same time
    blockEnd = blockStart;
    blockEnd++;
    // all times within ABSTOL_TIME are considered to being concurrent
    // blockEnd is the first non-concurrent crossing
    while ( std::abs(blockStart->t - blockEnd->t) < ABSTOL_TIME ) {
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

      std::stringstream msg;
      msg << "Attempting to apply crossings resulted in inconsistency. ";
      msg << "Concurrent block at time " << blockTime << ", ";
      msg << distance( blockStart, blockEnd );
      msg << " crossings between " << startN << " and "
          << endN << " cannot be resolved.";
      mexErrMsgIdAndTxt(
            "BRAIDLAB:braid:colorbraiding:badcrossing", msg.str().c_str());
    }
  }

  tictoc.toc("cross2gen_helper: generating the braid", true);

  stringSet.getBraid( retval.first );
  stringSet.getTime ( retval.second );
  tictoc.toc("cross2gen_helper: copying output");

  return retval;

}

// constructor from MATLAB
Real3DMatrix::Real3DMatrix( const mxArray *in ) : data( mxGetPr(in) ) {
  if ( mxGetNumberOfDimensions(in) != 3 )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:not3d",
                      "Requires 3d matrix.");
  const mwSize* sizes = mxGetDimensions(in);
  _R = sizes[0];
  _C = sizes[1];
  _S = sizes[2];
}

// access elements
double Real3DMatrix::operator()
  (const mwIndex row, const mwIndex col, const mwIndex lay ) const
{
  if ( !( row < _R) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:out_of_bounds",
                      "Row index out of bounds "
                      "(Remember: zero indexing used)");
  if ( !( col < _C) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:out_of_bounds",
                      "Column index out of bounds "
                      "(Remember: zero indexing used)");
  if ( !( lay < _S) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:out_of_bounds",
                      "Span index out of bounds "
                      "(Remember: zero indexing used)");

  return data[(lay*_C + col)*_R + row];
}

// constructor from MATLAB
RealVector::RealVector( const mxArray *in )
{
  if ( mxGetNumberOfDimensions(in) != 2 )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:not1d",
                      "Requires 1d matrix (array).");
  _N = mxGetDimensions(in)[0] > 1 ?
    mxGetDimensions(in)[0] : mxGetDimensions(in)[1];
  data = mxGetPr(in);
}

// access elements using vector( n ) syntax
double RealVector::operator()( const mwIndex n ) const {
  if ( !( n < _N) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:out_of_bounds",
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
    printf("%2f \t %c \t " BRAIDLAB_PRINTF_SIZE_T " \t " BRAIDLAB_PRINTF_SIZE_T "\n", t, L_On_Top ? '+' : '-', L, R);
    mexEvalString("pause(0.001);");
  }
}

void PairCrossings::detectCrossings( mwIndex I ) {
  for (mwIndex J = I+1; J < Nstrings; J++) {
    /*
      Determine times at which coordinates change order.
      is_I_on_Left records whether the strings are in order
      ...I...J...  J is_I_on_Left changes between two steps, it's
      an indication that the crossing happened.
    */

    try {
      assertNotCoincident( XYtraj, 0, I, J, AbsTol );
    }
    catch( PWXexception& e ) {
      listOfErrors.push_back( e );
    }
    // loop over rows
    for (mwIndex ti = 0; ti < XYtraj.R()-1; ti++) {

      // does a crossing occur at time-index ti between trajectories I and J?
      try {

        // Check that end-points do not coincide
        // (beginning was checked in previous iteration)
        assertNotCoincident( XYtraj, ti+1, I, J, AbsTol );

        // first element is true if crossing occurs
        // second element stores data about crossing
        std::pair<bool, PWX> interpCross = isCrossing( ti, I, J, XYtraj, t );

        // interpolated crossing stored in PWX structure interpCross
        if (interpCross.first)
          listOfCrossings.push_back(interpCross.second);

      }
      catch( PWXexception& e ) {
        listOfErrors.push_back( e );
        continue;
      }

    }
  }
}

void PairCrossings::run( size_t NThreadsRequested ) {

#ifndef BRAIDLAB_NOTHREADING
  // each tasks is one "row" of the (I,J) pairing matrix
  // ensure that we do not call more workers than we have tasks
  NThreadsRequested = NThreadsRequested < Nstrings ? NThreadsRequested : Nstrings;
#else
  NThreadsRequested = 1;
#endif

  if ( NThreadsRequested == 0 ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:numthreadsnotpositive",
                      "Number of threads requested must be positive");
  }

  // unthreaded version
  if ( NThreadsRequested == 1 ) {
    if (2 <= BRAIDLAB_debuglvl)  {
      printf("cross2gen_helper: pairwise crossings running UNTHREADED.\n" );
      mexEvalString("pause(0.001);"); //flush
    }
    for (mwIndex I = 0; I < Nstrings; I++) {
      detectCrossings(I);
    }
  }
#ifndef BRAIDLAB_NOTHREADING
  // threaded version
  else {
    // std::bind creates a function reference to a member function
    // needed here b/c passing references to member functions
    // requires explicit object to be referred
    //
    auto ptrDetectCrossings = std::bind(&PairCrossings::detectCrossings,
                                        this, std::placeholders::_1);
    ThreadPool pool(NThreadsRequested); // (c) Jakob Progsch, Václav Zeman

    if (2 <= BRAIDLAB_debuglvl)  {
      printf(
        "cross2gen_helper: pairwise crossings running on " BRAIDLAB_PRINTF_SIZE_T " threads.\n",
        NThreadsRequested );
      mexEvalString("pause(0.001);"); //flush
    }

    for (mwIndex I = 0; I < Nstrings; I++) {
      pool.enqueue( ptrDetectCrossings, I);
    }
  }
#endif

}

// initial locations are equal to colors of strings
Strings::Strings( mwIndex _N ) {

  Nstrings = _N;
  locationToColor.reserve(_N);
  colorToLocation.reserve(_N);

  for (mwIndex i = 0; i < _N; i++ ) {
    locationToColor[i] = i;
    colorToLocation[i] = i;
  }

}

// location given by X0
Strings::Strings( std::vector<double> X0 ) {
  mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:notimplemented",
                    "Strings custom color constructor not implemented");
}

// ensures that the locationToColor and colorToLocation are inverse
void Strings::assertLocationColorSanity() {

  mxAssert( locationToColor.size() == Nstrings,
            "locationToColor is not of correct size" );
  mxAssert( colorToLocation.size() == Nstrings,
            "colorToLocation is not of correct size" );
  for (mwIndex i = 0; i < Nstrings; i++ ) {
    mxAssert( locationToColor[ colorToLocation[i] ] == i,
              "locationToColor . colorToLocation != Id" );
    mxAssert( colorToLocation[ locationToColor[i] ] == i,
              "colorToLocation . locationToColor != Id" );
  }

}

// Applies a block of pairwise crossings which all have the same
// time to strings. Iterator end is the first element NOT in the block
bool Strings::applyCrossings
  ( std::list<PWX>::iterator start, std::list<PWX>::iterator end )
{

  mxAssert( distance(start, end) > 0,
            "Block has to contain at least one crossing" );

  if (3 <= BRAIDLAB_debuglvl)  {
    printf("Concurrent block size: " BRAIDLAB_PRINTF_SIZE_T "\n", distance(start, end) );
  }

  // single crossing was sent -- if it cannot be applied successfuly,
  // there is no way to figure out what went wrong
  if ( distance(start, end) == 1) {
    return applyCrossing(*start);
  }
  else {

    double blockStartTime = start->t;

    // Multiple crossings were sent -- cycle through all of them and try
    // to apply them sequentially and whittle the block to size zero.
    // Every time we successfully apply a crossing, remove it from the list
    // and re-start the application from the beginning.
    // Reaching the end of the list means that in that pass, no applications
    // were successful, so the list is inconsistent.
    std::list<PWX> concurrentBlock( start, end );
    std::list<PWX>::iterator it = concurrentBlock.begin();
    while ( it != concurrentBlock.end() ) {

      mxAssert(std::abs(blockStartTime - it->t) < ABSTOL_TIME,
               "Entire block should be roughly concurrent.");

      if ( applyCrossing( *it ) ) { // success -- remove crossing and restart
        concurrentBlock.erase(it);
        it = concurrentBlock.begin();
      }
      else { // not successful -- try the next
        it++;
      }
    }

    // only empty list is a success
    return concurrentBlock.empty();
  }

}

// copy braid and time to PREALLOCATED double arrays

mwSize Strings::braidSize() {

  mxAssert(braid.size() == t.size(),
           "Braid and time vector have inconsistent sizes" );
  return braid.size();

}
void Strings::getBraid( std::vector<int>& data ) {

  data.clear();
  std::copy(braid.begin(), braid.end(), std::back_inserter(data));

}
void Strings::getTime( std::vector<double>& data ) {

  data.clear();
  std::copy(t.begin(), t.end(), std::back_inserter(data));

}

// Attempt to apply a pairwise crossing to the list
// Successful if two strings were next to each other
bool Strings::applyCrossing( const PWX& cross ) {

  std::pair<bool, mwIndex> success = switchByColor( cross.L, cross.R );
  if (success.first) {
    // generator has a positive sign if left string crosses above the
    // right string
    braid.push_back( cross.L_On_Top ?
                     (success.second+1) : (-(success.second+1)) );
    t.push_back( cross.t );
  }
  return success.first;
}

std::pair<bool, mwIndex> Strings::switchByColor( mwIndex L, mwIndex R ) {

  // find locations of the string
  mwIndex oL = colorToLocation[L];
  mwIndex oR = colorToLocation[R];

  // if the higher string is in fact the next string to the right,
  // apply the crossing
  std::pair<bool, mwIndex> result(false, Nstrings);
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
std::pair<bool,PWX> isCrossing( mwIndex ti, mwIndex I, mwIndex J,
                           Real3DMatrix& XYtraj, RealVector& t) {

  bool I_On_Left = ( XYtraj(ti, 0, I) < XYtraj(ti, 0, J) );

  // NO CROSSING: order is the same -- exit the function
  if ( I_On_Left == (XYtraj(ti+1, 0, I) < XYtraj(ti+1, 0, J)) ) {
    return std::pair<bool, PWX>( false, PWX() );
  }

  // CROSSING == order of strings changes

  // calculate indices of the Left and Right string
  mwIndex L, R;
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

  if (sgn<double>(delta) != sgn<double>(T) ) {
    PWXexception e("Error in interpolating crossing time."
                   " Interpolated time-point is outside the interval "
                   "determined by input.", L+1, R+1);
    e.code = 1;
    throw e;
  }

  // interpolation
  double tc = t(ti) + delta * T;
  double YLc = XYtraj(ti, 1, L) + delta * dYL;
  double YRc = XYtraj(ti, 1, R) + delta * dYR;

  // left string is on top? important for direction of the generator
  bool leftOnTop = YLc > YRc;

  return std::pair<bool, PWX>( true, PWX(tc, leftOnTop, L, R) );
}

// signum function
template <typename T> int sgn(T val) {
  return (T(0) < val) - (val < T(0));
}


// Assert that trajectories I and J are not coincident at time step ti
// throws PWXexception otherwise
void assertNotCoincident(const Real3DMatrix& XYtraj, const mwIndex ti,
                         const mwIndex I, const mwIndex J,
                         const double AbsTol)
{
  int code = 0;

  if ( std::abs(XYtraj(ti, 0, I) - XYtraj(ti, 0, J)) < AbsTol ) { // X
    code = 2; // for code explanation, see PWXexception
    if ( std::abs(XYtraj(ti, 1, I) - XYtraj(ti, 1, J)) < AbsTol ) { // Y
      code = 3; // for code explanation, see PWXexception
    }
  }

  if ( code == 0 ) return; // no error

  // Construct error message.  Make sure to use Matlab 1-indexing.
  std::stringstream report;
  report << "Particles " << I+1 << " and " << J+1 << " have coincident ";
  if (code == 2)
    report << "projection ";
  else
    report << "coordinates ";
  report << "at time index " << ti+1 << ": ";
  if (code == 2)
    report << "change projection angle (type help braid.braid).";
  else
    report << "braid not defined.";

  PWXexception e(report.str(), I+1, J+1);
  e.code = code;
  throw e;

  return;
}


#endif // BRAIDLAB_CROSS2GEN_HELPER_HPP
