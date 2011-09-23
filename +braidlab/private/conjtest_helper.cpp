//
// Matlab MEX file
//
// CONJTEST   Conjugacy test for two braid words.
//

#include <iostream>
#include <cmath>
#include <list>
#include "mex.h"
#include "braiding.h"

using namespace std;

extern void _main();

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;

  // Arguments checked and formatted in conjtest.m.

  const mxArray *w1A = prhs[0];
  const double *w1 = mxGetPr(w1A);
  const int N1 = max(mxGetM(w1A),mxGetN(w1A));
  const mxArray *w2A = prhs[1];
  const double *w2 = mxGetPr(w2A);
  const int N2 = max(mxGetM(w2A),mxGetN(w2A));

  int n = (int)mxGetScalar(prhs[2]);

  // Convert braid words to list.
  std::list<int> bw1, bw2;
  for (int i = 0; i < N1; ++i) bw1.push_back((int)w1[i]);
  for (int i = 0; i < N2; ++i) bw2.push_back((int)w2[i]);

  CBraid::ArtinBraid B1(Braiding::WordToBraid(bw1,n));
  CBraid::ArtinBraid B2(Braiding::WordToBraid(bw2,n));
  CBraid::ArtinBraid C(1);

  B1.MakeLCF();
  B2.MakeLCF();

  bool conj = Braiding::AreConjugate(B1,B2,C);

  plhs[0] = mxCreateLogicalScalar(conj);

  /* This code is basically duplicated from canform. Make a library? */

  //
  // Create an output structure with three fields:
  //
  //  'type'    set to 'lcf' or 'rcf' to indicate the type of normal form;
  //  'delta'   the power of Delta;
  //  'factors' cell array of positive factors.
  //  'n'       order of braid group
  //

  if (C.LeftDelta == 0 && C.RightDelta != 0)
    {
      std::cerr << "conjtest_helper: The braid is in RCF.\n";
      exit(1);
    }

  const char *keys[] = { "type", "delta", "factors", "n" };
  plhs[1] = mxCreateStructMatrix(1,1,4,keys);
  mxArray *factors = mxCreateCellMatrix(1,C.FactorList.size());
  mxSetFieldByNumber(plhs[1],0,0,mxCreateString("lcf"));
  mxSetFieldByNumber(plhs[1],0,1,mxCreateDoubleScalar(C.LeftDelta));
  mxSetFieldByNumber(plhs[1],0,3,mxCreateDoubleScalar(n));
  int fac = 0;
  for(std::list<CBraid::ArtinFactor>::iterator it = C.FactorList.begin();
      it != C.FactorList.end(); ++it, ++fac)
    {
      // Extract the generators from each factor:
      // (see Juan's braiding.cpp)
      CBraid::ArtinFactor F = *it;
      std::list<int> wn;
      for (int i = 2; i <= n; ++i)
	{
	  for (int j = i; j > 1 && F[j] < F[j-1]; --j)
	    {
	      wn.push_back(j-1);
	      std::swap(F[j],F[j-1]);
	    }
	}
      // Now copy list wn to an mxArray.
      mxArray *wnA = mxCreateDoubleMatrix(1,wn.size(),mxREAL);
      double *wnp = mxGetPr(wnA);
      int k = 0;
      for (std::list<int>::const_iterator it2 = wn.begin();
	   it2 != wn.end(); ++it2, ++k)
	{
	  wnp[k] = *it2;
	}
      // And then assign this mxArray to a cell element.
      mxSetCell(factors,fac,wnA);
    }
  mxSetFieldByNumber(plhs[1],0,2,factors);
}
