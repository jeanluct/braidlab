#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include <string>
#include "hshoe.h"

namespace trains {

using namespace std;


codelist::codelist(uint s, uint d, uint o) : p(new code[s]), next(NULL), size(s), delta(d), origin(o), MaxAssigned(-1) {};


codelist::~codelist() {if (next) next->codelist::~codelist(); delete [] p;}

long codelist::TopIndex() {return MaxAssigned+long(origin);}

code& codelist::operator [](uint i)
{
	return Element(i-origin);
}

code& codelist::Element(uint i)
{
	if (i > MAXARRAYLENGTH) THROW("Array Index Out of Bounds", 1);
	if (long(i) >= MaxAssigned) MaxAssigned = long(i);
	if (i<size) return p[i];
	if (next) return next->Element(i-size);
	uint growby = (delta > i-size+1) ? delta : i-size+1;
	next = new codelist(growby, delta);
	if (!next) THROW("Out of Memory", 1);
	return next->Element(i-size);
}

uint codelist::GetSize()
{
	if (!next) return size;
	return size + next->GetSize();
}

void codelist::Flush()
{
	if (next)
	{
		next->Flush();
		next->codelist::~codelist();
	}
	next = NULL;
	MaxAssigned = -1;
}

codelist::codelist(codelist& A) : p(new code[A.GetSize()]),
next (NULL), size(A.GetSize()), delta(A.delta), origin(A.origin), MaxAssigned(A.MaxAssigned)
{
	for (uint i=0; long(i)<=A.MaxAssigned; i++) Element(i)=A.Element(i);
}

codelist& codelist::operator=(codelist& A)
{
	if (this == &A) return *this;
	Flush();
	MaxAssigned = -1;
	for (int i=0; i<=A.MaxAssigned; i++) Element(i) = A.Element(i);
	return *this;
}


long codelist::Find(code& Value)
{
	for (int i=0; i<=MaxAssigned; i++) if (Element(i) == Value) return (i+origin);
	return -1;
}

void codelist::_Remove(uint i, uint d)
{
	if (long(i+d) > MaxAssigned) THROW("Trying to remove non-existent elements",1);
	for (uint j=i+d+1; long(j)<=MaxAssigned; j++) Element(j-d-1)=Element(j);
	MaxAssigned -= (d+1);
}

void codelist::Remove(uint i, uint d)
{
	_Remove(i-origin, d);
}

void codelist::Append(codelist& A)
{
	for (uint i=0; long(i)<=A.MaxAssigned; i++)
		if (MaxAssigned == -1) Element(0) = A.Element(i);
		else Element(uint(MaxAssigned+1)) = A.Element(i);
}

void codelist::Prepend(codelist& A)
{
	long j = A.MaxAssigned;
	if (j==-1) return;
	for (long i=MaxAssigned; i>=0; i--)
		Element(uint(i+j+1)) = Element(uint(i));
	for (long i=0; i<=j; i++) Element(uint(i)) = A.Element(uint(i));
}


void codelist::_Split(uint i, codelist& A)
{
	if (long(i)>MaxAssigned) THROW("Trying to split after end of array",1);
	A.Flush();
	uint k=0;
	for (uint j=i+1; long(j)<=MaxAssigned; j++) A.Element(k++) = Element(j);
	MaxAssigned = long(i);
}


void codelist::Split(uint i, codelist& A)
{
	_Split(i-origin, A);
}

void codelist::Print(ostream& Out)
{
	for (uint i=0; long(i)<=MaxAssigned; i++) Out << Element(i) << " ";
	Out << '\n';
}



void codelist::Rotate(long Angle)
{
	if (MaxAssigned <= 0) return;
	codelist Temp = *this;
	long Modulus = MaxAssigned+1;
	for (long i=0; i<=MaxAssigned; i++)
	{                                                       
		long j= (i+Angle) % Modulus;
		if (j<0) j+=Modulus;                                   
		Element(uint(i))=Temp.Element(uint(j));
	}
}



void codelist::Insert(uint i, code& Value)
{
	for (uint j = TopIndex()+1; j>i; j--) (*this)[j] = (*this)[j-1]; 
	(*this)[i] = Value;
}


bool codelist::Agrees(uint i, codelist& A)
{
	if (MaxAssigned < long(i)-1 || A.MaxAssigned < long(i)-1) return false;
	for (uint j=0; j<i; j++) if (!(Element(j) == A.Element(j))) return false;
	return true;
}

bool codelist::Add(code Value)
{                                                                                 
	if (Find(Value) != -1) return false;
	Element(uint(MaxAssigned+1)) = Value;                                                  
	return true;
}                                                                                     

void codelist::SureAdd(code Value)
{
	Element(uint(MaxAssigned+1)) = Value;
}

uint codelist::AgreesTo(codelist& A)
{                                                         
	long Size = (MaxAssigned > A.MaxAssigned) ? A.MaxAssigned : MaxAssigned;
	uint i; for (i=0; long(i)<=Size; i++) if (!(Element(i) == A.Element(i))) return i;
	return i;                                                                  
}


bool code::operator <(code& C)
{
	uint i=1, j=1;
	int Parity = 0;
	bool Result = false;
	for (uint k=1; long(k)<=Length()*C.Length(); k++)
	{
		if (s[i] != C.s[j])
		{
			if (s[i]==Parity) Result = true;
			break;
		}
		if (s[i]==1) Parity = 1-Parity;
		i++; j++;
		if (long(i)>Length()) i = 1;
		if (long(j)>C.Length()) j = 1;
	}
	return Result;
}

bool code::operator ==(code& C)
{
	if (Length() != C.Length()) return false;
	for (uint i=1; long(i)<=Length(); i++) if (s[i] != C.s[i]) return false;
	return true;
}

istream& operator >> (istream& In, code& C)
{
	C.s.Flush();
	string s;
	In >> s;
	for (string::size_type i=0; i<s.length(); ++i)
	{
		if (s[i]!='0' && s[i]!='1') THROW("Illegal code symbol",0);
		if (s[i]=='0') C.s[i+1] = 0;
		else C.s[i+1] = 1;
	}
	return In;
}

ostream& operator << (ostream& Out, code C)
{
	for (uint i=1; long(i)<=C.Length(); i++) Out << C.s[i];
	return Out;
}


int horseshoe::FindPermutation()
{
	//Check that codes are non-repeating and distinct
	//First replace each code with its minimum translate
	uint i;
	for (i=1; i<=n; i++)
	{
		code &Now = L[i];
		code Current = Now;
		for (uint j=1; long(j)<Now.Length(); j++)
		{
			Current.s.Rotate(1);
			if (Current < Now) Now = Current;
			else if (Current == Now) return 0;;
		}
	}
	//Then check all codes are distinct
	for (i=1; i<n; i++) for (uint j=i+1; j<=n; j++)
		if (L[i] == L[j]) return 0;
	//Determine permutation INEFFICIENT
	Permutation.Flush();
	intarray Positions; //For points of orbits in order, gives position of code
	i=0;
	uint j;
	for (j=1; j<=n; j++)
	{
		code Now = L[j];
		for (uint k=1; long(k)<=L[j].Length(); k++)
		{
			i++; if (k>1) Now.s.Rotate(1);
			Positions[i] = 1;
			for (uint J=1; J<=n; J++)
			{
				code NOW = L[J];
				for (uint K=1; long(K)<=L[J].Length(); K++)
				{
					if (K>1) NOW.s.Rotate(1);
					if (j==J && k==K) continue;
					if (NOW<Now) Positions[i]++;
				}
			}
		}
	}
	uint Place = 1;
	for (i=1; i<=n; i++)
	{
		uint Start = Place;
		for (j=1; long(j)<=L[i].Length(); j++)
		{
			if (long(j)<L[i].Length()) Permutation[Positions[Place]] = Positions[Place+1];
			else Permutation[Positions[Place]] = Positions[Start];
			Place++;
		}
	}
	return 1;
}


istream& operator >> (istream& In, horseshoe& H)
{
	H.L.Flush();
	cout << "Number of orbits: ";
	In >> H.n;
	for (uint i=1; i<=H.n; i++)
	{
		cout << "Enter code of orbit " << i << ": ";
		In >> H.L[i];
	}
	H.FindPermutation();
	return In;
}

} // namespace trains
