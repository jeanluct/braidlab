#include "mex.h"

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

inline void mexerr()
{
  mexErrMsgIdAndTxt("BRAIDLAB:braid:sumg:overflow",
		    "Summation has overflowed.");
}


inline long long sumg(long long a, long long b)
{
  if (a >= 0)
    {
      if (LLONG_MAX - a < b) mexerr();
    }
  else
    {
      if (b < LLONG_MIN - a) mexerr();
    }

  return a+b;
}


inline int sumg(int a, int b)
{
  if (a >= 0)
    {
      if (INT_MAX - a < b) mexerr();
    }
  else
    {
      if (b < INT_MIN - a) mexerr();
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
