/*
    Copyright (C) 2000-2001 Jae Choon Cha.

    This file is part of CBraid.

    CBraid is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    any later version.

    CBraid is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with CBraid; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/


/*
    $Id: test.cpp,v 1.1 2001/12/07 10:12:15 jccha Exp $
    Jae Choon Cha <jccha@knot.kaist.ac.kr>

    This is a test program for CBraid Library.
*/


#include "cbraid.h"
using namespace CBraid;
using namespace std;

#include "optarg.h"

#include <iostream>
#include <typeinfo>


// Global option variables.
int Index = 6;
int CLength = 5;
bool bVerbose = false;
int CLibRandomSeed = 0;

template<class T> const char* TypeName() { return "(Unknown)"; }
template<> const char* TypeName<ArtinBraid>() { return "ArtinBraid"; }
template<> const char* TypeName<BandBraid>() { return "BandBraid"; }


template<class B>
bool CFormMulTest(B& (B::*pMakeCForm)())
{
    B a(Index), b(Index), c(Index), d(Index);

    cout << "a=" << a.Randomize(CLength) << endl
        << "b=" << b.Randomize(CLength) << endl;
    cout << "CF(a*b)=" << ((c = a*b).*pMakeCForm)() << endl;
    cout << "CF(a)=" << (a.*pMakeCForm)() << endl
        << "CF(b)=" << (b.*pMakeCForm)() << endl;
    cout << "CF(LCF(a)*CF(b))=" << ((d = a*b).*pMakeCForm)() << endl;
    bool rc = (c == d);
    cout << (rc ? "\nPassed: " : "\nFailed: ")
         << (pMakeCForm == &B::MakeLCF ? "Left" : "Right")
         << " canonical form and multiplication test for "
         << TypeName<B>() << endl << endl << flush;
    return rc;
}

template <class B>
bool CFormInvTest(B& (B::*pMakeCForm)())
{
    B a(Index), b(Index), c(Index);

    cout << "a=" << a.Randomize(CLength) << endl;
    cout << "b=!a=" << (b = !a) << endl;
    cout << "CF(a*b)=" << ((c=a*b).*pMakeCForm)() << endl;
    bool rc = c.CompareWithIdentity();
    cout << (rc ? "\nPassed: " : "\nFailed: ")
         << (pMakeCForm == &B::MakeLCF ? "Left" : "Right")
         << " canonical form and inversion test for "
         << TypeName<B>() << endl << endl << flush;
    return rc;
}


template<class B>
bool LeftReductionTest(B (B::*pReduce)())
{
    B x(Index), y(Index), a(Index), b(Index), c(Index);

    bool rc = true;
    cout << "x=" << (y = x.Randomize(CLength).MakeLCF()) << endl;
    cout << "a=Left reduction of x=" << (a = (x.*pReduce)()) << endl;
    cout << "b=(!a)*x=" << (b = x) << endl;
    cout << "Left eduction of b=" << (c = (x.*pReduce)()) << endl;
    rc = rc && c.MakeLCF().CompareWithIdentity();
    cout << "a*b=" << (x = a*b).MakeLCF() << endl;
    rc = rc && (y == x);
    cout << (rc ? "\nPassed: " : "\nFailed: ")
         << "Left " << (pReduce == &B::ReduceLeftLower ? "lower" : "upper")
         << " reduction test for "
         << TypeName<B>() << endl << endl << flush;
    return rc;
}


template<class B>
bool RightReductionTest(B (B::*pReduce)())
{
    B x(Index), y(Index), a(Index), b(Index), c(Index);

    bool rc = true;
    cout << "x=" << (y = x.Randomize(CLength).MakeLCF()) << endl;
    cout << "a=Right reduction of x=" << (a = (x.*pReduce)()) << endl;
    cout << "b=x*(!a)=" << (b = x) << endl;
    cout << "Right reduction of b=" << (c = (x.*pReduce)()) << endl;
    rc = rc && c.MakeLCF().CompareWithIdentity();
    cout << "b*a=" << (x = b*a).MakeLCF() << endl;
    rc = rc && (y == x);
    cout << (rc ? "\nPassed: " : "\nFailed: ")
         << "Right " << (pReduce == &B::ReduceRightLower ? "lower" : "upper")
         << " reduction test for "
         << TypeName<B>() << endl << endl << flush;
    return rc;
}


bool ArtinBandConversionTest()
{
    ArtinBraid a(Index), b(Index);
    BandBraid p(Index), q(Index);

    cout << "a=" << a.Randomize(CLength) << endl;
    cout << "p=BAND(a)=" << (p = ToBandBraid(a)) << endl;
    cout << "b=ARTIN(p)=" << (b = ToArtinBraid(p)) << endl;
    bool rc = (a.MakeLCF() == b.MakeLCF());
    cout << "q=BAND(b)=" << (q = ToBandBraid(b)) << endl;
    rc = rc && (p.MakeLCF() == q.MakeLCF());
    cout << (rc ? "\nPassed" : "\nFailed") <<
    ": Artin-band conversion test\n" << flush;
    return rc;
}


int main(int argc, char* argv[])
{
    // Process command line options.
    OptArg::optmap m;
    m << OptArg::opt("-index", OptArg::int_arg, &Index)
      << OptArg::opt("-clength", OptArg::int_arg, &CLength)
      << OptArg::opt("-verbose", OptArg::bool_true_arg, &bVerbose)
      << OptArg::opt("-srand", OptArg::int_arg, &CLibRandomSeed);
    try {
        OptArg::process_option(argv+1, argv+argc, m);
    }
    catch (OptArg::bad_optarg_seq e) {
        cerr << "Bad argument: " << e.option_name << endl;
        exit(1);
    }

    if (CLibRandomSeed)
        srand(CLibRandomSeed);

    if (!CFormMulTest(&ArtinBraid::MakeLCF) ||
        !CFormInvTest(&ArtinBraid::MakeLCF) ||
        !CFormMulTest(&ArtinBraid::MakeRCF) ||
        !CFormInvTest(&ArtinBraid::MakeRCF) ||
        !CFormMulTest(&BandBraid::MakeLCF) ||
        !CFormInvTest(&BandBraid::MakeLCF) ||
        !CFormMulTest(&BandBraid::MakeRCF) ||
        !CFormInvTest(&BandBraid::MakeRCF) ||
        !LeftReductionTest(&ArtinBraid::ReduceLeftLower) ||
        !LeftReductionTest(&ArtinBraid::ReduceLeftUpper) ||
        !RightReductionTest(&ArtinBraid::ReduceRightLower) ||
        !RightReductionTest(&ArtinBraid::ReduceRightUpper) ||
        !LeftReductionTest(&BandBraid::ReduceLeftLower) ||
        !LeftReductionTest(&BandBraid::ReduceLeftUpper) ||
        !RightReductionTest(&BandBraid::ReduceRightLower) ||
        !RightReductionTest(&BandBraid::ReduceRightUpper) ||
        // !ArtinBandConversionTest() ||
        false)
        return 1;

    return 0;
}
