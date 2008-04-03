// Header file for edges and vertices
#ifndef __EDGEVERT_H
#define __EDGEVERT_H

#include "array.h"

namespace trains {

enum edgetype {Main, Peripheral, Preperipheral};

class edge {
	friend class graph;
	friend class matrix;
	long Label; //Unique positive integer identifying edge. Inverse denoted -Label
	edgetype Type;
	uint Puncture; //For peripheral edge, identifies puncture it surrounds
	uint Start; //Label of initial vertex
	uint End; //Label of final vertex
public:
	intarray Image; // Integer list giving image of edge
	bool Flag; //Utility Flag
	void Set(long label, edgetype type, uint start, uint end, intarray& image, uint puncture=0);
	void Print(std::ostream& Out = std::cout); // Displays edge data
	edgetype GetType() {return Type;}
	long GetLabel() {return Label;}
	intarray GetImage() {return Image;}
	edge operator-() {THROW("Calling dummy operator -",4); return(*this);}
	bool operator==(edge& E) {THROW("Calling dummy operator =",4); return false;}
	friend std::ostream& operator<<(std::ostream& Out, edge E);
        int Key; //Used for TTT
};

class edgelist {
	friend class edgeiterator;
	friend class graph;
	friend class edge;
	friend class vertex;
	friend class code;
	edge* p;
	edgelist* next;  /*pointer to continuation of array*/
	uint size;
	uint delta;
	uint origin;
	long MaxAssigned; /* Maximum index accessed (origin at 0)*/
	edge& Element(uint i);  /* Origin at 0 */
	void _Remove(uint i, uint d=0); /* Removes elements in Positions i to i+d (origin 0) and shifts down.*/
	void _Split(uint i, edgelist& A); /*Splits after position i (origin 0) and places tail in A*/
public:
	edgelist(uint s = ARRAYSIZ, uint d = ARRAYDELTA, uint o=1);
	edgelist(edgelist& A);
	~edgelist();
	edgelist& operator=(edgelist& A);
	edge& operator [](uint i);
	uint GetSize(); /* returns space allocated */
	uint GetOrigin() {return origin;}
	bool Add(edge Value); /*Adds Value to end of array and returns true if not already somewhere in it*/
	void SureAdd(edge Value); /*Adds Value to end of array*/
	void Flush(); /*restores to original size*/
	long Find(edge& Value); /*returns index containing value if found, -1 else*/
	long TopIndex();
	void Remove(uint i, uint d=0);/* Removes elements in Positions i to i+d  and shifts down.*/
	void Append(edgelist& A); /* Appends A*/
        void Prepend(edgelist& A);
	void Insert(uint i, edge& Value); /*Array[i] = value, all others shifted up*/
	void Split(uint i, edgelist& A); /*Splits after position i and places tail in A*/
	void Print(std::ostream& Out = std::cout);
	void Rotate(long Angle=1); /*NewArray[i] = Array[i+Angle] (mod MaxAssigned+1)*/
	bool Agrees(uint i, edgelist& A);/*Tests if agrees with A on first i entries*/
	uint AgreesTo(edgelist& A); /*Returns number of symbols to which the two agree  */
};

class edgeiterator {
	uint Index;
	edgelist* Array;
public:
	edgeiterator(edgelist& A);
	edge& Now();
	edge& operator++(int);  /*Post Increment*/
	edge& operator++();     /* Pre Increment */
	bool AtOrigin();     /* Tests if iterator points to first element of array*/
	void Reset();
};

class vertex {
	friend class graph;
        friend class TTT;
	uint Label; //Unique positive integer identifier
	intarray Edges; //Labels of edges at vertex, in cyclic order
	uint Image; //Label of image vertex
	bool Flag; //Utility Flag
public:
	void Set(uint label, intarray& edges, uint image);
	void Print(std::ostream& Out = std::cout); // Displays vertex data
	uint Valence() {return (Edges.TopIndex());}
	uint GetLabel() {return Label;}
	uint GetImage() {return Image;}
	intarray GetEdges() {return Edges;}
	vertex operator-() {THROW("Calling dummy operator -",4); return(*this);}
	bool operator==(vertex& V) {THROW("Calling dummy operator =",4); return false;}
	friend std::ostream& operator<<(std::ostream& Out, vertex V);
};

class vertexlist {
	friend class vertexiterator;
	friend class graph;
	friend class edge;
	friend class vertex;
	friend class code;
	vertex* p;
	vertexlist* next;  /*pointer to continuation of array*/
	uint size;
	uint delta;
	uint origin;
	long MaxAssigned; /* Maximum index accessed (origin at 0)*/
	vertex& Element(uint i);  /* Origin at 0 */
	void _Remove(uint i, uint d=0); /* Removes elements in Positions i to i+d (origin 0) and shifts down.*/
	void _Split(uint i, vertexlist& A); /*Splits after position i (origin 0) and places tail in A*/
public:
	vertexlist(uint s = ARRAYSIZ, uint d = ARRAYDELTA, uint o=1);
	vertexlist(vertexlist& A);
	~vertexlist();
	vertexlist& operator=(vertexlist& A);
	vertex& operator [](uint i);
	uint GetSize(); /* returns space allocated */
	uint GetOrigin() {return origin;}
	bool Add(vertex Value); /*Adds Value to end of array and returns true if not already somewhere in it*/
	void SureAdd(vertex Value); /*Adds Value to end of array*/
	void Flush(); /*restores to original size*/
	long Find(vertex& Value); /*returns index containing value if found, -1 else*/
	long TopIndex();
	void Remove(uint i, uint d=0);/* Removes elements in Positions i to i+d  and shifts down.*/
	void Append(vertexlist& A); /* Appends A*/
        void Prepend(vertexlist& A);
	void Insert(uint i, vertex& Value); /*Array[i] = value, all others shifted up*/
	void Split(uint i, vertexlist& A); /*Splits after position i and places tail in A*/
	void Print(std::ostream& Out = std::cout);
	void Rotate(long Angle=1); /*NewArray[i] = Array[i+Angle] (mod MaxAssigned+1)*/
	bool Agrees(uint i, vertexlist& A);/*Tests if agrees with A on first i entries*/
	uint AgreesTo(vertexlist& A); /*Returns number of symbols to which the two agree  */
};

class vertexiterator {
	uint Index;
	vertexlist* Array;                                   
public:
	vertexiterator(vertexlist& A);
	vertex& Now();
	vertex& operator++(int);  /*Post Increment*/              
	vertex& operator++();     /* Pre Increment */
	bool AtOrigin();     /* Tests if iterator points to first element of array*/
	void Reset();
};





edgelist::edgelist(uint s, uint d, uint o) : p(new edge[s]), next(NULL), size(s), delta(d), origin(o), MaxAssigned(-1) {};


edgelist::~edgelist() {if (next) next->edgelist::~edgelist(); delete [] p;}

long edgelist::TopIndex() {return MaxAssigned+long(origin);}

edge& edgelist::operator [](uint i)
{                                                                                    
	return Element(i-origin);                                                       
}

edge& edgelist::Element(uint i)
{
	if (i > 30000) THROW("Array Index Out of Bounds", 1); 
	if (long(i) >= MaxAssigned) MaxAssigned = long(i);
	if (i<size) return p[i];                                                           
	if (next) return next->Element(i-size);
	uint growby = (delta > i-size+1) ? delta : i-size+1;
	next = new edgelist(growby, delta);
	return next->Element(i-size);                                                          
}

uint edgelist::GetSize()
{
	if (!next) return size;
	return size + next->GetSize();
}
																			
void edgelist::Flush()
{                                                          
	if (next)
	{
		next->Flush();
		next->edgelist::~edgelist();                                     
	}
	next = NULL;                                                  
	MaxAssigned = -1;
}                                                                  

edgelist::edgelist(edgelist& A) : p(new edge[A.GetSize()]),
		 next (NULL), size(A.GetSize()), delta(A.delta), origin(A.origin), MaxAssigned(A.MaxAssigned)
{
	for (uint i=0; long(i)<=A.MaxAssigned; i++) Element(i)=A.Element(i);
}                                                   

edgelist& edgelist::operator=(edgelist& A)                        
{
	if (this == &A) return *this;                        
	Flush();
	MaxAssigned = -1;                                      
	for (int i=0; i<=A.MaxAssigned; i++) Element(i) = A.Element(i);
	return *this;
}


long edgelist::Find(edge& Value)                                               
{
	for (int i=0; i<=MaxAssigned; i++) if (Element(i) == Value) return (i+origin);  
	return -1;
}                                                                                    

void edgelist::_Remove(uint i, uint d)
{
	if (long(i+d) > MaxAssigned) THROW("Trying to remove non-existent elements",1);             
	for (uint j=i+d+1; long(j)<=MaxAssigned; j++) Element(j-d-1)=Element(j);
	MaxAssigned -= (d+1);                                                                   
}

void edgelist::Remove(uint i, uint d)
{                                                 
	_Remove(i-origin, d);
}

void edgelist::Append(edgelist& A)                            
{
	for (uint i=0; long(i)<=A.MaxAssigned; i++)                
		if (MaxAssigned == -1) Element(0) = A.Element(i);
		else Element(uint(MaxAssigned+1)) = A.Element(i);   
}
																				
void edgelist::Prepend(edgelist& A)
{
	long j = A.MaxAssigned;
	if (j==-1) return; 
	for (long i=MaxAssigned; i>=0; i--)
		Element(uint(i+j+1)) = Element(uint(i));  
	for (long i=0; i<=j; i++) Element(uint(i)) = A.Element(uint(i));
}                                                                 



void edgelist::_Split(uint i, edgelist& A)
{                                                                                           
	if (long(i)>MaxAssigned) THROW("Trying to split after end of array",1);
	A.Flush();                               
	uint k=0;
	for (uint j=i+1; long(j)<=MaxAssigned; j++) A.Element(k++) = Element(j);
	MaxAssigned = long(i);
}

																								 
void edgelist::Split(uint i, edgelist& A)
{                                                                          
	_Split(i-origin, A);
}

void edgelist::Print(std::ostream& Out)
{
	for (uint i=0; long(i)<=MaxAssigned; i++) Out << Element(i) << " ";                 
	Out << '\n';
}   



void edgelist::Rotate(long Angle)
{                                                                                           
	if (MaxAssigned <= 0) return;
	edgelist Temp = *this;                                   
	long Modulus = MaxAssigned+1;
	for (long i=0; i<=MaxAssigned; i++)                    
	{
		long j= (i+Angle) % Modulus;
		if (j<0) j+=Modulus;
		Element(uint(i))=Temp.Element(uint(j));                 
	}
}  



void edgelist::Insert(uint i, edge& Value)
{
	for (uint j = TopIndex()+1; j>i; j--) (*this)[j] = (*this)[j-1];
	(*this)[i] = Value;
}




bool edgelist::Agrees(uint i, edgelist& A)
{
	if (MaxAssigned < long(i)-1 || A.MaxAssigned < long(i)-1) return false;
	for (uint j=0; j<i; j++) if (!(Element(j) == A.Element(j))) return false;
	return true;
}

bool edgelist::Add(edge Value)
{
	if (Find(Value) != -1) return false;
	Element(uint(MaxAssigned+1)) = Value;
	return true;
}

void edgelist::SureAdd(edge Value)
{
	Element(uint(MaxAssigned+1)) = Value;
}

uint edgelist::AgreesTo(edgelist& A)
{
	long Size = (MaxAssigned > A.MaxAssigned) ? A.MaxAssigned : MaxAssigned;
	uint i; for (i=0; long(i)<=Size; i++) if (!(Element(i) == A.Element(i))) return i;
	return i;
}


edgeiterator::edgeiterator(edgelist& A) : Index(0), Array(&A) {};

edge& edgeiterator::Now() {return Array->Element(Index);}

edge& edgeiterator::operator++(int)
{
	if (long(Index) < Array->MaxAssigned) return(Array->Element(Index++));
	Index = 0;
	return (Array->Element(uint(Array->MaxAssigned)));
}

edge& edgeiterator::operator++()
{
	if (long(Index) < Array->MaxAssigned) Index++;
	else Index = 0;
	return (Array->Element(Index));
}

bool edgeiterator::AtOrigin()
{
	return (Index == 0);                                                          
}

void edgeiterator::Reset()
{
	Index = 0;
}


vertexlist::vertexlist(uint s, uint d, uint o) : p(new vertex[s]), next(NULL), size(s), delta(d), origin(o), MaxAssigned(-1) {};


vertexlist::~vertexlist() {if (next) next->vertexlist::~vertexlist(); delete [] p;}

long vertexlist::TopIndex() {return MaxAssigned+long(origin);}

vertex& vertexlist::operator [](uint i)
{
	return Element(i-origin);
}

vertex& vertexlist::Element(uint i)
{
	if (i > 30000) THROW("Array Index Out of Bounds", 1);
	if (long(i) >= MaxAssigned) MaxAssigned = long(i);
	if (i<size) return p[i];
	if (next) return next->Element(i-size);
	uint growby = (delta > i-size+1) ? delta : i-size+1;
	next = new vertexlist(growby, delta);
	return next->Element(i-size);
}

uint vertexlist::GetSize()
{
	if (!next) return size;
	return size + next->GetSize();
}

void vertexlist::Flush()
{
	if (next)
	{
		next->Flush();
		next->vertexlist::~vertexlist();
	}
	next = NULL;
	MaxAssigned = -1;
}

vertexlist::vertexlist(vertexlist& A) : p(new vertex[A.GetSize()]),
		 next (NULL), size(A.GetSize()), delta(A.delta), origin(A.origin), MaxAssigned(A.MaxAssigned)
{
	for (uint i=0; long(i)<=A.MaxAssigned; i++) Element(i)=A.Element(i);
}

vertexlist& vertexlist::operator=(vertexlist& A)
{
	if (this == &A) return *this;
	Flush();
	MaxAssigned = -1;
	for (int i=0; i<=A.MaxAssigned; i++) Element(i) = A.Element(i);
	return *this;
}


long vertexlist::Find(vertex& Value)
{
	for (int i=0; i<=MaxAssigned; i++) if (Element(i) == Value) return (i+origin);
	return -1;
}

void vertexlist::_Remove(uint i, uint d)
{
	if (long(i+d) > MaxAssigned) THROW("Trying to remove non-existent elements",1);
	for (uint j=i+d+1; long(j)<=MaxAssigned; j++) Element(j-d-1)=Element(j);
	MaxAssigned -= (d+1);
}

void vertexlist::Remove(uint i, uint d)
{
	_Remove(i-origin, d);
}

void vertexlist::Append(vertexlist& A)
{
	for (uint i=0; long(i)<=A.MaxAssigned; i++)
		if (MaxAssigned == -1) Element(0) = A.Element(i);
		else Element(uint(MaxAssigned+1)) = A.Element(i);
}

void vertexlist::Prepend(vertexlist& A)
{
	long j = A.MaxAssigned;
	if (j==-1) return;
	for (long i=MaxAssigned; i>=0; i--)
		Element(uint(i+j+1)) = Element(uint(i));
	for (long i=0; i<=j; i++) Element(uint(i)) = A.Element(uint(i));
}



void vertexlist::_Split(uint i, vertexlist& A)
{
	if (long(i)>MaxAssigned) THROW("Trying to split after end of array",1);
	A.Flush();
	uint k=0;
	for (uint j=i+1; long(j)<=MaxAssigned; j++) A.Element(k++) = Element(j);
	MaxAssigned = long(i);
}


void vertexlist::Split(uint i, vertexlist& A)
{
	_Split(i-origin, A);
}

void vertexlist::Print(std::ostream& Out)
{
	for (uint i=0; long(i)<=MaxAssigned; i++) Out << Element(i) << " ";
	Out << '\n';
}



void vertexlist::Rotate(long Angle)
{
	if (MaxAssigned <= 0) return;
	vertexlist Temp = *this;
	long Modulus = MaxAssigned+1;
	for (long i=0; i<=MaxAssigned; i++)
	{
		long j= (i+Angle) % Modulus;
		if (j<0) j+=Modulus;
		Element(uint(i))=Temp.Element(uint(j));
	}
}



void vertexlist::Insert(uint i, vertex& Value)
{
	for (uint j = TopIndex()+1; j>i; j--) (*this)[j] = (*this)[j-1];
	(*this)[i] = Value;
}



bool vertexlist::Agrees(uint i, vertexlist& A)
{
	if (MaxAssigned < long(i)-1 || A.MaxAssigned < long(i)-1) return false;
	for (uint j=0; j<i; j++) if (!(Element(j) == A.Element(j))) return false;
	return true;
}

bool vertexlist::Add(vertex Value)
{
	if (Find(Value) != -1) return false;
	Element(uint(MaxAssigned+1)) = Value;
	return true;
}                                                                                     

void vertexlist::SureAdd(vertex Value)
{
	Element(uint(MaxAssigned+1)) = Value;                                                        
}
																		                                      
uint vertexlist::AgreesTo(vertexlist& A)
{
	long Size = (MaxAssigned > A.MaxAssigned) ? A.MaxAssigned : MaxAssigned;
	uint i; for (i=0; long(i)<=Size; i++) if (!(Element(i) == A.Element(i))) return i;
	return i;
}


vertexiterator::vertexiterator(vertexlist& A) : Index(0), Array(&A) {};

vertex& vertexiterator::Now() {return Array->Element(Index);}

vertex& vertexiterator::operator++(int)                                                         
{
	if (long(Index) < Array->MaxAssigned) return(Array->Element(Index++));                        
	Index = 0;
	return (Array->Element(uint(Array->MaxAssigned)));
}

vertex& vertexiterator::operator++()
{                                                                        
	if (long(Index) < Array->MaxAssigned) Index++;
	else Index = 0;
	return (Array->Element(Index));
}

bool vertexiterator::AtOrigin()
{
	return (Index == 0);
}

void vertexiterator::Reset()
{
	Index = 0;
}


//Edge Class

static char* EdgeType[] = {"Main", "Peripheral", "Pre-peripheral"};

void edge::Set(long label, edgetype type, uint start, uint end, intarray& image, uint puncture)
{
	Label = label;
	Type = type;
	Start = start;
	End = end;
	Image = image;
	Puncture = puncture;
}

void edge::Print(std::ostream& Out)
{
	Out << "Edge number " << Label << " from vertex " << Start << " to vertex " << End << ":\n";
	Out << "Type: " << EdgeType[Type];
	if (Type == Peripheral) Out << " about puncture number " << Puncture;
	Out << "\nImage is: ";
	Image.Print(Out);
}

std::ostream& operator<<(std::ostream& Out, edge E)
{
	Out << "Edge number " << E.Label << " from vertex " << E.Start << " to vertex " << E.End << ":\n";
	Out << "Type: " << EdgeType[E.Type];
	if (E.Type == Peripheral) Out << " about puncture number " << E.Puncture;
	Out << "\n Image is: ";
	intiterator I(E.Image);
	do
	{
		Out << (I++) << " ";
	} while (!I.AtOrigin());
	return (Out);
}



//Vertex Class
void vertex::Set(uint label, intarray& edges, uint image)
{
	Label = label;
	Image = image;
	Edges = edges;
}

void vertex::Print(std::ostream& Out)
{
	Out << "Vertex number " << Label << " with image vertex " << Image << ":\n";
	Out << "Edges at vertex are: ";
	Edges.Print(Out);
}

std::ostream& operator<<(std::ostream& Out, vertex V)
{
	Out << "Vertex number " << V.Label << " with image vertex " << V.Image << ":\n";
	Out << "Edges at vertex are: ";
	intiterator I(V.Edges);
	do
	{
		Out << (I++) << '\n';
	} while (! I.AtOrigin());
	return (Out);
}


} // namespace trains


#endif
