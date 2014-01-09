#ifndef __ARRAY_H
#define __ARRAY_H

#include <cstdlib>
#include <iostream>
#include <vector>
#include <list>
#include <algorithm>
#include <iterator>
#include "General.h"

namespace trains {

template<typename T> bool tighten(T& t) //removes all occurences of n -n from t
{
	if (t.empty()) return false;
	bool result = false;
	bool outputEmpty = true;
	typename T::iterator write = t.begin();
	for (typename T::iterator read = t.begin(); read != t.end(); ++read)
	{
		if (outputEmpty)
		{
			*write = *read; 
			outputEmpty = false;
		}
		else
		{
			if (*write == -*read)
			{
				result = true;
				if (write == t.begin()) outputEmpty = true;
				else --write;
			}
			else
			{
				++write;
				*write = *read;
				outputEmpty = false;
			}
		}
	}
	if (outputEmpty) t.clear();
	else t.erase(++write, t.end());
	return result;
}


template<typename T> class arrayiterator;

template<typename T> class MyArray {
	friend class arrayiterator<T>;
	friend class graph;
	friend class edge;
	friend class vertex;
	friend class code;
	std::vector<T> p;
	uint origin;
	//	long MaxAssigned; /* Maximum index accessed (origin at 0)*/
#ifdef __WINDOWSVERSION
	T& Element(uint i) {if (i>=p.size()) p.insert(p.end(), i+1-p.size(), static_cast<const long>(0)); return p[i];} /* Origin at 0 */
#else
	T& Element(uint i) {if (i>=p.size()) p.resize(i+1); return p[i];} /* Origin at 0 */
#endif
	void _Remove(uint i, uint d=0) {p.erase(p.begin()+i, p.begin()+i+d+1);} /* Removes elements in Positions i to i+d (origin 0) and shifts down.*/
	void _Split(uint i, MyArray<T>& A) {A.p.assign(p.begin()+i+1, p.end()); p.erase(p.begin()+i+1, p.end());} /*Splits after position i (origin 0) and places tail in A*/
public:
	MyArray(uint /*legacy*/ = 1, uint /*legacy*/=1, uint o=1) :  origin(o) {};
	MyArray(const MyArray& A) : p(A.p), origin(A.origin) {};
	MyArray& operator=(const MyArray&A) {origin = A.origin; p = A.p; return *this;}
	//	~intarray();
	//	intarray& operator=(intarray& A);
	T& operator [](uint i) {return Element(i-origin);}
	//	uint GetSize(); /* returns space allocated */
	//	uint GetOrigin() {return origin;}
	bool Add(const T& Value) {if (Find(Value)!=-1) return false; p.push_back(Value); return true;} /*Adds Value to end of array and returns true if not already somewhere in it*/
	void SureAdd(const T& Value) {p.push_back(Value);} /*Adds Value to end of array*/
	void Flush() {p.clear();} /*restores to original size*/
	long Find(const T& Value) {typename std::vector<T>::iterator I =  std::find(p.begin(), p.end(), Value); return (I==p.end()) ? -1 : origin+(I-p.begin());} /*returns index containing value if found, -1 else*/
	long TopIndex() {return static_cast<long>(p.size())+static_cast<long>(origin)-1;}
	void Remove(uint i, uint d=0) {_Remove(i-origin, d);}/* Removes elements in Positions i to i+d  and shifts down.*/
	void Append(const MyArray<T>& A) {p.insert(p.end(), A.p.begin(), A.p.end());} /* Appends A*/
	void Prepend(const MyArray<T>& A) {p.insert(p.begin(), A.p.begin(), A.p.end());}
	void Insert(uint i, const T& Value) {p.insert(p.begin()+i-origin,Value);} /*Array[i] = value, all others shifted up*/
	void Invert() {for (int i=0, j=static_cast<int>(p.size())-1; i<static_cast<int>(p.size())/2; ++i, --j)
	{
		T temp = p[i];
		p[i] = -p[j];
		p[j] = -temp;
	} 
	if (p.size()%2) p[(p.size()-1)/2]=-p[(p.size()-1)/2]; }/*Reverses order of elements and replaces each with negative (requires unary - on T)*/
	void Split(uint i, MyArray<T>& A) {_Split(i-origin,A);}/*Splits after position i and places tail in A*/
	void Print(std::ostream& Out = std::cout) const {std::copy(p.begin(), p.end(), std::ostream_iterator<T>(Out, " ")); 
	Out << std::endl;}
	void RemoveAll(const T& Value) {p.erase(std::remove(p.begin(), p.end(), Value),p.end()); p.erase(std::remove(p.begin(), p.end(), -Value),p.end());}/* Removes all occurences of Value and -Value */
	void Rotate(long Angle=1) {while (Angle>=static_cast<long>(p.size())) Angle-=static_cast<long>(p.size()); std::rotate(p.begin(), p.begin()+Angle, p.end());} /*NewArray[i] = Array[i+Angle] (mod MaxAssigned+1)*/
	void Replace(const T& Value, const MyArray<T>& A) {if (A.p.size()<1) {RemoveAll(Value); return;}
	//std::vector<T> temp = p; p.clear();
	std::vector<T> temp; p.swap(temp);
	MyArray<T> minusA = A; minusA.Invert();
	for (typename std::vector<T>::iterator I = temp.begin(); I!= temp.end(); ++I)
	{
		if (*I==Value) {p.insert(p.end(), A.p.begin(), A.p.end()); continue;}
		if (*I==-Value) {p.insert(p.end(), minusA.p.begin(), minusA.p.end()); continue;}
		p.push_back(*I);
	}
	;} /*Replaces Value with A, -Value with A.Invert()*/
	void Replace(const T& Value, const T& NewValue) {std::replace(p.begin(), p.end(), Value, NewValue);} /* Replaces Value with NewValue, -Value unchanged. */

   
	bool Tighten() {
		return tighten(p);
	} /* Cancels all occurences of Value -Value. True if some such found */
	void CyclicTighten() {
		Tighten();
		if (p.size()<2) return;
		while (p.front() == -p.back())
		{
			p.erase(p.begin()); 
#ifdef __WINDOWSVERSION
			std::vector<T>::iterator I = p.end(); --I; p.erase(I);
#else
			p.erase(--p.end());
#endif
			if (p.size()<2) return;
		}   
	}  
	bool Agrees(uint i, const MyArray<T>& A) {if (p.size()<i || A.p.size()<i) return false;
	for (uint j=0; j<i; ++j) if (p[j] != A.p[j]) return false;
	return true;}     /*Tests if agrees with A on first i entries*/
	uint AgreesTo(const MyArray<T>& A) {for (uint i=0; i<=p.size(); ++i)
	{
		if (i==p.size() || i==A.p.size()) return i;
		if (p[i] != A.p[i]) return i;
	} return 0;}
	/*Returns number of symbols to which the two agree  */
};

template<typename T> class arrayiterator {
	uint Index;                                   
	MyArray<T>*  Array;                                   
public:                                            
	arrayiterator(MyArray<T>& A) : Index(0), Array(&A) {};
	T& Now() {return Array->p[Index];}
	T& operator++(int) {if (Index<Array->p.size()-1) return Array->p[Index++]; Index=0; return Array->p[Array->p.size()-1];}  /*Post Increment*/              
	T& operator++() {Index = (Index==Array->p.size()-1) ? 0 : Index+1; return Array->p[Index];}  /* Pre Increment */ 
	bool AtOrigin() {return (Index==0);}    /* Tests if iterator points to first element of array*/
	void Reset() {Index=0;}                                                             
};


typedef MyArray<long> intarray;
typedef arrayiterator<long> intiterator;

} // namespace trains

#endif
