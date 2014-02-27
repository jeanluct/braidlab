#ifndef __HSHOE_H
#define __HSHOE_H

#include "General.h"
#include "newarray.h"


namespace trains {

class code {
	friend class horseshoe;
public:
	intarray s; //Symbols
	bool operator <(code& C);
	bool operator >(code& C) {return (C < *this);}
	bool operator ==(code& C);
	bool operator !=(code& C) {return !(*this == C);}
	code operator -() {THROW("Calling dummy operator -",4); return (*this);}
	long Length() {return s.TopIndex();}
	friend std::ostream& operator << (std::ostream& Out, code C);
	friend std::istream& operator >> (std::istream& In, code& C);
};


class codelist {
	friend class graph;
	friend class edge;
	friend class vertex;
	friend class code;
	code* p;
	codelist* next;  /*pointer to continuation of array*/
	uint size;
	uint delta;
	uint origin;
	long MaxAssigned; /* Maximum index accessed (origin at 0)*/
	code& Element(uint i);  /* Origin at 0 */
	void _Remove(uint i, uint d=0); /* Removes elements in Positions i to i+d (origin 0) and shifts down.*/
	void _Split(uint i, codelist& A); /*Splits after position i (origin 0) and places tail in A*/
public:
	codelist(uint s = ARRAYSIZ, uint d = ARRAYDELTA, uint o=1);
	codelist(codelist& A);
	~codelist();
	codelist& operator=(codelist& A);
	code& operator [](uint i);
	uint GetSize(); /* returns space allocated */
	uint GetOrigin() {return origin;}
	bool Add(code Value); /*Adds Value to end of array and returns true if not already somewhere in it*/
	void SureAdd(code Value); /*Adds Value to end of array*/
	void Flush(); /*restores to original size*/
	long Find(code& Value); /*returns index containing value if found, -1 else*/
	long TopIndex();
	void Remove(uint i, uint d=0);/* Removes elements in Positions i to i+d  and shifts down.*/
	void Append(codelist& A); /* Appends A*/
	void Prepend(codelist& A);
	void Insert(uint i, code& Value); /*Array[i] = value, all others shifted up*/
	void Split(uint i, codelist& A); /*Splits after position i and places tail in A*/
	void Print(std::ostream& Out = std::cout);
	void Rotate(long Angle=1); /*NewArray[i] = Array[i+Angle] (mod MaxAssigned+1)*/
	bool Agrees(uint i, codelist& A);/*Tests if agrees with A on first i entries*/
	uint AgreesTo(codelist& A); /*Returns number of symbols to which the two agree  */
};

class horseshoe {
	friend class braid;
public:
	uint n; //Number of orbits
	codelist L;
	intarray Permutation; //Stores permutation corresponding to codes
	int FindPermutation();
	friend std::istream& operator >> (std::istream& In, horseshoe& H);
};

} // namespace trains

#endif
