#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "braid.h"

namespace trains {

using namespace std;

ostream& operator << (ostream& Out, braid B)
{
	for (uint i=1; i<=B.Length(); i++)
	{
		if (i>1) Out << " ";
		Out << B[i];
	}
	return Out;
}

istream& operator >> (istream& In, braid& B)
{
	B.Word.Flush();
	cout << "Enter number of braid strings: ";
	In >> B.Strings;
	if (B.Strings<3) THROW("Braid should have at least three strings",0);
	cout << "Enter braid generators separated by spaces, ending with 0:\n";
	long Generator = 0;
	uint Index = 1;
	do
	{
		In >> Generator;
		if (Generator)
		{
			if ((Generator >= long(B.Strings)) || (Generator <= -long(B.Strings)))
				THROW("Illegal Braid generator",0);
			B[Index++] = Generator;
		}
	} while (Generator);
	B.Tighten();
	return In;
}

void braid::Set(uint n, intarray W)
{
	Strings = n;
	Word.Flush();
	long Generator;
	for (uint Index = 1; long(Index) <= W.TopIndex(); Index++)
	{
		Generator = W[Index];
		if (!Generator || (Generator >= long(n)) || (Generator <= -long(n)))
			THROW("Illegal Braid generator", 0);
		(*this)[Index] = Generator;
	}
	Tighten();
}


void braid::Set(horseshoe& H)
{
	Word.Flush();
	Strings = H.Permutation.TopIndex();
	bool OnWayDown = false;
	for (uint i=1; i<=Strings; i++)
	{
		if (OnWayDown)
			for (long j=i-1; j>=long(i+H.Permutation[i]-Strings); j--) Word.SureAdd(j);
		if (H.Permutation[i] == long(Strings)) OnWayDown = true;
	}
}

uint braid::Permute(uint i)
{
	if (i<1 || i>Strings) THROW("Illegal argument to braid::Permute", 0);
	uint CurrentPosition = i;
	for (uint Index = 1; static_cast<long>(Index) <= Word.TopIndex(); ++Index)
	{
		uint Generator  = static_cast<uint>( (Word[Index]>0) ? Word[Index] : -Word[Index]);
		if (CurrentPosition == Generator) ++CurrentPosition;
		else if (CurrentPosition == Generator+1) --CurrentPosition;
	}
	return CurrentPosition;
}

} // namespace trains
