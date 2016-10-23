//
// Matlab MEX file
//
// CFBRAID_HELPER   Left or right canonical form of a braid word.
//

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2016  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

#include <iostream>
#include <cmath>
#include <list>
#include "mex.h"
#include "braiding.h"


extern void _main();

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;

  // Arguments checked and formatted in cfbraid.m.

  const mxArray *wA = prhs[0];
  const int *w = (int *)mxGetData(wA); // wA contains int32's.
  const mwSize N = max(mxGetM(wA),mxGetN(wA));
  int n = (int)mxGetScalar(prhs[1]);
  int ityp = (int)mxGetScalar(prhs[2]);

  // Convert braid word to list.
  std::list<int> bw;
  for (mwIndex i = 0; i < N; ++i) bw.push_back(w[i]);

  CBraid::ArtinBraid B(Braiding::WordToBraid(bw,n));

  if (ityp == 0)
    {
      B.MakeLCF();
    }
  else
    {
      B.MakeRCF();
    }

#ifdef BRAIDLAB_MEX_DEBUG
  cout << endl << "The Left Normal Form is: " << endl << endl;
  Braiding::PrintBraidWord(B.MakeLCF());
  cout << endl;
  cout << "Factors in normal form:      " << B.FactorList.size() << endl;
#endif

  //
  // Create an output structure with three fields:
  //
  //  'type'    set to 'lcf' or 'rcf' to indicate the type of normal form;
  //  'delta'   the power of Delta;
  //  'factors' cell array of positive factors;
  //  'n'       number of strings in braid.
  //

  const char *keys[] = { "type", "delta", "factors", "n" };
  plhs[0] = mxCreateStructMatrix(1,1,4,keys);
  mxArray *factors = mxCreateCellMatrix(1,B.FactorList.size());
  if (ityp == 0)
    {
      mxSetFieldByNumber(plhs[0],0,0,mxCreateString("lcf"));
      mxSetFieldByNumber(plhs[0],0,1,mxCreateDoubleScalar(B.LeftDelta));
    }
  else
    {
      mxSetFieldByNumber(plhs[0],0,0,mxCreateString("rcf"));
      mxSetFieldByNumber(plhs[0],0,1,mxCreateDoubleScalar(B.RightDelta));
    }
  mxSetFieldByNumber(plhs[0],0,3,mxCreateDoubleScalar(n));
  mwIndex fac = 0;
  for(std::list<CBraid::ArtinFactor>::iterator it = B.FactorList.begin();
      it != B.FactorList.end(); ++it, ++fac)
    {
      // Extract the generators from each factor:
      // (see Juan's braiding.cpp)
      CBraid::ArtinFactor F = *it;
      std::list<int> wn;
      for (int i = 2; i <= n; ++i)
        {
          for (int j = i; j > 1 && F[j] < F[j-1]; --j)
            {
#ifdef BRAIDLAB_MEX_DEBUG
              cout << j-1 << " ";
#endif
              wn.push_back(j-1);
              std::swap(F[j],F[j-1]);
            }
        }
      // Now copy list wn to an mxArray.
      mxArray *wnA = mxCreateNumericMatrix(1,wn.size(),mxINT32_CLASS,mxREAL);
      int *wnp = (int *)mxGetPr(wnA);
      mwIndex k = 0;
      for (std::list<int>::const_iterator it2 = wn.begin();
           it2 != wn.end(); ++it2, ++k)
        {
          wnp[k] = *it2;
        }
      // And then assign this mxArray to a cell element.
      mxSetCell(factors,fac,wnA);
    }
  mxSetFieldByNumber(plhs[0],0,2,factors);
}
