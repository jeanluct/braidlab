#ifndef __BRAID_H
#define __BRAID_H

#include "array.h"
#include "hshoe.h"

namespace trains {

class braid {
public:
	intarray Word;
	void Tighten() {Word.Tighten();}
	uint Strings;
	uint Size() {return Strings;}
	uint Length() {return Word.TopIndex();}
	long& operator[] (uint i) {return Word[i];}
	void Set(uint n, intarray W); //Sets n-braid from word W
	void Set(horseshoe& H); //Sets braid from horseshoe orbit collection
	friend std::ostream& operator << (std::ostream& Out, braid B);
	friend std::istream& operator >> (std::istream& In, braid& B);
}; 



std::ostream& operator << (std::ostream& Out, braid B)
{
	for (uint i=1; i<=B.Length(); i++)
	{
		if (i>1) Out << " ";
		Out << B[i];
	}
	return Out;
}

std::istream& operator >> (std::istream& In, braid& B)
{
	B.Word.Flush();
	std::cout << "Enter number of braid strings: ";
	In >> B.Strings;
	if (B.Strings<3) THROW("Braid should have at least three strings",0);
	std::cout << "Enter braid generators separated by spaces, ending with 0:\n";
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


}

#endif
