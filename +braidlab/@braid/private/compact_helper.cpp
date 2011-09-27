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

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;
  using std::max;

  // Arguments checked and formatted in compact.m.

  const mxArray *wA = prhs[0];
  const double *w = mxGetPr(wA);
  const int N = max(mxGetM(wA),mxGetN(wA));

  const mxArray *tA = prhs[1];
  const double *tp = mxGetPr(tA);
  bool dotimes = true;
  if (mxIsEmpty(tA)) dotimes = false;

  // Convert braid word to list.
  std::list<int> bw;
  for (int i = 0; i < N; ++i) bw.push_back((int)w[i]);

  std::list<double> t;
  if (dotimes)
    {
      for (int i = 0; i < N; ++i) t.push_back(tp[i]);
    }

  // First use the commutation relations to bring generators as far
  // left as possible.  Delete (sig)(-sig) sequences as we go.
  bool sw;
  do {
    sw = false;
    std::list<double>::iterator itt1 = t.begin(), itt2 = ++(t.begin());
    for (std::list<int>::iterator it1 = bw.begin(), it2 = ++(bw.begin());
	 it2 != bw.end(); ++it1, ++it2, ++itt1, ++itt2)
      {
	if (*it1 == -(*it2))
	  {
	    // Two adjacent generators cancel: eliminate them.
	    it1 = bw.erase(it1,++it2);
	    it2++ = it1;
	    sw = true;

	    if (dotimes)
	      {
		// Also erase the times.
		itt1 = t.erase(itt1,++itt2);
		itt2++ = itt1;
	      }

	    if (it2 == bw.end()) break;
	  }
	else if (abs(abs(*it1) - abs(*it2)) > 1 && abs(*it1) > abs(*it2))
	  {
	    // Two adjacent generators commute: swap them.
	    std::swap(*it1,*it2);
	    sw = true;

	    // We don't swap the times, to keep them chronological.
	  }
      }
  } while (sw);

  if (dotimes) assert(bw.size() == t.size());

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

  // Now copy list bw to an mxArray.
  plhs[0] = mxCreateDoubleMatrix(1,bw.size(),mxREAL);
  double *bwp = mxGetPr(plhs[0]);
  int k = 0;
  for (std::list<int>::const_iterator it = bw.begin();
       it != bw.end(); ++it, ++k)
    {
      bwp[k] = *it;
    }

  // Create empty matrix of times.
  plhs[1] = mxCreateDoubleMatrix(1,t.size(),mxREAL);
  if (dotimes)
    {
      double *tpp = mxGetPr(plhs[1]);
      int k = 0;
      for (std::list<double>::const_iterator it = t.begin();
	   it != t.end(); ++it, ++k)
	{
	  tpp[k] = *it;
	}
    }
}
