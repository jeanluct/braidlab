//
// Matlab MEX file
//
// TNTYPE_HELPER
//

// Helper file for tntype.m.

#include <iostream>
#include <string>
#include "mex.h"
#include "trains/newarray.h"
#include "trains/braid.h"
#include "trains/graph.h"
trains::decimal trains::TOL = STARTTOL;
bool trains::GrowthCheck = true;

extern void _main();

//
// tntype_helper uses Toby Hall's "trains" code to find the isotopy class.
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

  // Arguments checked and formatted in tntype.m.

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
            mexErrMsgIdAndTxt("BRAIDLAB:braid:tntype_helper:notdecr",
                              "Growth not decreasing in fold and "
                              "minimum tolerance of %.2Le reached.",
                              trains::TOL);
          }
        trains::TOL = 1e-14;
      }
    catch(...)
      {
        mexErrMsgIdAndTxt("BRAIDLAB:braid:tntype_helper:notdecr",
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
      mexWarnMsgIdAndTxt("BRAIDLAB:braid:tntype_helper:pA_or_red",
                         "Ambiguous type.");
      type = "pA_or_reducible";
    }
  else
    {
      mexErrMsgIdAndTxt("BRAIDLAB:braid:tntype_helper:unknown",
                        "Unknown type.");
    }

  plhs[0] = mxCreateString(type.c_str());

  if (nlhs > 1)
    {
      // Also return the diltation.
      plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
      *(mxGetPr(plhs[1])) = log(dil);
    }
}
