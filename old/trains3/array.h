#ifndef __ARRAY_H
#define __ARRAY_H

#include <cstdlib>
#include <iostream>
#include "general.h"

namespace trains {

class intarray {
	friend class intiterator;
	friend class graph;
	friend class edge;
	friend class vertex;
	friend class code;
	long* p;
	intarray* next;  /*pointer to continuation of array*/
	uint size;
	uint delta;
	uint origin;
	long MaxAssigned; /* Maximum index accessed (origin at 0)*/
	long& Element(uint i);  /* Origin at 0 */
	void _Remove(uint i, uint d=0); /* Removes elements in Positions i to i+d (origin 0) and shifts down.*/
	void _Split(uint i, intarray& A); /*Splits after position i (origin 0) and places tail in A*/
public:
	intarray(uint s = ARRAYSIZ, uint d = ARRAYDELTA, uint o=1);
	intarray(intarray& A);
	~intarray();
	intarray& operator=(intarray& A);
	long& operator [](uint i);
	uint GetSize(); /* returns space allocated */
	uint GetOrigin() {return origin;}
	bool Add(long Value); /*Adds Value to end of array and returns true if not already somewhere in it*/
	void SureAdd(long Value); /*Adds Value to end of array*/
	void Flush(); /*restores to original size*/
	long Find(long& Value); /*returns index containing value if found, -1 else*/
	long TopIndex();
	void Remove(uint i, uint d=0);/* Removes elements in Positions i to i+d  and shifts down.*/
	void Append(intarray& A); /* Appends A*/
    void Prepend(intarray& A);
	void Insert(uint i, long& Value); /*Array[i] = value, all others shifted up*/
	void Invert(); /*Reverses order of elements and replaces each with negative (requires unary - on T)*/
	void Split(uint i, intarray& A); /*Splits after position i and places tail in A*/
	void Print(std::ostream& Out = std::cout);
	void RemoveAll(long& Value); /* Removes all occurences of Value and -Value */
	void Rotate(long Angle=1); /*NewArray[i] = Array[i+Angle] (mod MaxAssigned+1)*/
	void Replace(long& Value, intarray& A); /*Replaces Value with A, -Value with A.Invert()*/
	void Replace(long& Value, long& NewValue); /* Replaces Value with NewValue, -Value unchanged. */
	bool Tighten(); /* Cancels all occurences of Value -Value. True if some such found */
	bool Agrees(uint i, intarray& A);/*Tests if agrees with A on first i entries*/
	uint AgreesTo(intarray& A); /*Returns number of symbols to which the two agree  */
};

class intiterator {
	uint Index;                                   
	intarray* Array;                                   
public:                                            
	intiterator(intarray& A);
	long& Now();                                         
	long& operator++(int);  /*Post Increment*/              
	long& operator++();     /* Pre Increment */ 
	bool AtOrigin();     /* Tests if iterator points to first element of array*/
	void Reset();                                                                
};


intarray::intarray(uint s, uint d, uint o) : p(new long[s]), next(NULL), size(s), delta(d), origin(o), MaxAssigned(-1) {};
																										
																										 
intarray::~intarray() {if (next) next->intarray::~intarray(); delete [] p;}                     
																											
long intarray::TopIndex() {return MaxAssigned+long(origin);}                          
																											  
long& intarray::operator [](uint i)                                                        
{                                                                                    
	return Element(i-origin);                                                       
}                                                                                   
																											 
long& intarray::Element(uint i)                                                           
{                                                                                    
	if (long(i) > 30000) THROW("Array Index Out of Bounds", 1); 
	if (long(i) >= MaxAssigned) MaxAssigned = long(i);                                            
	if (i<size) return p[i];                                                           
	if (next) return next->Element(i-size);                                             
	uint growby = (delta > i-size+1) ? delta : i-size+1;                                 
	next = new intarray(growby, delta);                                                       
	return next->Element(i-size);                                                          
}                                                                                          
																														  
uint intarray::GetSize()                                
{                                                   
	if (!next) return size;                            
	return size + next->GetSize();                      
}                                                       
																			
void intarray::Flush()                                        
{                                                          
	if (next)                                                
	{                                                         
		next->Flush();                                          
		next->intarray::~intarray();                                     
	}                                                            
	next = NULL;                                                  
	MaxAssigned = -1;                                              
}                                                                  
																						  
intarray::intarray(intarray& A) : p(new long[A.GetSize()]),                         
		 next (NULL), size(A.GetSize()), delta(A.delta), origin(A.origin), MaxAssigned(A.MaxAssigned)
{                                                                              
	for (uint i=0; long(i)<=A.MaxAssigned; i++) Element(i)=A.Element(i);
}                                                   
																	  
intarray& intarray::operator=(intarray& A)                        
{                                                      
	if (this == &A) return *this;                        
	Flush();                                              
	MaxAssigned = -1;                                      
	for (int i=0; i<=A.MaxAssigned; i++) Element(i) = A.Element(i);  
	return *this;                                                     
}

																							  
long intarray::Find(long& Value)                                               
{                                                                        
	for (int i=0; i<=MaxAssigned; i++) if (Element(i) == Value) return (i+origin);  
	return -1;                                                                       
}                                                                                    
																												  
void intarray::_Remove(uint i, uint d)                                                     
{                                                                                       
	if (long(i+d) > MaxAssigned) THROW("Trying to remove non-existent elements",1);             
	for (uint j=i+d+1; long(j)<=MaxAssigned; j++) Element(j-d-1)=Element(j);                     
	MaxAssigned -= (d+1);                                                                   
}                                                                                           
																															
void intarray::Remove(uint i, uint d)                                                             
{                                                 
	_Remove(i-origin, d);                           
}                                                   
																	  
void intarray::Append(intarray& A)                            
{                                                      
	for (uint i=0; long(i)<=A.MaxAssigned; i++)                
		if (MaxAssigned == -1) Element(0) = A.Element(i);  
		else Element(uint(MaxAssigned+1)) = A.Element(i);   
}                                                          
																				
void intarray::Prepend(intarray& A)                                  
{                                                             
	long j = A.MaxAssigned; 
	if (j==-1) return; 
	for (long i=MaxAssigned; i>=0; i--)          
		Element(uint(i+j+1)) = Element(uint(i));  
	for (long i=0; i<=j; i++) Element(uint(i)) = A.Element(uint(i));
}                                                                 
																						 
void intarray::Invert()                                                 
{                                                                    
	intarray Temp = *this;                                                 
	for (uint i = 0; long(i)<=MaxAssigned; i++)
    {long temp=-Temp.Element(uint(MaxAssigned-i)); Element(i)=temp;}
}                                                                                        
																														
void intarray::_Split(uint i, intarray& A)                                                         
{                                                                                           
	if (long(i)>MaxAssigned) THROW("Trying to split after end of array",1);                         
	A.Flush();                               
	uint k=0;                                 
	for (uint j=i+1; long(j)<=MaxAssigned; j++) A.Element(k++) = Element(j); 
	MaxAssigned = long(i);                                                    
}

																								 
void intarray::Split(uint i, intarray& A)                                         
{                                                                          
	_Split(i-origin, A);                                                     
}       
																									
void intarray::Print(std::ostream& Out)                                                 
{                                                                               
	for (uint i=0; long(i)<=MaxAssigned; i++) Out << Element(i) << " ";                 
	Out << '\n';                                                                   
}   
																												
void intarray::RemoveAll(long& Value)                                                       
{                                                                                     
	long Found;
    long Temp=-Value;
	while ((Found = Find(Value)) != -1) Remove(uint(Found));
	while ((Found = Find(Temp)) != -1) Remove(uint(Found));
}    
																															 
void intarray::Rotate(long Angle)                                                             
{                                                                                           
	if (MaxAssigned <= 0) return;                     
	intarray Temp = *this;                                   
	long Modulus = MaxAssigned+1;                         
	for (long i=0; i<=MaxAssigned; i++)                    
	{                                                       
		long j= (i+Angle) % Modulus;                          
		if (j<0) j+=Modulus;                                   
		Element(uint(i))=Temp.Element(uint(j));                 
	}                                                           
}  
																			  
void intarray::Replace(long& Value, intarray& A)                             
{                                                                  
	long Size = A.MaxAssigned;                                       
	if (Size < 0)                                                     
	{                                                                  
		RemoveAll(Value);                                                
		return;                                                           
	}                                                                     
	intarray Temp = *this;                                                     
	uint j=0; long Mvalue=-Value;                                                              
	for (uint i=0; long(i)<=Temp.MaxAssigned; i++)                                 
	{                                                                         
		if (Temp.Element(i) == Value)                                           
		{                                                                        
			for (uint k=0; long(k)<=Size; k++) Element(j++) = A.Element(k);
			continue;                                                               
		}                                                                           
		if (Temp.Element(i) == Mvalue)                                               
		{                                                                             
			for (uint k=Size+1; k>=1; k--) {long temp=-A.Element(k-1); Element(j++) = temp;}                   
			continue;                                                                    
		}                                                                                
		Element(j++) = Temp.Element(i);                                                   
	}                                                                                     
}


void intarray::Insert(uint i, long& Value)           
{                                              
	for (uint j = TopIndex()+1; j>i; j--) (*this)[j] = (*this)[j-1]; 
	(*this)[i] = Value;                                               
}
																						  
void intarray::Replace(long& Value, long& NewValue)                               
{                                                                        
	for (uint i=0; long(i)<=MaxAssigned; i++) if (Element(i)==Value) Element(i) = NewValue; 
}      
																													
bool intarray::Tighten()                                                                    
{                                                                                       
	bool Result = false;                               
	for (long i=0; i<MaxAssigned; i++)                  
	{                                                    
		long temp=-Element(i+1);if (Element(i) == temp)                   
		{                                                   
			_Remove(i,1);                                     
			i=-1;                                              
			Result = true;                                      
		}                                                       
	}                                                           
	return Result;                                               
}
  
bool intarray::Agrees(uint i, intarray& A)                                 
{                                                                   
	if (MaxAssigned < long(i)-1 || A.MaxAssigned < long(i)-1) return false;       
	for (uint j=0; j<i; j++) if (!(Element(j) == A.Element(j))) return false; 
	return true;                                                               
}                                                                              
																										  
bool intarray::Add(long Value)                                                          
{                                                                                 
	if (Find(Value) != -1) return false;                                            
	Element(uint(MaxAssigned+1)) = Value;                                                  
	return true;                                                                      
}                                                                                     
																												
void intarray::SureAdd(long Value)                                                             
{                                                                                        
	Element(uint(MaxAssigned+1)) = Value;                                                        
}                                                                                          
																		                                      
uint intarray::AgreesTo(intarray& A)
{                                                         
	long Size = (MaxAssigned > A.MaxAssigned) ? A.MaxAssigned : MaxAssigned;
	uint i; for (i=0; long(i)<=Size; i++) if (!(Element(i) == A.Element(i))) return i;
	return i;                                                                  
}


intiterator::intiterator(intarray& A) : Index(0), Array(&A) {};
																												  
long& intiterator::Now() {return Array->Element(Index);}                                 
																													 
long& intiterator::operator++(int)                                                         
{                                                                                         
	if (long(Index) < Array->MaxAssigned) return(Array->Element(Index++));                        
	Index = 0;                                                                               
	return (Array->Element(uint(Array->MaxAssigned)));                                        
}                                                                                             
																							  
long& intiterator::operator++()
{                                                                        
	if (long(Index) < Array->MaxAssigned) Index++;                               
	else Index = 0;                                                         
	return (Array->Element(Index));                                          
}                                                                            
																										
bool intiterator::AtOrigin()                                                  
{                                                                               
	return (Index == 0);                                                          
}                                                                                 
																											  
void intiterator::Reset()
{                                                                                    
	Index = 0;                                                                         
}


} // namespace trains


#endif
