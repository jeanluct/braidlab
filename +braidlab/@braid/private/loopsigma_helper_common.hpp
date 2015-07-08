#ifndef BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP
#define BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP

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


////////////////// PREAMBLE  /////////////////////////

#include <functional>
#include <unordered_map>
#include <vector>
#include <algorithm>

#include "mex.h"
#include "update_rules.hpp"

int BRAIDLAB_debuglvl = -1; // set externally after the include

// real GCC feature list:
// https://gcc.gnu.org/projects/cxx0x.html
#if ( (defined __GNUC__) && (!defined __clang__) )

#define GCCVERSION (__GNUC__ * 10000            \
                    + __GNUC_MINOR__ * 100      \
                    + __GNUC_PATCHLEVEL__)

# if ( (!defined BRAIDLAB_NOTHREADING) &&           \
       ( GCCVERSION < 40600) ) // less than GCC 4.5
# define BRAIDLAB_NOTHREADING
# endif
#endif // gcc

// CLANG: feature list:
// http://clang.llvm.org/cxx_status.html
#if (defined __clang__)

#define CLANGVERSION (__clang_major__ * 10000   \
                      + __clang_minor__ * 100   \
                      + __clang_patchlevel__)

# if ( (!defined BRAIDLAB_NOTHREADING) &&               \
       (CLANGVERSION < 30300) ) // less than Clang 3.3
# define BRAIDLAB_NOTHREADING
# endif

#endif // clang

#ifndef BRAIDLAB_NOTHREADING
#include <mutex>
#include "ThreadPool.h" // (c) Jakob Progsch
                        // https://github.com/progschj/ThreadPool
#endif

////////////////// DECLARATIONS  /////////////////////////

template <class T>
class BraidInPlace {

public:

  BraidInPlace(mxArray *P_LOOP,
               const mxArray *P_SIGMA_IDX, mxArray *P_OPSIGN);

  BraidInPlace(T *T_LOOP, int T_LOOPS, int T_COORD,
               const mxArray *P_SIGMA_IDX,
               mxArray *P_OPSIGN);

  ~BraidInPlace();
  void run(size_t NThreadsRequested = 1);
  void applyToLoop(const mwIndex l);

private:

  void initOpSign(mxArray *P_OPSIGN);

  // storage
  T *loop;
  double *opSign;

  // are we storing opSign or not?
  const bool isOpSignUsed;

  // dimension of Dynnikov coordinate vector
  const mwSize Ncoord;

  // number of loops
  const mwSize Nloops;

  // number of punctures
  const mwSize Npunc;

  // number of generators in the braid
  const int Ngen;
  const int* sigma_idx;

  // array used for storage of operation signs on a single loop
  mxArray* P_OPSIGN1;
  int *opSign1;

  const mwSize maxopSign;

  typedef std::pair< std::vector<T>, std::vector<T> > tempAB;

  std::unordered_map< std::thread::id, tempAB > tmp;


};

//////////////////////////// DEFINITIONS  ////////////////////////////
template <class T>
BraidInPlace<T>::BraidInPlace(mxArray *P_LOOP,
                const mxArray *P_SIGMA_IDX,
                mxArray *P_OPSIGN) :
  //initializer lists
  loop( static_cast<T *>(mxGetData(P_LOOP)) ),
  opSign(NULL),
  isOpSignUsed(P_OPSIGN != NULL),
  Ncoord(mxGetM(P_LOOP)),
  Nloops(mxGetN(P_LOOP)),
  Npunc(mxGetM(P_LOOP)/2 + 2),
  Ngen(mxGetNumberOfElements(P_SIGMA_IDX)),
  sigma_idx( static_cast<const int *>(mxGetData(P_SIGMA_IDX)) ),
  opSign1(NULL),
  maxopSign(5){

  initOpSign(P_OPSIGN);
}

template <class T>
BraidInPlace<T>::BraidInPlace(T *T_LOOP, int T_LOOPS, int T_COORD,
                const mxArray *P_SIGMA_IDX,
                mxArray *P_OPSIGN) :
  //initializer lists
  loop( T_LOOP ),
  opSign(NULL),
  isOpSignUsed(P_OPSIGN != NULL),
  Ncoord(T_COORD),
  Nloops(T_LOOPS),
  Npunc(T_COORD/2 + 2),
  Ngen(mxGetNumberOfElements(P_SIGMA_IDX)),
  sigma_idx( static_cast<const int *>(mxGetData(P_SIGMA_IDX)) ),
  opSign1(NULL),
  maxopSign(5){

  initOpSign(P_OPSIGN);
}

