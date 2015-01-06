//
//
// EQFUZZY
//
// Check equality of two vectors up to D float-representable numbers.
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

#ifndef BRAIDLAB_EQFUZZY_HPP
#define BRAIDLAB_EQFUZZY_HPP

#include <cmath>

// check for equality taking float precision into account
bool eqfuzzy( double a, double b, int D ) {

  bool retval;

  if (a == b)
    retval = true;
  else{
    // ensure a < b
    if (b < a) {
      double tmp = b;
      b = a;
      a = tmp;
    }
    // compute the D-th representable number larger than a
    double bnd = a;
    for (int i = 0; i < D; i++)
      bnd = std::nextafter(bnd, 1.0);
    // check if b is between a and bnd
    retval = b <= bnd;
  }

  return retval;
}

#endif
