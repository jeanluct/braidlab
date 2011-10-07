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
#include <vector>
#include <algorithm>
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


template<class T>
inline
bool sort_and_cancel(T& bw)
{
  // Use the commutation relations to bring generators as far left as
  // possible.  Delete (sig)(-sig) sequences as we go.
  bool sw, anysw = false;
  do {
    sw = false;
    for (typename T::iterator it1 = bw.begin(), it2 = ++(bw.begin());
	 it2 != bw.end(); ++it1, ++it2)
      {
	if (*it1 == -(*it2))
	  {
	    // Two adjacent generators cancel: eliminate them.
	    delete_two(bw,it1,it2);
	    sw = anysw = true;

	    if (it2 == bw.end()) break;
	  }
	else if (abs(abs(*it1) - abs(*it2)) > 1 && abs(*it1) > abs(*it2))
	  {
	    // Two adjacent generators commute: swap them.
	    std::swap(*it1,*it2);
	    sw = anysw = true;
	  }
      }
  } while (sw);

  return anysw;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;
  using std::max;
  typedef std::list<int>::iterator listit;

  // Arguments checked and formatted in compact.m.

  const mxArray *wA = prhs[0];
  const int *w = (int *)mxGetData(wA);
  const int N = max(mxGetM(wA),mxGetN(wA));
  int n = 1;

  // Convert braid word to list.
  /* Would it be faster to use a vector, and overwrite deleted
     generators with zeros? */
  std::list<int> bw;
  for (int i = 0; i < N; ++i)
    {
      n = max(n,abs((int)w[i])+1);
      bw.push_back((int)w[i]);
    }

  sort_and_cancel(bw);

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

#if 0
  for (int j = 0; j < 1; ++j) // Doing this a few times often helps.
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
	    listit it = std::search(bw.begin(),bw.end(),pat.begin(),pat.end());
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
