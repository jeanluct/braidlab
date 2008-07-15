// Header file for edges and vertices
#ifndef __EDGEVERT_H
#define __EDGEVERT_H


#include "newarray.h"
#include "embedding.h"

namespace trains {

enum edgetype {Main, Peripheral, Preperipheral};

class matrix;
class graph;


class edge {
	friend class graph;
	friend class matrix;
	long Label; //Unique positive integer identifying edge. Inverse denoted -Label
	edgetype Type;
	uint Puncture; //For peripheral edge, identifies puncture it surrounds
	uint Start; //Label of initial vertex
	uint End; //Label of final vertex
	EmbeddingInformation EI;
public:
	intarray Image; // Integer list giving image of edge
	bool Flag; //Utility Flag
	void Set(long label, edgetype type, uint start, uint end, intarray& image, uint puncture=0);
	void Print(std::ostream& Out = std::cout, bool showimages = true, bool showembedding = false); // Displays edge data
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
	int Region; //For embedding information
	bool Flag; //Utility Flag
public:
	void Set(uint label, intarray& edges, uint image);
	void Print(std::ostream& Out = std::cout, bool showembedding = false); // Displays vertex data
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

} // namespace trains

#endif
