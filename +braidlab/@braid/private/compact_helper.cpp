//
// Matlab MEX file
//
// COMPACT   Shorten a braid word.
//

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

// Use the group relations to shorten a braid word as much as
// possible.

// The commute-and-cancel algorithm is from Bangert et al. (2002).

#include <iostream>
#include <vector>
#include <algorithm>
#include "mex.h"

// #undef BRAIDLAB_BANGERT_RESTORE
// #undef BRAIDLAB_COMPACT_DEBUG

extern void _main();


#ifdef BRAIDLAB_COMPACT_DEBUG
// Print a vector (only needed in debug mode).
void printvec(const std::vector<int>& b)
{
  if (b.empty()) return;
  for (int k = 0; k < b.size()-1; ++k) std::cerr << b[k] << " ";
  std::cerr << b.back() << std::endl;
}
#endif


//
// "Commute-and-cancel" is described succinctly in Bangert et
// al. (2002), p. 52; for a braid A,
//
//   "We begin with the leftmost generator of A and attempt to move it
//   to the right using both braid group operations. If we can cancel
//   it along the way, we do so and if we cannot, we move it back to
//   where it started. In this way, we proceed to move all the
//   generators as far to the right as possible. Then we begin at the
//   end and move each generator as far to the left as possible in the
//   same manner."
//
// It isn't completely clear to me what moving a generator using the
// second relation actually means.  In the implementation below, while
// moving to the right a sequence such as 121 is turned into 212, and
// the "position" is updated from the first 1 of 121 to the final 2 of
// 212.
//
// I also don't see the point of moving the generator back to where it
// started.  It works faster (and even better) to just leave it there.
// This behavior is controlled by BRAIDLAB_BANGERT_RESTORE.
//

