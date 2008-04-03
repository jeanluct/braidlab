#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "edgevert.h"

namespace trains {

using namespace std;

edgelist::edgelist(uint s, uint d, uint o) : p(new edge[s]), next(NULL), size(s), delta(d), origin(o), MaxAssigned(-1) {};


edgelist::~edgelist() {if (next) next->edgelist::~edgelist(); delete [] p;}

long edgelist::TopIndex() {return MaxAssigned+long(origin);}

edge& edgelist::operator [](uint i)
{                                                                                    
	return Element(i-origin);                                                       
}

edge& edgelist::Element(uint i)
{
	if (i > MAXARRAYLENGTH) THROW("Array Index Out of Bounds", 1); 
	if (long(i) >= MaxAssigned) MaxAssigned = long(i);
	if (i<size) return p[i];                                                           
	if (next) return next->Element(i-size);
	uint growby = (delta > i-size+1) ? delta : i-size+1;
	next = new edgelist(growby, delta);
	if (!next) THROW("Out of Memory", 1);
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

void edgelist::Print(ostream& Out)
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
	if (i > MAXARRAYLENGTH) THROW("Array Index Out of Bounds", 1);
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

void vertexlist::Print(ostream& Out)
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

void edge::Print(ostream& Out, bool showimages, bool showembedding)
{
	Out << "Edge number " << Label << " from vertex " << Start << " to vertex " << End << ":\n";
	Out << "Type: " << EdgeType[Type];
	if (Type == Peripheral) Out << " about puncture number " << Puncture;
	if (showimages)
	{
		Out << "\nImage is: ";
		Image.Print(Out);
	}
	else Out << endl;
	if (showembedding)
	{
		Out << EI << endl;
	}
}

ostream& operator<<(ostream& Out, edge E)
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

void vertex::Print(ostream& Out, bool showembedding)
{
	Out << "Vertex number " << Label << " with image vertex " << Image << ":\n";
	Out << "Edges at vertex are: ";
	Edges.Print(Out);
	if (showembedding) Out << "Region " << Region << endl;
}

ostream& operator<<(ostream& Out, vertex V)
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
