//
// Matlab MEX file
//
// TRAIN_HELPER
//

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2018  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic          <marko@clarkson.edu>
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

// Helper file for train.m.

#include <iostream>
#include <string>
#include <cstring>
#include "mex.h"
#include "trains/newarray.h"
#include "trains/braid.h"
#include "trains/graph.h"
trains::decimal trains::TOL = STARTTOL;
bool trains::GrowthCheck = true;

extern void _main();

//
// train_helper uses Toby Hall's "trains" code to find the isotopy class.
//
// Some braids fail: for example, the 9-string braid
//
// 6 -4 -7  2  3 -4 -8 -2  3 -6  3  7  3 -2 -5 -1 -4  2 -6  2 -3  7 -2 -4 -1 -8
//
// leads to a "growth not decreasing in fold" exception.  Even a
// decrease in TOL fails to resolve this.
//

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;
  using std::max;
  typedef std::vector<int>::iterator vecit;
  typedef std::vector<int>::const_iterator veccit;

  // Arguments checked and formatted in train.m.

  const mxArray *wA = prhs[0];
  const int *w = (int *)mxGetData(wA); // wA contains int32's.
  const mwSize N = max(mxGetM(wA),mxGetN(wA));
  const int n = (int)mxGetScalar(prhs[1]);

  // Convert braid word to vector.
  trains::intarray arr;
  trains::braid b;
  for (mwIndex i = 0; i < N; ++i)
    {
      arr.SureAdd((long)w[i]);
    }
  b.Set(n,arr);

  trains::graph G;
  G.Set(b);
  double dil;
  int tries = 1, maxtries = 2;
  do {
    try
      {
        dil = G.FindTrainTrack();
        break;
      }
    catch(trains::Error& E)
      {
        // Encountered exception... decrease tolerance and try again once.
        if (++tries > maxtries)
          {
            mexErrMsgIdAndTxt("BRAIDLAB:braid:train_helper:notdecr",
                              "Growth not decreasing in fold and "
                              "minimum tolerance of %.2Le reached.",
                              trains::TOL);
          }
        trains::TOL = 1e-14;
      }
    catch(...)
      {
        mexErrMsgIdAndTxt("BRAIDLAB:braid:train_helper:notdecr",
                          "Unknown exception occurred.");
      }
  } while (tries <= maxtries);

  std::string type;

  if (G.GetType() == trains::pA_or_red) G.FindTrack();

  if (G.GetType() == trains::pA)
    {
      type = "pseudo-Anosov";
    }
  else if (G.GetType() == trains::fo)
    {
      type = "finite-order";
    }
  else if (G.GetType() == trains::Reducible1)
    {
      type = "reducible1";
    }
  else if (G.GetType() == trains::Reducible2)
    {
      type = "reducible2";
    }
  else if (G.GetType() == trains::pA_or_red)
    {
      mexWarnMsgIdAndTxt("BRAIDLAB:braid:train_helper:pA_or_red",
                         "Ambiguous type.");
      type = "pA_or_reducible";
    }
  else
    {
      mexErrMsgIdAndTxt("BRAIDLAB:braid:train_helper:unknown",
                        "Unknown type.");
    }

  // Store result in a Matlab data structure.
  const int nfields = 2;    // number of fields

  // Field names.
  std::string strfnames[nfields] = {"tntype","entropy"};

  // Allocate field names, copy strings over.
  const int MAXCHARS = 20;  // maximum characters in each field (terrible)
  const char *fieldnames[nfields];
  for (int i = 0; i < nfields; ++i)
    {
      fieldnames[i] = (char *)mxMalloc(MAXCHARS);
      std::memcpy((void *)fieldnames[i],
		  strfnames[i].c_str(),
		  strfnames[i].length()+1);
    }

  plhs[0] = mxCreateStructMatrix(1,1,nfields,fieldnames);
  mxArray *wtntype = mxCreateString(type.c_str());
  mxArray *wentropy = mxCreateDoubleMatrix(1,1,mxREAL);
  *(mxGetPr(wentropy)) = log(dil);
  mxSetFieldByNumber(plhs[0],0,0,wtntype);
  mxSetFieldByNumber(plhs[0],0,1,wentropy);

  for (int i = 0; i < nfields; ++i) mxFree((void *)fieldnames[i]);
}
