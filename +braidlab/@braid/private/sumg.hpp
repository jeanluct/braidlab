#ifndef BRAIDLAB_SUMG_HPP
#define BRAIDLAB_SUMG_HPP

#include <string>
#include "mex.h"
#ifdef BRAIDLAB_USE_GMP
#include <gmpxx.h>
#endif

// Guarded sum: check for overflow.

// https://stackoverflow.com/questions/3944505/detecting-signed-overflow-in-c-c?rq=1

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   https://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2024  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic          <mbudisic@gmail.com>
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
//   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
// LICENSE>

template <class T>
inline void mexerr(T a, T b, std::string p)
{
  std::string err = "Summation of " + p + " and " + p + " has overflowed.";
  mexErrMsgIdAndTxt("BRAIDLAB:braid:sumg:overflow",err.c_str(),a,b);
}


inline long long sumg(long long a, long long b)
{
  if (a >= 0)
    {
      if (LLONG_MAX - a < b) mexerr(a,b,"%lld");
    }
  else
    {
      if (b < LLONG_MIN - a) mexerr(a,b,"%lld");
    }

  return a+b;
}


inline int sumg(int a, int b)
{
  if (a >= 0)
    {
      if (INT_MAX - a < b) mexerr(a,b,"%d");
    }
  else
    {
      if (b < INT_MIN - a) mexerr(a,b,"%d");
    }

  return a+b;
}


inline double sumg(double a, double b)
{
  // TODO: check for overflow of doubles.
  return a+b;
}


inline float sumg(float a, float b)
{
  // TODO: check for overflow of floats.
  return a+b;
}


#ifdef BRAIDLAB_USE_GMP
inline mpz_class sumg(mpz_class a, mpz_class b)
{
  // mpz_class never overflows.
  return a+b;
}
#endif

#endif // BRAIDLAB_SUMG_HPP