template <class T>
void BraidInPlace<T>::initOpSign(mxArray *P_OPSIGN) {

  if (Ncoord % 2 != 0)
    mexErrMsgIdAndTxt("BRAIDLAB:loopsigma_helper:badarg",
                      "input loop coordinates should have an"
                      "even number of columns.");

  // If P_OPSIGN has been allocated, we'll record the pos/neg operations.
  if (isOpSignUsed) {
    mwSize dims[2] = {maxopSign*Ngen,1};
    P_OPSIGN1 = mxCreateNumericArray( 2, dims, mxINT32_CLASS, mxREAL );
    opSign1 = static_cast<int *>(mxGetData(P_OPSIGN1));
    opSign = mxGetPr(P_OPSIGN);
  }
}

template <class T>
BraidInPlace<T>::~BraidInPlace( ) {

  if (isOpSignUsed && P_OPSIGN1 != NULL)
    mxDestroyArray(P_OPSIGN1);

}

template <class T>
void BraidInPlace<T>::applyToLoop(const mwIndex l) {

  // Create 1-indexed pointers to the appropriate place
  T* a = &loop[l*Ncoord];
  T* b = &loop[Ncoord/2+l*Ncoord];
  a--;
  b--;

  // retrieve temporary storage based on thread ID
#ifndef BRAIDLAB_NOTHREADING
  tempAB& mytmp = tmp[std::this_thread::get_id()];
#else
  tempAB& mytmp = tmp[0];
#end

  if (mytmp.first.empty())
    mytmp.first.resize(Ncoord/2);
  if (mytmp.second.empty())
    mytmp.second.resize(Ncoord/2);

  // create 1-indexed temporary pointers
  T* a_tmp = mytmp.first.data() - 1;
  T* b_tmp = mytmp.second.data() - 1;

  // Act with the braid sequence in sigma_idx onto the coordinates a,b.
  update_rules<T>(Ngen, Npunc, sigma_idx, a, b,
                  a_tmp, b_tmp, opSign1);

  // Copy the pos/neg results to output array.
  if (isOpSignUsed) {
    for (mwIndex k = 0; k < maxopSign; ++k) {
      for (mwIndex j = 0; j < Ngen; ++j) {
        opSign[k*Ngen*Nloops + j*Nloops + l] = static_cast<double>(opSign1[k*Ngen + j]);
      }
    }
  }
}

template <class T>
void BraidInPlace<T>::run(size_t NThreadsRequested) {

#ifndef BRAIDLAB_NOTHREADING
  // restrict the number of threads if there are less jobs than available
  // threads
  NThreadsRequested = NThreadsRequested > Nloops ? Nloops : NThreadsRequested;
#else
  NThreadsRequested = 1;
#endif
  if ( NThreadsRequested == 0 ) {
    mexErrMsgIdAndTxt("BRAIDLAB:braid:colorbraiding:numthreadsnotpositive",
                      "Number of threads requested must be positive");
  }

  // unthreaded version
  if (NThreadsRequested == 1) {
    if (1 <= BRAIDLAB_debuglvl)  {
      printf("loopsigma_helper: multiplication running UNTHREADED.\n" );
      mexEvalString("pause(0.001);"); //flush
    }
    for (mwIndex l = 0; l < Nloops; ++l) {
      applyToLoop(l);
    }
  }
#ifndef BRAIDLAB_NOTHREADING
  else {   // threaded version
    if (1 <= BRAIDLAB_debuglvl)  {
      printf("loopsigma_helper: multiplication running THREADED (%d threads).\n",
             NThreadsRequested);
      mexEvalString("pause(0.001);"); //flush
    }
    // scheduler for threads
    ThreadPool pool(NThreadsRequested); // (c) Jakob Progsch

    // std::bind creates a function reference to a member function
    // needed here b/c passing references to member functions
    // requires explicit object to be referred
    auto funApplyToLoop = std::bind(&BraidInPlace<T>::applyToLoop,
                                    this, std::placeholders::_1);

    for (mwIndex l = 0; l < Nloops; ++l) {
      pool.enqueue( funApplyToLoop, l);
    }
  }
#endif
}


#endif // BRAIDLAB_LOOPSIGMA_HELPER_COMMON_HPP
