//
// Matlab MEX file
//
// COMPACT   Shorten a braid word.
//

// Use the group relations to shorten a braid word as much as
// possible.

// The sort-and-cancel algorithm was ripped from the braid::braidword class.

#include <iostream>
#include <vector>
#include <algorithm>
#include "mex.h"

extern void _main();


template<class T>
inline
bool sort_and_cancel(T& b)
{
  // Use the commutation relations to bring generators as far left as
  // possible.  Delete (sig)(-sig) sequences as we go.
  bool sw, anysw = false;
  do
    {
      sw = false;
      for (int i = 0; i < b.size()-1; ++i)
	{
	  if (b[i] == -b[i+1] && b[i] != 0)
	    {
	      // Two adjacent generators cancel: eliminate them.
	      b[i] = b[i+1] = 0;
	      ++i;
	      sw = anysw = true;
	    }
	  else if (abs(abs(b[i]) - abs(b[i+1])) > 1 && abs(b[i]) > abs(b[i+1]))
	    {
	      // Two adjacent generators commute: swap them.
	      std::swap(b[i],b[i+1]);
	      sw = anysw = true;
	    }
	}
      // remove 0's from the vector.
      b.erase(remove(b.begin(),b.end(),0),b.end());
    }
  while (sw && b.size() > 1);

  return anysw;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;
  using std::max;
  typedef std::vector<int>::iterator vecit;
  typedef std::vector<int>::const_iterator veccit;

  // Arguments checked and formatted in compact.m.

  const mxArray *wA = prhs[0];
  const int *w = (int *)mxGetData(wA);
  const int N = max(mxGetM(wA),mxGetN(wA));
  int n = 1;

  // Convert braid word to vector.
  std::vector<int> bw;
  for (int i = 0; i < N; ++i)
    {
      n = max(n,abs((int)w[i])+1);
      bw.push_back((int)w[i]);
    }

  sort_and_cancel(bw);

  //
  // Apply the orther relation, crudely.
  //

#define BRAIDLAB_MORE_COMPACT
#ifdef BRAIDLAB_MORE_COMPACT
  for (int j = 0; j < 2; ++j) // Doing this a few times often helps.
    {
      bool any;
      do {
	any = false;
	for (int i = 1; i <= n-2; ++i)
	  {
	    std::vector<int> pat(3);
	    pat[0] = i;
	    pat[1] = i+1;
	    pat[2] = i;
	    vecit it = std::search(bw.begin(),bw.end(),pat.begin(),pat.end());
	    if (it != bw.end())
	      {
		*(it++) = i+1;
		*(it++) = i;
		*(it) =   i+1;
		any = sort_and_cancel(bw);
	      }

	    pat[0] = -i;
	    pat[1] = -(i+1);
	    pat[2] = -i;
	    it = std::search(bw.begin(),bw.end(),pat.begin(),pat.end());
	    if (it != bw.end())
	      {
		*(it++) = -(i+1);
		*(it++) = -i;
		*(it) =   -(i+1);
		any = sort_and_cancel(bw);
	      }

	    pat[0] = i+1;
	    pat[1] = i;
	    pat[2] = i+1;
	    it = std::search(bw.begin(),bw.end(),pat.begin(),pat.end());
	    if (it != bw.end())
	      {
		*(it++) = i;
		*(it++) = i+1;
		*(it) =   i;
		any = sort_and_cancel(bw);
	      }

	    pat[0] = -(i+1);
	    pat[1] = -i;
	    pat[2] = -(i+1);
	    it = std::search(bw.begin(),bw.end(),pat.begin(),pat.end());
	    if (it != bw.end())
	      {
		*(it++) = -i;
		*(it++) = -(i+1);
		*(it) =   -i;
		any = sort_and_cancel(bw);
	      }
	  }
      } while (any);
    }
#endif

  // Now copy vector bw to an mxArray of int32's.
  plhs[0] = mxCreateNumericMatrix(1,bw.size(),mxINT32_CLASS,mxREAL);
  int *bwp = (int *)mxGetData(plhs[0]);
  int k = 0;
  for (veccit it = bw.begin(); it != bw.end(); ++it, ++k)
    {
      bwp[k] = *it;
    }
}
