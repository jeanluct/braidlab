//
// Matlab MEX file
//
// COMPACT   Shorten a braid word.
//

// Use the group relations to shorten a braid word as much as
// possible.

// The sort-and-cancel algorithm was ripped from the braid::braidword class.

#include <iostream>
#include <list>
#include <cassert>
#include "mex.h"

extern void _main();


// Delete two adjacent list entries specified by iterators.
// it1 and it2 still adjacent after deletion, and point to the next
// entries after the deleted ones.
template<class T>
inline
void delete_two(T& b, typename T::iterator& it1, typename T::iterator& it2)
{
  it1 = b.erase(it1,++it2);
  it2++ = it1;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;
  using std::max;

  // Arguments checked and formatted in compact.m.

  const mxArray *wA = prhs[0];
  const int *w = (int *)mxGetData(wA);
  const int N = max(mxGetM(wA),mxGetN(wA));

  // Convert braid word to list.
  std::list<int> bw;
  for (int i = 0; i < N; ++i) bw.push_back((int)w[i]);

  // First use the commutation relations to bring generators as far
  // left as possible.  Delete (sig)(-sig) sequences as we go.
  bool sw;
  do {
    sw = false;
    for (std::list<int>::iterator it1 = bw.begin(), it2 = ++(bw.begin());
	 it2 != bw.end(); ++it1, ++it2)
      {
	if (*it1 == -(*it2))
	  {
	    // Two adjacent generators cancel: eliminate them.
	    delete_two(bw,it1,it2);
	    sw = true;

	    if (it2 == bw.end()) break;
	  }
	else if (abs(abs(*it1) - abs(*it2)) > 1 && abs(*it1) > abs(*it2))
	  {
	    // Two adjacent generators commute: swap them.
	    std::swap(*it1,*it2);
	    sw = true;
	  }
      }
  } while (sw);

  // Then eventually try to apply the other rules.
  //
  // Suggestion: look for i -(i+1) -i and replace with
  //
  // i -(i+1) -i  =  i -(i+1)   -i   -(i+1) (i+1)
  //              =  i   -i   -(i+1)   -i   (i+1)
  //              =           -(i+1)   -i   (i+1)
  //
  // It doesn't change the length, but maybe then could lead to more
  // cancellations, once we've done everything we can with the
  // commutativity rule.
  //
  // Another option is to systematically list all shortening rules.

  // Now copy list bw to an mxArray of int32's.
  plhs[0] = mxCreateNumericMatrix(1,bw.size(),mxINT32_CLASS,mxREAL);
  int *bwp = (int *)mxGetData(plhs[0]);
  int k = 0;
  for (std::list<int>::const_iterator it = bw.begin();
       it != bw.end(); ++it, ++k)
    {
      bwp[k] = *it;
    }
}