template<class T>
inline
bool commute_and_cancel(T& b, const int dir, const int n,
                        const bool secndrel, const bool annular)
{
#ifdef BRAIDLAB_COMPACT_DEBUG
  using std::cerr;
  using std::endl;
#endif
  if (b.size() < 2) return false;

  bool shorter = false;
  bool badrel = false;
  mwIndex pos0 = 0; // pos0 is the starting point of the "current" generator.
  do
    {
      bool incrpos = false;
      // dir=1 means start from the beginning, dir=-1 from the end.
      mwIndex i = (dir == 1 ? pos0 : b.size()-1-pos0);
#ifdef BRAIDLAB_COMPACT_DEBUG
      cerr << "Position i = " << i << endl;
#endif
#ifdef BRAIDLAB_BANGERT_RESTORE
      T b0(b);      // Save the braid.
#endif
      do
        {
          if (i > 0)
            {
              if (b[i-1] == -b[i] && b[i] != 0)
                {
                  // Cancel with the generator on the left.
#ifdef BRAIDLAB_COMPACT_DEBUG
                  cerr << "Cancelling adjacent generators at position ";
                  cerr << i-1 << " and " << i << endl;
                  cerr << "before: "; printvec(b);
#endif
                  b[i-1] = b[i] = 0;
#ifdef BRAIDLAB_COMPACT_DEBUG
                  cerr << " after: "; printvec(b);
#endif
                  shorter = true;
                  break;
                }
            }
          if (i < b.size()-1)
            {
              if (b[i+1] == -b[i] && b[i] != 0)
                {
                  // Cancel with the generator on the right.
#ifdef BRAIDLAB_COMPACT_DEBUG
                  cerr << "Cancelling adjacent generators at position ";
                  cerr << i << " and " << i+1 << endl;
                  cerr << "before: "; printvec(b);
#endif
                  b[i+1] = b[i] = 0;
#ifdef BRAIDLAB_COMPACT_DEBUG
                  cerr << " after: "; printvec(b);
#endif
                  shorter = true;
                  break;
                }
            }
          if (annular)
            {
              // Omit commutation relation involving strings 1 and n-1
              // for an annular braid.
              badrel =
                (abs(b[i]) == 1 && abs(b[i+dir]) == n-1) ||
                (abs(b[i]) == n-1 && abs(b[i+dir]) == 1);
#ifdef BRAIDLAB_COMPACT_DEBUG
              if (badrel)
                cerr << "Omitting annular commutation relation.\n";
#endif
            }
          if (abs(abs(b[i]) - abs(b[i+dir])) > 1 && !badrel)
            {
              // Commute with the next generator.
#ifdef BRAIDLAB_COMPACT_DEBUG
              cerr << "Commuting adjacent generators at position ";
              cerr << i << " and " << i+dir << endl;
              cerr << "before: "; printvec(b);
#endif
              std::swap(b[i],b[i+dir]);
#ifdef BRAIDLAB_COMPACT_DEBUG
              cerr << " after: "; printvec(b);
#endif
              i += dir;
              incrpos = true;
              continue;
            }
          if ((int)i+2*dir >= 0 && (int)i+2*dir <= (int)b.size()-1 && secndrel)
            {
              // Try the second type of relation.
              if ((b[i]+1 == b[i+dir] || b[i]-1 == b[i+dir])
                  && b[i] == b[i+2*dir])
                {
#ifdef BRAIDLAB_COMPACT_DEBUG
                  cerr << "Using second relation at position ";
                  cerr << i << "," << i+dir << "," << i+2*dir << endl;
                  cerr << "before: "; printvec(b);
#endif
                  if (annular)
                    {
                      // Omit braid relation involving n-1 for an
                      // annular braid.
                      badrel =
                        (abs(b[i]) == n-1 ||
                         abs(b[i+dir]) == n-1 ||
                         abs(b[i+2*dir] == n-1));
#ifdef BRAIDLAB_COMPACT_DEBUG
                      if (badrel)
                        cerr << "Omitting annular braid relation.\n";
#endif
                    }
                  if (!badrel)
                    {
                      std::swap(b[i],b[i+dir]);
                      b[i+2*dir] = b[i];
                    }
#ifdef BRAIDLAB_COMPACT_DEBUG
                  cerr << " after: "; printvec(b);
#endif
                  i += 2*dir;
                  incrpos = true;
                  continue;
                }
            }
          // Nothing happened: break out of the loop to increase pos0
          // and try again.
#ifdef BRAIDLAB_BANGERT_RESTORE
          b = b0;   // Restore braid, so generator moves back to its
                    // initial position.
#endif
          incrpos = true;
          break;
        } while ((int)i+dir >= 0 && (int)i+dir <= (int)b.size()-1);
      // remove 0's from the vector.
      b.erase(remove(b.begin(),b.end(),0),b.end());
      if (b.size() < 2) break;
      if (incrpos) ++pos0;
    } while (pos0 < b.size()-1);

  return shorter; // true if actually shorter than upon entry.
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;
  using std::max;
  typedef std::vector<int>::iterator vecit;
  typedef std::vector<int>::const_iterator veccit;

  // Arguments checked and formatted in compact.m.

#ifdef BRAIDLAB_COMPACT_DEBUG
  std::cerr << "Entering compact_helper...\n";
#endif

  if ( nrhs < 1 )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:compact:badargument",
                      "Not enough arguments");

  const mxArray *wA = prhs[0];

  if ( !mxIsInt32(wA) && !mxIsEmpty(wA) )
    mexErrMsgIdAndTxt("BRAIDLAB:braid:compact:badargument",
                      "Argument should be a non-empty vector of int32");

#ifdef BRAIDLAB_COMPACT_DEBUG
  std::cerr << "Dimensions are " << mxGetM(wA) << "," << mxGetN(wA) << std::endl;
#endif

  const mwSize N = max(mxGetM(wA),mxGetN(wA));
  const int *w = (int *)mxGetData(wA); // wA contains int32's.

  // The number of strings.
  const int n = (int)mxGetScalar(prhs[1]);
  // Third argument determines whether this is an annular braid.
  const int annular = (int)mxGetScalar(prhs[2]);

  // Convert braid word to vector.
  std::vector<int> bw;
  for (mwIndex i = 0; i < N; ++i)
    {
      bw.push_back(w[i]);
    }

  // Try to commute_and_cancel from the left/right until nothing changes.
  // Omit the second type (three-string) of braid relations.
  while (commute_and_cancel(bw,1,n,false,annular) ||
         commute_and_cancel(bw,-1,n,false,annular)) {}

  // Try to commute_and_cancel from the left/right until nothing changes.
  while (commute_and_cancel(bw,1,n,true,annular) ||
         commute_and_cancel(bw,-1,n,true,annular)) {}

  // Now copy vector bw to an mxArray of int32's.
  plhs[0] = mxCreateNumericMatrix(1,bw.size(),mxINT32_CLASS,mxREAL);
  int *bwp = (int *)mxGetData(plhs[0]);
  mwIndex k = 0;
  for (veccit it = bw.begin(); it != bw.end(); ++it, ++k)
    {
      bwp[k] = *it;
    }
}
