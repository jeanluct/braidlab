// MEX implementation of subbraid algorithm.

//
// <LICENSE
//   Braidlab: a Matlab package for analyzing data using braids
//
//   http://github.com/jeanluct/braidlab
//
//   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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


#include <utility>
#include "mex.h"

void printvector( const int *v, int L ) {
  for (size_t k = 0; k< L; k++) printf("%d ", v[k]);
  printf("\n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{


  const mxArray *p_braid = prhs[0];
  const mxArray *p_perm = prhs[1];
  const mxArray *p_keepstr = prhs[2];
  const mxArray *p_storeind = prhs[3];
  
  // Get debug level global variable.
  mxArray *dbglvl_ptr = mexGetVariable("global", "BRAIDLAB_debuglvl");
  int dbglvl = 0;
  if (dbglvl_ptr != NULL)
    if (mxGetM(dbglvl_ptr) != 0)
      dbglvl = (int)mxGetPr(dbglvl_ptr)[0];

  if (dbglvl >= 1)
    printf("Using MEX subbraid.\n");

  if (!mxIsInt32(p_braid) ||
      (mxGetM(p_braid) != 1) ) 
      mexErrMsgIdAndTxt("BRAIDLAB:braid:subbraid_helper:badarg",
                        "word should be int32 row-vectors.");

  if (!mxIsInt32(p_perm) ||
      (mxGetM(p_perm) != 1) ) 
      mexErrMsgIdAndTxt("BRAIDLAB:braid:subbraid_helper:badarg",
                        "perm should be int32 row-vectors.");

  if (!mxIsLogical(p_keepstr) ||
      (mxGetM(p_keepstr) != 1) ) 
      mexErrMsgIdAndTxt("BRAIDLAB:braid:subbraid_helper:badarg",
                        "keepstr should be logical row-vectors.");

  if (!mxIsLogicalScalar(p_storeind))
      mexErrMsgIdAndTxt("BRAIDLAB:braid:subbraid_helper:badarg",
                        "storeind should be logical scalar.");
  
  const int *word = (int *)mxGetData(p_braid); // braid word
  int *perm = (int *)mxGetData(p_perm); // store permutations
  mxLogical *keepstr = mxGetLogicals(p_keepstr); // is string kept?
  bool storeind = mxIsLogicalScalarTrue(p_storeind); // retain time

  // number of generators
  mwSize L = mxGetNumberOfElements( p_braid );
  mwSize N = mxGetNumberOfElements( p_perm );
  
  // create output braid of max length
  // output subbraid
  plhs[0] = mxCreateNumericMatrix(1,L,mxINT32_CLASS,mxREAL);
  int *bs = (int *)mxGetData(plhs[0]);

  plhs[1] = mxCreateNumericMatrix(1,L,mxINT32_CLASS,mxREAL);
  int *is;
  if (storeind)
    is = (int *)mxGetData(plhs[1]);

  mwIndex ind;
  int mygen;
  mwIndex bsL = 0;
  int sgen;

  
  // main algorithm loop
  // go through the full braid,
  // and infer if its generators reflect on kept strands,
  // and determine what subbraid generator should be
  for (mwIndex i = 0; i < L; i++) {
    // current generator
    mygen = word[i];

    // index of first strand in generator 
    ind = ( mygen >= 0 ? mygen : -mygen );

    if ( keepstr[ind-1] && keepstr[ind] ) {
      // find index of the strand in subset
      // of strands that is kept
      sgen = 0;
      for ( mwIndex n = 0; n < N; n++ ) {
        if ( !keepstr[n] ) {
          continue;
        }
        else {
          if ( perm[ind-1] == perm[n] ) {
            break;
          }
          else {
            sgen++;
          }
        }
      }

      // store subbraid generator and index of crossing
      // in matlab convention
      bs[bsL] = (int) ( mygen >= 0 ? (sgen+1) : -(sgen+1) );
      if (storeind)
        is[bsL] = (int) (i+1);
      bsL++;
    }

    // update permutation
    std::swap<int>( perm[ind-1], perm[ind] );
    std::swap<mxLogical>( keepstr[ind-1], keepstr[ind] );    
  }

  mxSetN( plhs[0], bsL );
  mxSetN( plhs[1], bsL );  

}


