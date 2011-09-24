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
#include "mex.h"

extern void _main();

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;
  using std::max;

  // Arguments checked and formatted in compact.m.

  const mxArray *wA = prhs[0];
  const double *w = mxGetPr(wA);
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
	    it1 = bw.erase(it1,++it2);
	    it2++ = it1;
	    sw = true;
	    if (it2 == bw.end()) break;
	  }
	else if (abs(abs(*it1) - abs(*it2)) > 1 && abs(*it1) > abs(*it2))
	  {
	    std::swap(*it1,*it2);
	    sw = true;
	  }
      }
  } while (sw);

  // Then eventually try to apply the other rules.
  //  ...

  // Now copy list bw to an mxArray.
  plhs[0] = mxCreateDoubleMatrix(1,bw.size(),mxREAL);
  double *bwp = mxGetPr(plhs[0]);
  int k = 0;
  for (std::list<int>::const_iterator it = bw.begin();
       it != bw.end(); ++it, ++k)
    {
      bwp[k] = *it;
    }
}
