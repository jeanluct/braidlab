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
#include <deque>
#include <algorithm>
#include <cmath>
#include "mex.h"
#include "colorbraiding_helper.hpp"



using namespace std;

// A pairwise crossing
typedef pair<double, char> PWX; // (time, sign) pair

// A matrix storing pairwise crossings.
// Nested std::vectors enable [i][j] syntax for access in O(1).
// deque<PWX> allows O(1) append operation on each element.
// The constructor just allows for a one-shot initialization.
class PWCrossings {

private:
  size_t Ncrossings; // number of crossings stored
  vector< vector< deque<PWX> > > data; // main data storage

public:

  // initialize the structure to accomodate N strands
  PWCrossings( size_t N );

  // Add a crossing c to pair (I,J)
  void add( size_t I, size_t J, const PWX& c );

  // Return all crossings of pair (I,J)
  const deque<PWX>& operator() ( size_t I, size_t J );

  // return the total number of added pairwise crossings
  size_t total() {
    return Ncrossings;
  }

};

void crossingsToGenerators( Real3DMatrix& XYtraj, RealVector& t) {

  Timer tictoc;
  size_t Nstrands = XYtraj.S();

  // Find pairwise crossings and store them into cross_pairwise matrix
  PWCrossings cross_pairwise( Nstrands );

  /* 
     Check there are no coincident trajectories:

     If only X coordinates coincide for a pair of strands, this means a
     different projection angle will fix things.

     If both X and Y coordinates coincide, then this is a true trajectory
     intersection, which means that the braid is undefined.
  */
  tictoc.tic();
  bool anyXCoinc = false;  
  for (int I = 0; I < Nstrands; I++) {
    for (int J = I+1; J < Nstrands; J++) {
      for (int ti = 0; ti < XYtraj.R(); ti++) {
        // crossing is detected as "within 10 float-representable numbers"
        if ( areEqual(XYtraj(ti, 0, I), XYtraj(ti, 0, J), 10 ) ) {
          anyXCoinc = true;
          if ( areEqual(XYtraj(ti, 1, I), XYtraj(ti, 1, J), 10 ) ) {
            printf("Xvalues: %.3e %.3e\n", XYtraj(ti, 0, I), XYtraj(ti, 0, J) );            
            printf("Yvalues: %.3e %.3e\n", XYtraj(ti, 1, I), XYtraj(ti, 1, J) );
            mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:coincidentparticles",
                              "Coincident particles: Braid not defined.");
          }
        }
      }
    }
  }
  if (anyXCoinc)
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:coincidentproj",
                      "Coincident projection coordinate: change projection angle.");

  tictoc.toc("Checking coincidence");

  // Determine time-ordered sequence of crossings and store them into cross_timewise matrix
  mexEvalString("braidlab.debugmsg('Part 2: Search for crossings between pairs of strings')");
  
  // Determine generators from ordered crossing data
  mexEvalString("braidlab.debugmsg('Part 3: Sorting the pair crossings into the generator sequence')");  

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

PWCrossings::PWCrossings( size_t Nstrands ) : Ncrossings(0) {
  // initialize a square Nstrands x Nstrands matrix
  data.resize( Nstrands );
  for (size_t i = 0; i < Nstrands; i++ ) {
    data[i].resize(Nstrands);
  }
}

void PWCrossings::add( size_t I, size_t J, const PWX& c ) {
  if ( !(I < data.size() && J < data.size() ) ) 
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:PWCrossings",
                      "add() out of bounds");
  data[I][J].push_back( c );
  Ncrossings++;
}

const deque<PWX>& PWCrossings::operator() ( size_t I, size_t J ) {
  if ( !(I < data.size() && J < data.size() ) ) 
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:PWCrossings",
                      "operator() out of bounds");
  return data[I][J];
}
