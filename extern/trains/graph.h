#ifndef __GRAPH_H
#define __GRAPH_H


#include <string>
#include <vector>
#include <set>
#include <list>

#include "newarray.h"
#include "edgevert.h"
#include "braid.h"
#include "Matrix.h"


namespace trains {

template<typename T, typename U> bool Find(const T& v, const U& elem)
{
	return (find(v.begin(), v.end(), elem) != v.end());
}


enum thurstontype {pA, fo, Reducible1, Reducible2, pA_or_red, Unknown};
//Reducible1 means transition matrix reducible, Reducible2 have efficient fibred surface

enum matrixformat {raw, maple, latex};

struct singularity
{
	singularity(int prongs_, ::std::list<long> location_, bool interior_) : prongs(prongs_), location(location_), interior(interior_) {};
	int prongs;
	::std::list<long> location;
	bool interior;
};

struct singularityOrbit
{
	int rotation;
	::std::vector<singularity> singularities;
	bool operator< (const singularityOrbit& rhs) const
	{
		if (singularities.empty() || rhs.singularities.empty()) return false;
		if (singularities.front().prongs > rhs.singularities.front().prongs) return true;
		if (singularities.front().prongs < rhs.singularities.front().prongs) return false;
		if (singularities.size() < rhs.singularities.size()) return true;
		return false;
	}
};

struct vertexGateInformation
{
	::std::vector< ::std::vector<long> > gates;
	::std::vector< ::std::pair<long, long> > infinitesimalEdges;
};

struct cuspCounter
{
	cuspCounter(long nextEdge_=0, int cusps_=0) : nextEdge(nextEdge_), cusps(cusps_), considered(false) {};
	long nextEdge; //Following this edge on the right, what is next edge we come to?
	int cusps; //And how many cusps to get there?
	bool considered;
};

class turn {
	friend class graph;
protected:
	long i,j; //Edge labels of turn
	uint Level; //Number of iterates to identification. 0 if not illegal
	bool IsDegenerate() {return (i==j);}
public:
	turn operator-() {THROW("Calling dummy operator -",4); return(*this);}
	bool operator==(turn& T) {return ((i==T.i && j==T.j) || (i==T.j && j==T.i));}
	friend ::std::ostream& operator<<(::std::ostream& Out, turn T);
};

struct turnplace { //Indicates position of turn - in edge Label between places Posn and Posn+1
	long Label;
	uint Position;
};

class turnlist {
	friend class graph;
	friend class edge;
	friend class vertex;
	friend class code;
	turn* p;
	turnlist* next;  /*pointer to continuation of array*/
	uint size;
	uint delta;
	uint origin;
	long MaxAssigned; /* Maximum index accessed (origin at 0)*/
	turn& Element(uint i);  /* Origin at 0 */
	void _Remove(uint i, uint d=0); /* Removes elements in Positions i to i+d (origin 0) and shifts down.*/
	void _Split(uint i, turnlist& A); /*Splits after position i (origin 0) and places tail in A*/
public:
	turnlist(uint s = ARRAYSIZ, uint d = ARRAYDELTA, uint o=1);
	turnlist(turnlist& A);
	~turnlist();
	turnlist& operator=(turnlist& A);
	turn& operator [](uint i);
	uint GetSize(); /* returns space allocated */
	uint GetOrigin() {return origin;}
	bool Add(turn Value); /*Adds Value to end of array and returns true if not already somewhere in it*/
	void SureAdd(turn Value); /*Adds Value to end of array*/
	void Flush(); /*restores to original size*/
	long Find(turn& Value); /*returns index containing value if found, -1 else*/
	long TopIndex();
	void Remove(uint i, uint d=0);/* Removes elements in Positions i to i+d  and shifts down.*/
	void Append(turnlist& A); /* Appends A*/
	void Prepend(turnlist& A);
	void Insert(uint i, turn& Value); /*Array[i] = value, all others shifted up*/
	void Split(uint i, turnlist& A); /*Splits after position i and places tail in A*/
	void Print(::std::ostream& Out = ::std::cout);
	void Rotate(long Angle=1); /*NewArray[i] = Array[i+Angle] (mod MaxAssigned+1)*/
	bool Agrees(uint i, turnlist& A);/*Tests if agrees with A on first i entries*/
	uint AgreesTo(turnlist& A); /*Returns number of symbols to which the two agree  */
};

class graph {
	friend class matrix;
public:
	//Data Members
	uint Punctures; // Number of punctures
	long NextEdgeLabel; // Next edge label
	uint NextVertexLabel;
	edgelist Edges;
	vertexlist Vertices;
	turnlist Turns;     //Also holds infinitesimal edges when have efficient graph map
	intarray Reduction; //Labels of edges in invariant subgraph. Holds gates if efficient graph map
	thurstontype Type;
	bool Factor; //Should we factorise charpoly?
	bool DesireEmbedding; //Does the user want to keep track of embedding information?
	bool Embedding; //Do we keep track of embedding information. false if user input etc, otherwise equals desireembedding
	::std::vector<intarray> loops;
	::std::vector< ::std::string> looplabels;
	::std::vector<singularityOrbit> singularities;
	bool UtilityFlag;
#ifdef VS2005
	bool isHorseshoeBraid;
	::std::vector< ::std::string> Messages;
#endif
	//Utilities
	uint FindEdge(long Label);  // Returns index of edge with given label, 0 if not found
	uint FindVertex(uint Label);
	void Replace(long Label, intarray& L); //Replaces occurences of Label or -Label in edge images
	void LoopReplace(long Label, intarray& L); //Does the same in loops
	void RemoveAll(long Label); // Calls array.RemoveAll on each edge image
	void LoopRemoveAll(long Label); //Calls array.RemoveAll on each loop
	bool Tighten(); //Calls Tighten on each edge image. true if some edge tightened
	void Flush(); //Flushes edge and vertex lists, and resets label counters
	long Derivative(long Label); // Returns Dg(Label). Returns 0 if edge has null image
	long Derivative(long Label, uint n); // Returns Dg^n(Label). Returns 0 if some edge has null image
	long AltDerivative(long Label, uint n=1); // Returns first of Labels image which is not peripheral, repeats n times
	bool IntersectsP(long Label); //Does edge intersect peripheral subgraph
	bool IntersectsP(uint Index) {return (IntersectsP(Edges[Index].Label));} //INEFFICIENT
	uint OnP(uint Label); //Returns appropriate puncture if Vertex is on Peripheral subgraph, 0 otherwise
	uint OnPInd(uint Index); //Same as OnP, but for index not label
	bool IsPeripheral(long Label); //Is edge peripheral
	bool IsPeripheral(uint Index) {return (Edges[Index].Type == Peripheral);}
	uint FromP(long Label) {return OnP(From(Label));}
	void FindTypes(); //Determines edge types
	uint NumberEdges() {return Edges.TopIndex();}
	uint NumberVertices() {return Vertices.TopIndex();}
	uint From(long Label); //Start vertex of edge
	uint To(long Label) {return From(-Label);}
	bool IsProperSubForest(bool* Inset, uint n); //Checks if edge indices in Inset[n+1] form proper subforest
	bool RetractsOntoP(bool* Inset, uint n); //Checks if edge indices in Inset[n+1] form subgraph which deformation retracts onto P.
	turn FindTurns(); //Computes all turns, and returns one with minimal iterates to identification
	void IterateTurn(turn& T); //Iterates turn with derivative
	turnplace LocateTurn(turn& T); //Returns position of given turn
	bool NeedToAbsorb(); //Returns true if some edge from peripheral loop has image beginning peripheral
	bool Collapses(intarray& L); //Returns true if iterating turn germ L gives trivial germ
	void FindGates(); //Calculates gates and infinitesimal edges if graph is efficient
	void FindSingularities();
	bool SingleVertexEmbeddingTighten(uint Index); // if more than half from vertex start same, push along them
	void VertexEmbeddingTighten(uint Index) {while (SingleVertexEmbeddingTighten(Index));}
	void TightenAllVertexEmbeddings() {for (uint i=1; i<=NumberVertices(); ++i) VertexEmbeddingTighten(i);} 
	//Moves
	void Split(long Label); // Splits edge given
	void Collapse(long Label); // Collapses edge given
	void Push(long Label, uint i);// Pushes i symbols from edge Label to each other edge at vertex
	void Subdivide(long Label, uint i); // Subdivides edge Label after i symbols
	void SubdivideHere(long Label, uint i); //Ensures new vertex is at position i in ORIGINAL edge image
	void SubdivideAllBut(long Label, uint i); //Leaves i edge images after subdivision
	void ValenceTwoIsotopy(long Label); //Across given edge (which is collapsed)
	void ValenceTwoIsotopy(uint Label); //At given vertex - chooses correct edge
	void FoldAsMuchAsPossible(long Label1, long Label2, bool Care = true);// Folds 2 edges and any between as much as possible, avoiding fold up to flagged vertex
	void CarefulFoldAsMuchAsPossible(long Label1, long Label2); //Avoids problem of eventually only folding preperipheral edges
	//Graph Setting
	void IdentityGraph(uint n); //Sets up graph on n punctured disc with identity action
	void ActOn(long g); //Acts on graph on n punctured disc with braid generator g
	void VertexImageSwap(uint i, uint j);
	bool SanityCheck(); //Returns true if graph is sane
	void OrientPeripheralEdges(); //Chooses orientation of peripheral edges
	void AddLoop(const intarray& L, const ::std::string& Label) {loops.push_back(L); looplabels.push_back(Label);}
public:
	//Graph Setting
	graph() : Factor(true), DesireEmbedding(true), UtilityFlag(false) {};
	graph(braid& B); // Generate graph from braid.
	void Set(braid& B); //Sets graph from braid.
	void BoundaryPeripheralSet(braid& B); //Sets graph from braid with boundary a peripheral loop
	void UserInput();
	void Print(::std::ostream& Out = ::std::cout, bool showimages = true);
	void PrintTurns(::std::ostream& Out = ::std::cout);
	void PrintReduction(::std::ostream& Out = ::std::cout) {Reduction.Print(Out);}
	void PrintGates(::std::ostream& Out = ::std::cout);
	void PrintSingularities(::std::ostream& Out = ::std::cout, bool Abbreviated = false);
	void PrintLoops(::std::ostream& Out = ::std::cout);
	void ReLabel(); //Relabels Edges and Vertices
	void Save(::std::string Filename);
	void Load(::std::string Filename);
	void Load(::std::istream& In);
	void OldLoad(::std::istream& In);
	//Utilities
	decimal Growth();
#ifdef __CHARPOLY
	::std::string CharacteristicPolynomial(bool factorise, bool includeNonMain = false);
#endif
	::std::vector< ::std::string> TransitionMatrix(matrixformat format = raw, bool includeNonMain = false); 
	bool HasIrreducibleMatrix();
	thurstontype GetType() {return Type;}
	void SetType(thurstontype T) {Type = T;}
	void FindReduction();
	void FindTrack(); //Finds gates, and determines connectivity at vertices, and if pA or red
	void TampDown(); // Makes all gates trivial at non-peripheral vertices. Only used for TTT
	//Moves
	bool PullTight(); // Returns true if any pulling tight is achieved
	//Algorithm
	bool CollapseInvariantForest(); // Returns true if invariant forest (disjt from P) found. Pulls tight
	bool PerformValenceTwoIsotopies(); //Returns true if valence two performed. Pulls Tight
	bool AbsorbIntoP(); //Returns true if graph map is changed. Pulls Tight
	bool MakeIrreducible(bool OldVersion = false); //Returns true if graph map is changed.
	bool FoldToDecreaseLambda(); //Returns true if growth is decreased. Pulls Tight
	decimal FindTrainTrack(); //Returns growth (or 1 if reducible)
};

} // namespace trains

#endif
