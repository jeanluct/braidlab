#ifndef BRAIDLAB_UPDATE_RULES_HPP
#define BRAIDLAB_UPDATE_RULES_HPP

#include "mex.h"
#include "sumg.hpp"

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

template <class T> inline T pos(T x) { return (x > 0 ? x : 0); }
template <class T> inline T neg(T x) { return (x < 0 ? x : 0); }

template <class T>
inline void update_rules(const int Ngen, const int n, const int *ii, T *a, T *b)
{
  const int N = 2*(n-2);

  // Make 1-indexed arrays.
  T *ap = new T[N/2] - 1;
  T *bp = new T[N/2] - 1;

  // Copy initial row data
  for (mwIndex k = 1; k <= N/2; ++k) { ap[k] = a[k]; bp[k] = b[k]; }

  for (int j = 0; j < Ngen; ++j) // Loop over generators.
    {
      int i = abs(ii[j]);
      if (ii[j] > 0)
        {
          if (i == 1)
            {
              bp[1] = sumg( a[1] , pos(b[1]) );
              ap[1] = sumg( -b[1] , pos(bp[1]) );
            }
          else if (i == n-1)
            {
              bp[n-2] = sumg( a[n-2] , neg(b[n-2]) );
              ap[n-2] = sumg( -b[n-2] , neg(bp[n-2]) );
            }
          else
            {
              T c = sumg(sumg(a[i-1],-a[i]) , sumg(-pos(b[i]),neg(b[i-1])));
              ap[i-1] = sumg(sumg(a[i-1],-pos(b[i-1])),-pos(sumg(pos(b[i]),c)));
              bp[i-1] = sumg( b[i] , neg(c) );
              ap[i] = sumg(sumg(a[i],-neg(b[i])),-neg(sumg(neg(b[i-1]),-c)));
              bp[i] = sumg( b[i-1] , -neg(c) );
            }
        }
      else if (ii[j] < 0)
        {
          if (i == 1)
            {
              bp[1] = sumg( -a[1] , pos(b[1]) );
              ap[1] = sumg( b[1] , -pos(bp[1]) );
            }
          else if (i == n-1)
            {
              bp[n-2] = sumg( -a[n-2] , neg(b[n-2]) );
              ap[n-2] = sumg( b[n-2] , -neg(bp[n-2]) );
            }
          else
            {
              T d = sumg(sumg(a[i-1], -a[i]) , sumg(pos(b[i]), -neg(b[i-1])));
              ap[i-1] = sumg(sumg(a[i-1],pos(b[i-1])),pos(sumg(pos(b[i]),-d)));
              bp[i-1] = sumg( b[i] , -pos(d) );
              ap[i] = sumg(sumg(a[i] , neg(b[i])) , neg(sumg(neg(b[i-1]) , d)));
              bp[i] = sumg( b[i-1] , pos(d) );
            }
        }
      for (mwIndex k = 1; k <= N/2; ++k) { a[k] = ap[k]; b[k] = bp[k]; }
    }

  delete[] (ap+1);
  delete[] (bp+1);
}

#endif // BRAIDLAB_UPDATE_RULES_HPP
