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
    $Id: speedtest.cpp,v 1.1 2001/12/07 10:12:14 jccha Exp $
    Jae Choon Cha <jccha@knot.kaist.ac.kr>

    This is a speed test program for CBraid Library.
*/


#include <string>
#include <iostream>
#include <ctime>
#include <cmath>

#include "cbraid.h"
using namespace CBraid;
using namespace std;

#include "optarg.h"
#include "timecounter.h"


int Index = 100;
int CLength = 17;
int Count = 10;
bool bEncrypt = true;
bool bVerbose = false;
int RandomSeed;
double BlockSize, SecurityLevel;

void Encrypt()
{
    TimeCounter t;

    ArtinBraid x(Index), y(Index), z(Index), b1(Index), b2(Index);

    x.Randomize(CLength);
    y.Randomize(CLength);
    b1 = x;
    for(ArtinBraid::FactorItr i = b1.FactorList.begin();
        i != b1.FactorList.end(); ++i)
        i->Identity();
    b2 = b1;

	ArtinBraid::CanonicalFactor f(Index/2);

	t.Start();

	for(int n = 0; n < Count; ++n) {

		for(ArtinBraid::FactorItr i = b1.FactorList.begin(),
                j = b2.FactorList.begin();
			i != b1.FactorList.end();
			++i, ++j) {
			f.Randomize();
			for(int k = 1; k <= f.Index(); ++k)
				(*i)[k] = f[k];
			f.Randomize();
			for(int k = 1; k <= f.Index(); ++k)
				(*j)[k] = f[k];

		}
		z = b1;
		z.RightMultiply(x);
		z.RightMultiply(b2);
		z.MakeLCF();
		z = b1;
		z.RightMultiply(y);
		z.RightMultiply(b2);
		z.MakeLCF();
		flush(cout << ".");
	}

    t.Stop();

	cout << "\nExecution time=" << t.IntervalSec() << " sec, "
         << Count/t.IntervalSec() << " blocks/sec, "
         << BlockSize/8000*Count/t.IntervalSec() << " Kbytes/sec\n";
}

void Decrypt()
{
	std::clock_t t1, t2;

	ArtinBraid a1(Index), a2(Index);
	ArtinBraid c1(Index), c2(Index), z(Index), w(Index);
	a1.Randomize(CLength);
	a2.Randomize(CLength);
	ArtinBraid::CanonicalFactor f(Index/2);

	for(ArtinBraid::FactorItr i = a1.FactorList.begin(), j = a2.FactorList.begin();
		i != a1.FactorList.end();
		++i, ++j) {
		f.Randomize();
		for(int k = 1; k <= f.Index(); ++k)
			(*i)[k] = f[k];
		f.Randomize();
		for(int k = 1; k <= f.Index(); ++k)
			(*j)[k] = f[k];
	}
	c1.Randomize(CLength);
	c2.Randomize(CLength);

	t1 = clock();

	for(int n = 0; n < Count; ++n) {
		z = a1;
		z.RightMultiply(c1);
		z.RightMultiply(a2);
		w = !z;
		w.RightMultiply(c2);
		w.MakeLCF();
		// ((!(a1*c1*a2))*c2).MakeLCF();
		flush(cout << ".");
	}

	t2 = clock();

	cout << "\nExecution time=" << (double)(t2-t1)/CLOCKS_PER_SEC;
}


int main(int argc, char *argv[])
{
    // Process command line options.
    OptArg::optmap m;
    m << OptArg::opt("-n", OptArg::int_arg, &Index)
      << OptArg::opt("-l", OptArg::int_arg, &CLength)
      << OptArg::opt("-lndex", OptArg::int_arg, &Index)
      << OptArg::opt("-CLength", OptArg::int_arg, &CLength)
      << OptArg::opt("-encrypt", OptArg::bool_true_arg, &bEncrypt)
      << OptArg::opt("-decrypt", OptArg::bool_false_arg, &bEncrypt)
      << OptArg::opt("-count", OptArg::int_arg, &Count)
      << OptArg::opt("-verbose", OptArg::bool_true_arg, &bVerbose)
      << OptArg::opt("-srand", OptArg::int_arg, &RandomSeed);
    try {
        OptArg::process_option(argv+1, argv+argc, m);
    }
    catch (OptArg::bad_optarg_seq e) {
        cerr << "Bad argument: " << e.option_name << endl;
        exit(1);
    }

    // Report parameters.
    cout << "Encryption test, with parameters n=" << Index
         << ", l=" << CLength << ", count=" << Count << endl;

    // Compute the block size and security level from Index and CLength.
    double LogFactorial = 0;
    for(int i = 1; i <= Index; ++i)
        LogFactorial += log(i);
    LogFactorial /= log(2);
    BlockSize = LogFactorial*2*CLength;
    SecurityLevel = CLength*log(Index/2)/log(2);

    cout << "Block size=" << BlockSize/8000 << "Kbytes, Security level="
         << SecurityLevel << endl;

	if (bEncrypt)
		Encrypt();
	else
		Decrypt();
	return 0;
}
