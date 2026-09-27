#ifndef __BRAID_H
#define __BRAID_H


#include "newarray.h"
#include "hshoe.h"
#include "types.h"

namespace trains {

class braid {
public:
	intarray Word;
	void Tighten() {Word.Tighten();}
	uint Strings;
	uint Size() {return Strings;}
	uint Length() {return static_cast<uint>(Word.TopIndex());}
	uint Permute(uint i); //Where does string i end up?
	BraidGenerator& operator[] (uint i) {return Word[i];}
	void Set(uint n, intarray W); //Sets n-braid from word W
	void Set(horseshoe& H); //Sets braid from horseshoe orbit collection
	friend std::ostream& operator << (std::ostream& Out, braid B);
	friend std::istream& operator >> (std::istream& In, braid& B);
}; 

} // namespace trains



#endif
