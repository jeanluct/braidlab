#ifndef BRAIDLAB_UPDATE_RULES_HPP
#define BRAIDLAB_UPDATE_RULES_HPP

#include <vector>

#include "mex.h"
#include "sumg.hpp"

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic         <marko@math.wisc.edu>
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

template <typename T> inline T pos(T x) { return (x > 0 ? x : 0); }
template <typename T> inline T neg(T x) { return (x < 0 ? x : 0); }

template <typename T>  int sign(T x) {
  return ( x > 0 ? 1 : (x < 0 ? -1 : 0) );
}


// with pre-allocated temp storage
template <typename T>
void inline update_rules(const int Ngen, const int Npunc, const int *braidword,
                         T *a, T *b, T *a_tmp, T *b_tmp, const int Ncoord, int* opSign = 0) {

  // Copy initial row data
  for (mwIndex k = 1; k <= Ncoord/2; ++k) {
    a_tmp[k] = a[k];
    b_tmp[k] = b[k];
  }

  for (int g = 0; g < Ngen; ++g) { // Loop over generators.
    int idx = abs(braidword[g]);
    if (braidword[g] > 0) {
      if (idx == 1) {
        b_tmp[1] = sumg( a[1] , pos(b[1]) );
        a_tmp[1] = sumg( -b[1] , pos(b_tmp[1]) );
        if (opSign != 0) {
          opSign[0*Ngen + g] = sign(b[1]);
          opSign[1*Ngen + g] = sign(b_tmp[1]);
        }
      }
      else if (idx == Npunc-1) {
        b_tmp[Npunc-2] = sumg( a[Npunc-2] , neg(b[Npunc-2]) );
        a_tmp[Npunc-2] = sumg( -b[Npunc-2] , neg(b_tmp[Npunc-2]) );
        if (opSign != 0) {
          opSign[0*Ngen + g] = sign(b[Npunc-2]);
          opSign[1*Ngen + g] = sign(b_tmp[Npunc-2]);
        }
      }
      else {
        T c = sumg(sumg(a[idx-1],-a[idx]) , sumg(-pos(b[idx]),neg(b[idx-1])));
        a_tmp[idx-1] = sumg(sumg(a[idx-1],-pos(b[idx-1])),-pos(sumg(pos(b[idx]),c)));
        b_tmp[idx-1] = sumg( b[idx] , neg(c) );
        a_tmp[idx] = sumg(sumg(a[idx],-neg(b[idx])),-neg(sumg(neg(b[idx-1]),-c)));
        b_tmp[idx] = sumg( b[idx-1] , -neg(c) );

        if (opSign != 0) {
          opSign[0*Ngen + g] = sign(b[idx]);
          opSign[1*Ngen + g] = sign(b[idx-1]);
          opSign[2*Ngen + g] = sign(c);
          opSign[3*Ngen + g] = sign(pos(b[idx]) + c);
          opSign[4*Ngen + g] = sign(neg(b[idx-1]) - c);
        }
      }
    }
    else if (braidword[g] < 0) {
      if (idx == 1) {
        b_tmp[1] = sumg( -a[1] , pos(b[1]) );
        a_tmp[1] = sumg( b[1] , -pos(b_tmp[1]) );
        if (opSign != 0) {
          opSign[0*Ngen + g] = sign(b[1]);
          opSign[1*Ngen + g] = sign(b_tmp[1]);
        }
      }
      else if (idx == Npunc-1) {
        b_tmp[Npunc-2] = sumg( -a[Npunc-2] , neg(b[Npunc-2]) );
        a_tmp[Npunc-2] = sumg( b[Npunc-2] , -neg(b_tmp[Npunc-2]) );
        if (opSign != 0) {
          opSign[0*Ngen + g] = sign(b[Npunc-2]);
          opSign[1*Ngen + g] = sign(b_tmp[Npunc-2]);
        }
      }
      else {
        T d = sumg(sumg(a[idx-1], -a[idx]) , sumg(pos(b[idx]), -neg(b[idx-1])));
        a_tmp[idx-1] = sumg(sumg(a[idx-1],pos(b[idx-1])),pos(sumg(pos(b[idx]),-d)));
        b_tmp[idx-1] = sumg( b[idx] , -pos(d) );
        a_tmp[idx] = sumg(sumg(a[idx] , neg(b[idx])) , neg(sumg(neg(b[idx-1]) , d)));
        b_tmp[idx] = sumg( b[idx-1] , pos(d) );

        if (opSign != 0) {
          opSign[0*Ngen + g] = sign(b[idx]);
          opSign[1*Ngen + g] = sign(b[idx-1]);
          opSign[2*Ngen + g] = sign(pos(b[idx]) - d);
          opSign[3*Ngen + g] = sign(d);
          opSign[4*Ngen + g] = sign(neg(b[idx-1]) + d);
        }
      }
    }


    for (mwIndex k = 1; k <= Ncoord/2; ++k) {
      a[k] = a_tmp[k];
      b[k] = b_tmp[k];
    }

  }

}

// without pre-allocated temp storage
template <typename T>
void update_rules(const int Ngen, const int Npunc, const int *braidword,
                  T *a, T *b, int* opSign = 0) {

  const int Ncoord = 2*(Npunc-2);

  // Make 1-indexed arrays.
  std::vector<T> a_storage (Ncoord/2);
  std::vector<T> b_storage (Ncoord/2);

  T *a_tmp = a_storage.data()-1;
  T *b_tmp = b_storage.data()-1;

  update_rules( Ngen, Npunc, braidword, a, b, a_tmp, b_tmp, Ncoord, opSign );

}

#endif // BRAIDLAB_UPDATE_RULES_HPP
