//
// Matlab MEX file
//
// TRAIN_HELPER
//

// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   https://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2025  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
//                            Marko Budisic          <mbudisic@gmail.com>
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
//   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
// LICENSE>

// Helper file for train.m.

#include <iostream>
#include <sstream>
#include <string>
#include <cstring>
#include <cassert>
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
  using std::vector;

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

  // Reset tolerance.
  // Matlab remembers the value of globals!
  // So subsequent calls to train start at too high a tolerance.
  // This is yet another reason why globals are bad.
  // See issue #152.
  trains::TOL = STARTTOL;

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
  const int nfields = 4;    // number of fields
  int field = 0;

  // Field names.
  std::string fieldnames_string[nfields] =
    {"tntype","entropy","transmat","ttmap"};

  // Allocate field names, copy strings over.
  const int MAXCHARS = 20;  // maximum characters in each field (terrible)
  const char *fieldnames[nfields];
  for (int i = 0; i < nfields; ++i)
    {
      fieldnames[i] = (char *)mxMalloc(MAXCHARS);
      std::memcpy((void *)fieldnames[i],
                  fieldnames_string[i].c_str(),
                  fieldnames_string[i].length()+1);
    }

  // Create a 1x1 Matlab structure.
  plhs[0] = mxCreateStructMatrix(1,1,nfields,fieldnames);

  // Copy TN type, entropy to fields.
  mxArray *wtntype = mxCreateString(type.c_str());
  mxArray *wentropy = mxCreateDoubleScalar(log(dil));
  mxSetFieldByNumber(plhs[0],0,field++,wtntype);
  mxSetFieldByNumber(plhs[0],0,field++,wentropy);

  // Find transition matrix.
  // Output in raw format, do not show infinitesimal edges (false).
  vector<std::string> M = G.TransitionMatrix(trains::raw,false);
  // Copy rows (strings) to a Matlab matrix.
  const int nedges = M.size();
  mxArray *wtransmat = mxCreateDoubleMatrix(nedges,nedges,mxREAL);
  double *transmat = (double *)mxGetPr(wtransmat);
  for (int i = 0; i < nedges; ++i)
    {
      std::stringstream rowss(M[i]);
      for (int j = 0; j < nedges; ++j)
	{
	  if (!(rowss >> transmat[i + nedges*j]))
	    {
	      mexErrMsgIdAndTxt("BRAIDLAB:braid:train_helper:badrow",
				"Row %d has %d columns "
				"(needs %d).",i+1,j,nedges);
	    }
	}
      int num;
      if (rowss >> num)
	{
	  mexErrMsgIdAndTxt("BRAIDLAB:braid:train_helper:badrow",
			    "Row %d has more than %d columns."
			    ,i+1,nedges);
	}
    }
  // Attach Matlab matrix to field.
  mxSetFieldByNumber(plhs[0],0,field++,wtransmat);

  // Find the train track map.
  trains::edgeiterator J(G.Edges);
  // Store as vector of vectors.
  // ttmap[i] will give a vector of signed image edges.
  // Infinitesimal edges are listed first.
  vector<vector<int>> ttmap;
  // Loop over all edges, infinitesimal and main.
  do
    {
      trains::intiterator I(J.Now().Image);
      vector<int> ttmaprow;
      // Loop over image edges.
      do
	{
	  // Add edge to vector.
	  ttmaprow.push_back(I.Now());
	  I++;
	}
      while (!I.AtOrigin());
      // Add image vector for this edge.
      ttmap.push_back(ttmaprow);
      J++;
    }
  while (!J.AtOrigin());

  // Store as ttmap as cell array of vectors.
  mxArray *wttmap = mxCreateCellMatrix(ttmap.size(),1);
  for (int i = 0; i < ttmap.size(); ++i)
    {
      mxArray *wrow = mxCreateDoubleMatrix(1,ttmap[i].size(),mxREAL);
      double *row = (double *)mxGetPr(wrow);
      for (int j = 0; j < ttmap[i].size(); ++j)
        {
          row[j] = ttmap[i][j];
	}
      mxSetCell(wttmap,i,wrow);
    }
  // Attach Matlab cell array to field.
  mxSetFieldByNumber(plhs[0],0,field++,wttmap);

  assert(field == nfields);

  // Free memory for field names.  So 1995.
  for (int i = 0; i < nfields; ++i) mxFree((void *)fieldnames[i]);
}
