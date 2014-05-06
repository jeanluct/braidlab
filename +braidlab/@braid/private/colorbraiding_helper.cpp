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
  vector< vector< deque<PWX> > > data;

public:
  PWCrossings( size_t Nstrands ) : Ncrossings(0) {
    data.resize( Nstrands );
    for (size_t i = 0; i < Nstrands; i++ ) {
      data[i].resize(Nstrands);
    }
  }

  // add a crossing and record the size
  void add( size_t I, size_t J, const PWX& c ) {
    data[I][J].push_back( c );
    Ncrossings++;
  }

  const deque<PWX>& operator() ( size_t I, size_t J ) {
    return data[I][J];
  }

  size_t total() {
    return Ncrossings;
  }

};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  Matrix_3D trj = Matrix_3D( prhs[0] );
  if ( trj.C() != 2 ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding_helper:input","2 columns required for trajectory");
  }

  size_t Nstrands = trj.S();

  // Find pairwise crossings and store them into cross_pairwise matrix
  PWCrossings cross_pairwise( Nstrands );

  cross_pairwise.add( 2,2, PWX(0.5, 1) );

  printf("Total crossings: %d\n", cross_pairwise.total() );
  printf("Crossing: %f %d\n", cross_pairwise(2,2)[0].first, cross_pairwise(2,2)[0].second );
  

  // Determine time-ordered sequence of crossings and store them into cross_timewise matrix

  // Determine generators from ordered crossing data
}
