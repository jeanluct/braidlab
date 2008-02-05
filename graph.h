#ifndef __GRAPH_H
#define __GRAPH_H

#include <fstream>
#include <string>
#include <cstdio>
#include "decimal.h"
#include "array.h"
#include "edgevert.h"
#include "braid.h"
#include "matrix.h"

decimal TOL = STARTTOL;
bool GrowthCheck = true;

namespace trains {

enum thurstontype {pA, fo, Reducible1, Reducible2, pA_or_red, Unknown};
//Reducible1 means transition matrix reducible, Reducible2 have efficient fibred surface

class turn {
	friend class graph;
protected:
	long i,j; //Edge labels of turn
	uint Level; //Number of iterates to identification. 0 if not illegal
	bool IsDegenerate() {return (i==j);}
public:
	turn operator-() {THROW("Calling dummy operator -",4); return(*this);}
	bool operator==(turn& T) {return ((i==T.i && j==T.j) || (i==T.j && j==T.i));}
	friend std::ostream& operator<<(std::ostream& Out, turn T);
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
	void Print(std::ostream& Out = std::cout);
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
//Utilities
	uint FindEdge(long Label);  // Returns index of edge with given label, 0 if not found
	uint FindVertex(uint Label);
	void Replace(long Label, intarray& L); //Replaces occurences of Label or -Label in edge images
	void RemoveAll(long Label); // Calls array.RemoveAll on each edge image
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
public:
//Graph Setting
	graph() {};
	graph(braid& B); // Generate graph from braid.
	void Set(braid& B); //Sets graph from braid.
	void UserInput();
	void Print(std::ostream& Out = std::cout);
	void PrintTurns(std::ostream& Out = std::cout);
	void PrintReduction(std::ostream& Out = std::cout) {Reduction.Print(Out);}
	void PrintGates(std::ostream& Out = std::cout);
	void ReLabel(); //Relabels Edges and Vertices
	void Save(char* Filename, const char* Comment = "");
	void Load(char* Filename, bool Sanity=1);
//Utilities
	decimal Growth();
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
	bool MakeIrreducible(); //Returns true if graph map is changed.
	bool FoldToDecreaseLambda(); //Returns true if growth is decreased. Pulls Tight
	decimal FindTrainTrack(); //Returns growth (or 1 if reducible)
};



bool graph::CollapseInvariantForest()
{
	uint n = NumberEdges();
//First check if some edge has trivial image. In this case it is either an invariant forest or
//a homotopically trivial loop - in either case, collapse and return.
    uint i;
	for (i=1; i<=n; i++) if (!Edges[i].Image.TopIndex())
	{
		Collapse(Edges[i].Label);
		PullTight();
		return true;
	}
	bool *Inset = new bool[n+1], *Changed = new bool[n+1], *NewChanged = new bool[n+1], Result = false;
	long *Labels = new long[n+1];
	for (i=1; i<=n; i++) Labels[i] = Edges[i].Label;
	for (i=1; i<=n; i++) //Is Edges[i] in invariant forest
	{
		if (IntersectsP(Labels[i])) continue; //Certainly no good
		for (uint j=1; j<=n; j++) Inset[j] = Changed[j] = NewChanged[j] = false;
		Inset[i] = Changed[i] = true;
		bool SomeChanged = true, Bad = false;
		while (SomeChanged && !Bad)
		{
			for (uint j=i; j<=n; j++) if (Changed[j])
			{
				intarray& Im = Edges[j].Image;
				for (uint k=1; long(k)<=Im.TopIndex(); k++)
				{
					if (IntersectsP(Im[k]))
					{
						Bad = true;
						break;
					}
					uint Index = FindEdge(Im[k]);
					if (Index < i)
					{
						Bad = true;
						break;
					}
					if (!Inset[Index])
					{
						Inset[Index] = true;
						NewChanged[Index] = true;
					}
				}
				if (Bad) break;
			}
			if (Bad) break;
			SomeChanged = false;
			for (uint j=1; j<=n; j++)
			{
				Changed[j] = NewChanged[j];
				if (NewChanged[j]) SomeChanged = true;
				NewChanged[j] = false;
			}
		}
		if (!Bad)          //In this case Inset contains an invariant graph disjoint from P
		{
			if (IsProperSubForest(Inset,n))
			{
				Result = true;
				break;
			}
		}
	}
	if (Result)
	{
		for (i=1; i<=n; i++) if (Inset[i])
		{
			Push(Labels[i], Edges[FindEdge(Labels[i])].Image.TopIndex());
			Collapse(Labels[i]);
		}
		PullTight();
	}
	delete []Inset;
	delete []Changed;
	delete []NewChanged;
	delete []Labels;
	return Result;
}

bool graph::PerformValenceTwoIsotopies()
{
	bool Result = false;
	bool ValenceTwoFound = true;
	while (ValenceTwoFound)
	{
		ValenceTwoFound = false;
		for (uint i=1; i<=NumberVertices(); i++)
		{
			if (Vertices[i].Valence() == 2)
			{
				ValenceTwoIsotopy(Vertices[i].Label);
				PullTight();
				while (CollapseInvariantForest());
				ValenceTwoFound = Result = true;
				break;
			}
		}
		if (!HasIrreducibleMatrix()) break;
	}
	return Result;
}

bool graph::FoldToDecreaseLambda()
{
	decimal OldGrowth = Growth();
	if (OldGrowth-1.0 < TOL)
	{
		Type = fo;
		return false;
	}
	turn Illegal = FindTurns();
	if (!Illegal.Level)
	{
		Type = pA_or_red;
		return false;
	}
	turnplace Here = LocateTurn(Illegal);
	SubdivideHere(Here.Label, Here.Position);
	//Mark new vertex
    uint i;
	for (i=1; i<NumberVertices(); i++) Vertices[i].Flag = false;
	Vertices[i].Flag = true;
	//Make list of vertices to fold at
	uint* FoldHere = new uint[Illegal.Level+1];
	uint Current = NextVertexLabel-1; //Newly created vertex
	for (i=1; i<=Illegal.Level; i++)
	{
		Current = Vertices[FindVertex(Current)].Image;
		FoldHere[Illegal.Level+1-i] = Current;
	}
	//Fold at each vertex in turn
	for (i=1; i<=Illegal.Level; i++)
	{
		//Find Marked Vertex
		uint j=1; while (!Vertices[j].Flag) j++;
		//Find labels of edges to fold
		long Label1 = Vertices[j].Edges[1], Label2 = Vertices[j].Edges[2];
		for (uint k=0; k<=Illegal.Level-i; k++)
		{
			Label1 = Derivative(Label1);
			Label2 = Derivative(Label2);
		}
		if (Label1 == Label2)
		{
			uint FromLabel = From(Label1);
			uint FromIndex = FindVertex(FromLabel);
			if (Vertices[FromIndex].Valence() != 1)
			{
				delete [] FoldHere;
				THROW("Trying to fold edge with itself!",1);
			}
			uint Index = FindEdge(Label1);
			Edges[Index].Image.Flush();
			Vertices[FromIndex].Image = Vertices[FindVertex(To(Label1))].Image;
			Collapse(Label1);
			break;
		}
		FoldAsMuchAsPossible(Label1, Label2);
	}

	PullTight();
	bool Changed = true;
	while (Changed)
	{
		if (CollapseInvariantForest()) continue;
		if (HasIrreducibleMatrix())
			if (PerformValenceTwoIsotopies()) continue;
		Changed = false;
	}
	delete [] FoldHere;
	if (GrowthCheck && HasIrreducibleMatrix())
		if (Growth() >= OldGrowth-TOL)
        {
           THROW("Growth not decreasing in fold.\nTry decreasing the tolerance\n or disable checking.",2);
           return false;
        }
	return true;
}

decimal graph::FindTrainTrack()
{
	bool Finished = false;
	while (!Finished)
	{
		PullTight();
		if (CollapseInvariantForest()) continue;
		if (AbsorbIntoP()) continue;
		if (!HasIrreducibleMatrix())
		{
			Type = Reducible1;
			FindReduction();
			ReLabel();
			return 1.0;
		}
		if (PerformValenceTwoIsotopies()) continue;
		if (MakeIrreducible()) continue;
		if (!FoldToDecreaseLambda()) Finished = true;
		if (!SanityCheck())
			THROW("Insane graph map",1);
	}
	ReLabel();
	decimal Result = Growth();
	if (Result-1.0<TOL)
	{
		Type = fo;
		return 1.0;
	}
	Type = pA_or_red;
	return Result;
}

bool graph::AbsorbIntoP()
{
	if (!Punctures) return false;
	bool Result = false;
// Eliminate any invariant subgraphs which deformation retract onto P other than P itself
	bool Found = true;
	while (Found)
	{
		uint n = NumberEdges();
		bool *Inset = new bool[n+1], *Changed = new bool[n+1], *NewChanged = new bool[n+1];
		long* Labels = new long[n+1];
		for (uint i=1; i<=n; i++) Labels[i] = Edges[i].Label;
		Found = false;
		for (uint i=1; i<=n; i++) if (IntersectsP(i) && !IsPeripheral(i))
		//Does edges[i], which emanates from P, lie in an invariant subgraph which drs onto P?
		{
			for (uint j=1; j<=n; j++)
			{
				Inset[j] = Changed[j] = NewChanged[j] = false;
				if (IsPeripheral(j)) Inset[j] = true;
			}
			Inset[i] = Changed[i] = true;
			bool SomeChanged = true, Bad = false;
			while (SomeChanged && !Bad)
			{
				for (uint j=i; j<=n; j++) if (Changed[j])
				{
					intarray& Im = Edges[j].Image;
					for (uint k=1; long(k)<=Im.TopIndex(); k++)
					{
						uint Index = FindEdge(Im[k]);
						if (Index < i && !IsPeripheral(Index))
						{
							Bad = true;
							break;
						}
						if (!Inset[Index])
						{
							Inset[Index] = true;
							NewChanged[Index] = true;
						}
					}
					if (Bad) break;
				}
				if (Bad) break;
				SomeChanged = false;
				for (uint j=1; j<=n; j++)
				{
					Changed[j] = NewChanged[j];
					if (NewChanged[j]) SomeChanged = true;
					NewChanged[j] = false;
				}
			}
			if (!Bad && RetractsOntoP(Inset, n))
			{
				Found = true;
				Result = true;
				//Collapse edges in Inset, pushing images anywhere but into P
				for (uint j=1; j<=n; j++) if (Inset[j] && !IsPeripheral(Labels[j]))
				{
					uint Index = FindEdge(Labels[j]);
					if (OnP(Edges[Index].Start)) Push(-Labels[j], Edges[Index].Image.TopIndex());
					else Push(Labels[j], Edges[Index].Image.TopIndex());
					Collapse(Labels[j]);
				}
				PullTight();
			}
			if (Found) break;
		}
		delete[] Labels; delete[] Inset; delete[] Changed; delete[] NewChanged;
	}
	//Now there are no invariant subgraphs which deformation retract onto P other than P
	//Modify the graph structure at each peripheral loop in turn


	if (!NeedToAbsorb())	return Result;
	Result = true;
	uint Count = 0;
	do { //while need to absorb
		if (Count++ > 1) THROW("Problems absorbing",1);
		for (uint i=1; i<=Punctures; i++) //Work at each puncture in turn
		{
			intarray EdgesOut; //Will hold edges out of peripheral loop in cyclic order
			intarray Separators; // Separators[j] = 1 iff edge j is separated from next round by peripheral edge
			//Find some vertex on this loop
			uint j=1;
			while (OnP(Vertices[j].Label) != i) j++;
			uint VertexIndex = j;
			do { //while not back to j again
				intarray& Round = Vertices[VertexIndex].Edges;
				//Start with edge first after peripheral in
				uint k = 1; while (!IsPeripheral(Round[k]) || Round[k]>0) k++;
				k= (long(k)==Round.TopIndex()) ? 1 : k+1;
				while (!IsPeripheral(Round[k]))
				{
					EdgesOut.Add(Round[k]);
					Separators[Separators.TopIndex()+1] = 0;
					k = (long(k)==Round.TopIndex()) ? 1 : k+1;
				}
				Separators[Separators.TopIndex()] = 1;
				VertexIndex = FindVertex(To(Round[k]));
			} while (VertexIndex != j);
			if (EdgesOut.TopIndex() == 1) continue; //No action when only one edge from loop
			//Now determine equivalence classes in EdgesOut INEFFICIENT
			intarray Class; //Will hold AltDeriv(corresponding edge, 2*number edges) which determines class
			for (j=1; long(j)<=EdgesOut.TopIndex(); j++)
			{
				long ClassNo = AltDerivative(EdgesOut[j],2*NumberEdges()-Punctures);
				if (!ClassNo) THROW("Altderivative giving undefined result",1);
				Class[j] = ClassNo;
			}
			intarray ClassLabels; //Will hold possible labels for equivalence classes
			for (j=1; long(j)<=Class.TopIndex(); j++)
				if (ClassLabels.Find(Class[j]) == -1) ClassLabels[ClassLabels.TopIndex()+1] = Class[j];
			//If at least 2 classes, insert zero-image edges to separate classes, and push from edges within classes
			if (ClassLabels.TopIndex() > 1)
			{
				for (j=1; long(j)<=EdgesOut.TopIndex(); j++)
				{
					uint k = (long(j)==EdgesOut.TopIndex()) ? 1 : j+1;
					if (Class[j] != Class[k] && !Separators[j])
					{
						//First change graph
						long NewEdgeLabel = NextEdgeLabel++;
						uint NewVertexLabel = NextVertexLabel++;
						edge& NewEdge = Edges[Edges.TopIndex()+1];
						vertex& NewVertex = Vertices[Vertices.TopIndex()+1];
						uint OldVertexLabel = From(EdgesOut[j]);
						vertex& OldVertex = Vertices[FindVertex(OldVertexLabel)];
						//Set up new edge
						NewEdge.Type = Peripheral;
						NewEdge.Puncture = i;
						NewEdge.Start = OldVertexLabel;
						NewEdge.End = NewVertexLabel;
						NewEdge.Label = NewEdgeLabel;
						NewEdge.Image.Flush();
						//Set up new vertex and change edges round old vertex, and ends of edges to old vertex
						NewVertex.Label = NewVertexLabel;
						NewVertex.Image = OldVertex.Image;
						NewVertex.Edges.Flush();
						intarray& OldEdgesRound = OldVertex.Edges;
						uint l = uint(OldEdgesRound.Find(EdgesOut[k]));
						uint Startl = l;
						while (1)
						{
							long Now = OldEdgesRound[l];
							NewVertex.Edges.Add(Now);
							if (Now>0) Edges[FindEdge(Now)].Start = NewVertexLabel;
							else Edges[FindEdge(Now)].End = NewVertexLabel;
							if (IsPeripheral(Now)) break;
							l++;
							if (long(l)>OldEdgesRound.TopIndex()) l=1;
						}
						NewVertex.Edges.Add(-NewEdgeLabel);
						OldEdgesRound[Startl] = NewEdgeLabel;
						for (l=1; long(l)<=OldEdgesRound.TopIndex(); )
						{
							if (NewVertex.Edges.Find(OldEdgesRound[l]) != -1) OldEdgesRound.Remove(l);
							else l++;
						}
						//Now change graph map. Start with vertex images
						for (l=1; l<=NumberVertices(); l++)
							if (Vertices[l].Image == OldVertexLabel) Vertices[l].Image = NewVertexLabel;
						//Then do the edge images
						for (l=1; l<=NumberEdges(); l++)
						{
							intarray& NowImage = Edges[l].Image;
							for (uint m=1; long(m)<NowImage.TopIndex(); m++)
							{
                                long Temp=-NowImage[m], Temp2=-NewEdgeLabel;
								if (OldEdgesRound.Find(Temp) != -1 // Comes from j group
								  &&NewVertex.Edges.Find(NowImage[m+1]) != -1) //Goes to k group
									 NowImage.Insert(++m, NewEdgeLabel);
								else if (NewVertex.Edges.Find(Temp) != -1 //Comes from k group
										 &&OldEdgesRound.Find(NowImage[m+1]) != -1) //Goes to j group
											NowImage.Insert(++m, Temp2);
							}
							if (!NowImage.TopIndex()) continue;
                            long Temp=-NewEdgeLabel, Temp2=-NowImage[NowImage.TopIndex()];
							if (OldEdgesRound.Find(NowImage[1])!=-1) NowImage.Insert(1, Temp);
							if (OldEdgesRound.Find(Temp2)!=-1) NowImage.SureAdd(NewEdgeLabel);
						}
					}
				} // Finished adding new zero-image edges.
				//Push from peripheral edges separating same equivalence class, and collapse
				for (j=1; long(j)<=EdgesOut.TopIndex(); j++)
				{
					uint k = (long(j)==EdgesOut.TopIndex()) ? 1 : j+1;
					if (Class[j] == Class[k] && From(EdgesOut[j]) != From(EdgesOut[k]))
					{
						//Find peripheral edge going from j vertex to k vertex
						intarray& EdgesRoundj = Vertices[FindVertex(From(EdgesOut[j]))].Edges;
						uint l=1;
						while (EdgesRoundj[l]<0 || !IsPeripheral(EdgesRoundj[l])) l++;
						//Push all at k vertex, and collapse
						long SeparatingEdgeLabel = EdgesRoundj[l];
						Push(-SeparatingEdgeLabel, Edges[FindEdge(SeparatingEdgeLabel)].Image.TopIndex());
						Collapse(SeparatingEdgeLabel);
					}
				}
				//Now have correct structure at this puncture
			}
			else
			{
				//Case with only one equivalence class
				//Determine between which edges peripheral loop should lie
				intarray L; //Holds turn germ
				bool IncludePeripheral = false;
				for (j=1; long(j)<=EdgesOut.TopIndex(); j++)
				{
					uint k = (long(j)==EdgesOut.TopIndex()) ? 1 : j+1;
					L.Flush();
					IncludePeripheral = false;
					L[1] = -EdgesOut[j];
					//Do we need to include peripheral edge from j to k
					intarray& EdgesAtj = Vertices[FindVertex(From(EdgesOut[j]))].Edges;
					uint m = uint(EdgesAtj.Find(EdgesOut[j]));
					uint Next = (long(m) == EdgesAtj.TopIndex()) ? 1 : m+1;
					if (!IsPeripheral(EdgesAtj[Next])) L[2] = EdgesOut[k];
					else
					{
						//Include peripheral edge joining j to k
						IncludePeripheral = true;
						L[2] = EdgesAtj[Next];
						L[3] = EdgesOut[k];
					}
					if (!Collapses(L)) break;
				}
				uint k = (long(j)==EdgesOut.TopIndex()) ? 1 : j+1;
				if (!IncludePeripheral)
				{
					//Insert zero-image edge between j and k
					//First change graph
						long NewEdgeLabel = NextEdgeLabel++;
						uint NewVertexLabel = NextVertexLabel++;
						edge& NewEdge = Edges[Edges.TopIndex()+1];
						vertex& NewVertex = Vertices[Vertices.TopIndex()+1];
						uint OldVertexLabel = From(EdgesOut[j]);
						vertex& OldVertex = Vertices[FindVertex(OldVertexLabel)];
						//Set up new edge
						NewEdge.Type = Peripheral;
						NewEdge.Puncture = i;
						NewEdge.Start = OldVertexLabel;
						NewEdge.End = NewVertexLabel;
						NewEdge.Label = NewEdgeLabel;
						NewEdge.Image.Flush();
						//Set up new vertex and change edges round old vertex, and ends of edges to old vertex
						NewVertex.Label = NewVertexLabel;
						NewVertex.Image = OldVertex.Image;
						NewVertex.Edges.Flush();
						intarray& OldEdgesRound = OldVertex.Edges;
						uint l = uint(OldEdgesRound.Find(EdgesOut[k]));
						uint Startl = l;
						while (1)
						{
							long Now = OldEdgesRound[l];
							NewVertex.Edges.Add(Now);
							if (Now>0) Edges[FindEdge(Now)].Start = NewVertexLabel;
							else Edges[FindEdge(Now)].End = NewVertexLabel;
							if (IsPeripheral(Now)) break;
							l++;
							if (long(l)>OldEdgesRound.TopIndex()) l=1;
						}
						NewVertex.Edges.Add(-NewEdgeLabel);
						OldEdgesRound[Startl] = NewEdgeLabel;
						for (l=1; long(l)<=OldEdgesRound.TopIndex(); )
						{
							if (NewVertex.Edges.Find(OldEdgesRound[l]) != -1) OldEdgesRound.Remove(l);
							else l++;
						}
						//Now change graph map. Start with vertex images
						for (l=1; l<=NumberVertices(); l++)
							if (Vertices[l].Image == OldVertexLabel) Vertices[l].Image = NewVertexLabel;
						//Then do the edge images
						for (l=1; l<=NumberEdges(); l++)
						{
							intarray& NowImage = Edges[l].Image;
							for (uint m=1; long(m)<NowImage.TopIndex(); m++)
							{
                                long Temp=-NowImage[m], Temp2=-NewEdgeLabel;
								if (OldEdgesRound.Find(Temp) != -1 // Comes from j group
								  &&NewVertex.Edges.Find(NowImage[m+1]) != -1) //Goes to k group
									 NowImage.Insert(++m, NewEdgeLabel);
								else if (NewVertex.Edges.Find(Temp) != -1 //Comes from k group
										 &&OldEdgesRound.Find(NowImage[m+1]) != -1) //Goes to j group
											NowImage.Insert(++m, Temp2);
							}
							if (!NowImage.TopIndex()) continue;
                            long Temp=-NewEdgeLabel, Temp2= -NowImage[NowImage.TopIndex()];
							if (OldEdgesRound.Find(NowImage[1])!=-1) NowImage.Insert(1, Temp);
							if (OldEdgesRound.Find(Temp2)!=-1) NowImage.SureAdd(NewEdgeLabel);
						}
				} //Finished adding new edge
				//Now work around loop pushing and collapsing all edges except the one from j to k
				while (From(EdgesOut[j]) != From(EdgesOut[k]))
				{
					//Find Peripheral edge emanating from same vertex as k
					intarray& EdgesRoundk = Vertices[FindVertex(From(EdgesOut[k]))].Edges;
					uint l=1; while (!IsPeripheral(EdgesRoundk[l]) || EdgesRoundk[l]<0) l++;
					//Push and collapse it
					Push(EdgesRoundk[l], Edges[FindEdge(EdgesRoundk[l])].Image.TopIndex());
					Collapse(EdgesRoundk[l]);
				}
			}//End of one equivalence class case
		}
		// Kill all initial peripheral images from edges emanating from P
		for (uint i=1; i<=NumberEdges(); i++)
		{
			if (Edges[i].Type == Peripheral) continue;
			if (OnP(Edges[i].Start))
				while (IsPeripheral(Edges[i].Image[1])) Edges[i].Image.Remove(1);
			if (OnP(Edges[i].End))
				while (IsPeripheral(Edges[i].Image[Edges[i].Image.TopIndex()]))
					Edges[i].Image.Remove(Edges[i].Image.TopIndex());
		}
		// Correct images of peripheral edges and vertices
		for (uint i=1; i<=NumberEdges(); i++)
		{
			if (Edges[i].Type != Peripheral) continue;
			vertex& Start = Vertices[FindVertex(Edges[i].Start)];
			uint j=1; while (IsPeripheral(Start.Edges[j])) j++;
			uint ImVertexLabel = From(Derivative(Start.Edges[j]));
			Start.Image = ImVertexLabel;
			//Find peripheral edge starting at ImVertexLabel
			intarray& EdgesAtImage = Vertices[FindVertex(ImVertexLabel)].Edges;
			j=1; while (!IsPeripheral(EdgesAtImage[j]) || EdgesAtImage[j] < 0) j++;
			Edges[i].Image.Flush();
			Edges[i].Image[1] = EdgesAtImage[j];
		}
		PullTight();
	} while (NeedToAbsorb());
	return Result;
}

bool graph::MakeIrreducible()
{
	if (!Punctures) return false;
	intarray CurrentPreP, NextPreP;
	bool Changed = true;
	bool Result = false;
	while (Changed)
	{
		Changed = false;
		bool Finished = false;
		CurrentPreP.Flush();
		FindTypes();
		for (uint i=1; i<=NumberEdges(); i++) //Load up CurrentPreP with peripheral edges to start
			if (Edges[i].Type == Peripheral) CurrentPreP.SureAdd(Edges[i].Label);
		while (!Finished) //Loop until CurrentPreP is empty
		{
			for (uint i=1; i<=NumberVertices(); i++) //Look at each vertex for 2 edges with deriv in CurrentPreP
			{
				vertex& Now = Vertices[i];
				for (uint j=1; j<=Now.Valence(); j++)
				{
					uint k = (j == Now.Valence()) ? 1 : j+1;
					if (Derivative(Now.Edges[j]) != Derivative(Now.Edges[k])) continue;
					long AbsDeriv = Derivative(Now.Edges[j]);
					AbsDeriv = (AbsDeriv < 0) ? -AbsDeriv : AbsDeriv;
					if (CurrentPreP.Find(AbsDeriv) != -1)
					{
						Result = Changed = true;
						for (uint l=1; l<=NumberVertices(); l++) Vertices[l].Flag = false;
						FoldAsMuchAsPossible(Now.Edges[j], Now.Edges[k]);
						break;
					}
				}
				if (Changed) break;
			}
			if (Changed) break;
			NextPreP.Flush();
			for (uint i=1; i<=NumberEdges(); i++) //Load edges with image entirely in CurrentPreP
			{
				edge& Now = Edges[i];
				if (CurrentPreP.Find(Now.Label) != -1) continue;
				bool Include = true;
				for (uint j=1; long(j)<=Now.Image.TopIndex(); j++)
				{
					long AbsImage = (Now.Image[j]<0) ? -Now.Image[j] : Now.Image[j];
					if (CurrentPreP.Find(AbsImage) == -1) Include = false;
					if (!Include) break;
				}
				if (Include) NextPreP.SureAdd(Now.Label);
			}
			if (!NextPreP.TopIndex()) Finished = true;
			else CurrentPreP = NextPreP;
		}
		if (Changed)
		{
			while (PullTight() || CollapseInvariantForest() || AbsorbIntoP());
			if (!HasIrreducibleMatrix()) break;
		}
	}
	return Result;
}









turnlist::turnlist(uint s, uint d, uint o) : p(new turn[s]), next(NULL), size(s), delta(d), origin(o), MaxAssigned(-1) {};

																										 
turnlist::~turnlist() {if (next) next->turnlist::~turnlist(); delete [] p;}
																											
long turnlist::TopIndex() {return MaxAssigned+long(origin);}
																											  
turn& turnlist::operator [](uint i)
{                                                                                    
	return Element(i-origin);
}

turn& turnlist::Element(uint i)                                                           
{
	if (i > 30000) THROW("Array Index Out of Bounds", 1); 
	if (long(i) >= MaxAssigned) MaxAssigned = long(i);
	if (i<size) return p[i];                                                           
	if (next) return next->Element(i-size);
	uint growby = (delta > i-size+1) ? delta : i-size+1;                                 
	next = new turnlist(growby, delta);
	return next->Element(i-size);
}
																														  
uint turnlist::GetSize()
{                                                   
	if (!next) return size;
	return size + next->GetSize();                      
}
																			
void turnlist::Flush()
{
	if (next)
	{
		next->Flush();
		next->turnlist::~turnlist();
	}
	next = NULL;
	MaxAssigned = -1;
}                                                                  

turnlist::turnlist(turnlist& A) : p(new turn[A.GetSize()]),
		 next (NULL), size(A.GetSize()), delta(A.delta), origin(A.origin), MaxAssigned(A.MaxAssigned)
{
	for (uint i=0; long(i)<=A.MaxAssigned; i++) Element(i)=A.Element(i);               
}                                                   

turnlist& turnlist::operator=(turnlist& A)                        
{                                                      
	if (this == &A) return *this;
	Flush();                                              
	MaxAssigned = -1;
	for (int i=0; i<=A.MaxAssigned; i++) Element(i) = A.Element(i);
	return *this;                                                     
}


long turnlist::Find(turn& Value)                                               
{
	for (int i=0; i<=MaxAssigned; i++) if (Element(i) == Value) return (i+origin);  
	return -1;                                                                       
}
																												  
void turnlist::_Remove(uint i, uint d)                                                     
{
	if (long(i+d) > MaxAssigned) THROW("Trying to remove non-existent elements",1);             
	for (uint j=i+d+1; long(j)<=MaxAssigned; j++) Element(j-d-1)=Element(j);
	MaxAssigned -= (d+1);
}                                                                                           
																															
void turnlist::Remove(uint i, uint d)
{
	_Remove(i-origin, d);                           
}
																	  
void turnlist::Append(turnlist& A)                            
{
	for (uint i=0; long(i)<=A.MaxAssigned; i++)                
		if (MaxAssigned == -1) Element(0) = A.Element(i);  
		else Element(uint(MaxAssigned+1)) = A.Element(i);
}                                                          

void turnlist::Prepend(turnlist& A)
{                                                             
	long j = A.MaxAssigned; 
	if (j==-1) return;
	for (long i=MaxAssigned; i>=0; i--)
		Element(uint(i+j+1)) = Element(uint(i));  
	for (long i=0; i<=j; i++) Element(uint(i)) = A.Element(uint(i));
}                                                                 
																						 

void turnlist::_Split(uint i, turnlist& A)                                                         
{                                                                                           
	if (long(i)>MaxAssigned) THROW("Trying to split after end of array",1);
	A.Flush();
	uint k=0;                                 
	for (uint j=i+1; long(j)<=MaxAssigned; j++) A.Element(k++) = Element(j);
	MaxAssigned = long(i);                                                    
}

																								 
void turnlist::Split(uint i, turnlist& A)                                         
{
	_Split(i-origin, A);                                                     
}

void turnlist::Print(std::ostream& Out)                                                 
{                                                                               
	for (uint i=0; long(i)<=MaxAssigned; i++) Out << Element(i) << " ";
	Out << '\n';
}   


																															 
void turnlist::Rotate(long Angle)
{
	if (MaxAssigned <= 0) return;                     
	turnlist Temp = *this;                                   
	long Modulus = MaxAssigned+1;
	for (long i=0; i<=MaxAssigned; i++)
	{                                                       
		long j= (i+Angle) % Modulus;
		if (j<0) j+=Modulus;                                   
		Element(uint(i))=Temp.Element(uint(j));                 
	}
}  
																			  


void turnlist::Insert(uint i, turn& Value)
{                                              
	for (uint j = TopIndex()+1; j>i; j--) (*this)[j] = (*this)[j-1]; 
	(*this)[i] = Value;
}



bool turnlist::Agrees(uint i, turnlist& A)
{
	if (MaxAssigned < long(i)-1 || A.MaxAssigned < long(i)-1) return false;
	for (uint j=0; j<i; j++) if (!(Element(j) == A.Element(j))) return false;
	return true;
}

bool turnlist::Add(turn Value)
{
	if (Find(Value) != -1) return false;
	Element(uint(MaxAssigned+1)) = Value;
	return true;
}

void turnlist::SureAdd(turn Value)
{
	Element(uint(MaxAssigned+1)) = Value;
}

uint turnlist::AgreesTo(turnlist& A)
{
	long Size = (MaxAssigned > A.MaxAssigned) ? A.MaxAssigned : MaxAssigned;
	uint i; for (i=0; long(i)<=Size; i++) if (!(Element(i) == A.Element(i))) return i;
	return i;
}


void graph::Split(long Label)
{
	uint Index = FindEdge(Label);
	if (!Index) THROW("Trying to split non-existent edge",1);
	uint NewVertex = Vertices.TopIndex()+1, NewEdge = Edges.TopIndex()+1;
	vertex& V = Vertices[NewVertex];
	edge& E = Edges[NewEdge];
	(V.Edges).Flush();
	(E.Image).Flush();
	edge& OldE = Edges[Index];
	V.Label = NextVertexLabel++;
	V.Flag = E.Flag = false;
	E.Label = NextEdgeLabel++;
	E.Type = OldE.Type;
	E.Puncture = OldE.Puncture;
	if (Label>0)
	{
		E.Start = OldE.Start;
		E.End = V.Label;
		OldE.Start = V.Label;
		V.Edges[1] = Label;
		V.Edges[2] = -E.Label;
		uint VIndex = FindVertex(E.Start);
		V.Image = (Vertices[VIndex]).Image;
		(Vertices[VIndex].Edges).Replace(Label, E.Label);
		intarray Temp; Temp[1] = E.Label; Temp[2] = Label;
		Replace(Label, Temp);
	}
	else
	{
		E.Start = V.Label;
		E.End = OldE.End;
		OldE.End = V.Label;
		V.Edges[1] = E.Label;
		V.Edges[2] = Label;
		uint VIndex = FindVertex(E.End);
		V.Image = (Vertices[VIndex]).Image;
        long Tempo=-E.Label;
		(Vertices[VIndex].Edges).Replace(Label, Tempo);
		intarray Temp; Temp[1] = -E.Label; Temp[2] = Label;
		Replace(Label, Temp);
	}
}

void graph::Collapse(long Label)
{
	if (Label<0) Label = -Label;
	uint Index = FindEdge(Label);
	if (!Index) THROW("Trying to collapse non-existent edge",1);
	edge& E = Edges[Index];
	if (! (E.Image).TopIndex() == 0) THROW("Trying to collapse non-trivial edge",1);
	//First identify vertices at two ends of Edge
	uint StartIndex = FindVertex(E.Start), EndIndex = FindVertex(E.End);
	if (StartIndex == EndIndex) // Starts and ends at same vertex
	{
		Vertices[StartIndex].Edges.RemoveAll(Label);
	}
	else
	{
		uint i = Vertices[StartIndex].Edges.Find(Label);
        long Temp=-Label;
		uint j = Vertices[EndIndex].Edges.Find(Temp);
		Vertices[StartIndex].Edges.Rotate(i);
		Vertices[StartIndex].Edges.Remove(Vertices[StartIndex].Edges.TopIndex());
		Vertices[EndIndex].Edges.Rotate(j);
		Vertices[EndIndex].Edges.Remove(Vertices[EndIndex].Edges.TopIndex());
		Vertices[StartIndex].Edges.Append(Vertices[EndIndex].Edges);
		// Vertices with image E.End now have image E.Start
		vertexiterator I(Vertices);
		do
		{
			if (I.Now().Image == E.End) I.Now().Image = E.Start;
			I++;
		} while (!I.AtOrigin());
		//Edges with endpoints at E.End now have endpoints at E.Start
		edgeiterator J(Edges);
		uint start = E.Start, end = E.End;
		do
		{
			if (J.Now().Start == end) J.Now().Start = start;
			if (J.Now().End == end) J.Now().End = start;
			J++;
		} while (!J.AtOrigin());
		//Delete vertex from graph
		Vertices[EndIndex].Edges.Flush();
		Vertices.Remove(EndIndex);
	}
	//Next remove all occurences of Edge in other edge images
	RemoveAll(Label);
	//Finally delete edge from graph.
	Edges[Index].Image.Flush();
	Edges.Remove(Index);
}

void graph::Push(long Label, uint i)
{
	uint Index = FindEdge(Label);
	edge& E = Edges[Index];
	uint VertexLabel;
	if (E.Image.TopIndex() < long(i)) THROW("Trying to push more symbols than there are",1);
	if (i==0) return;
	intarray Pushed(i,1,1);
	if (Label > 0)
	{
		VertexLabel = E.Start;
		for (uint j=1; j<=i; j++) Pushed[j] = E.Image[j];
		E.Image.Remove(1,i-1);
	}
	else
	{
		VertexLabel = E.End;
		uint k=E.Image.TopIndex();
		for (uint j=1; j<=i; j++) Pushed[j] = -E.Image[k--];
		E.Image.Remove(k+1,i-1);
	}
	intarray PushedInverse = Pushed;
	PushedInverse.Invert();
	uint VIndex = FindVertex(VertexLabel);
	vertex& V = Vertices[VIndex];
	intiterator I(V.Edges);
	do
	{
		long ELabel = (I++);
		if (ELabel == Label) continue;
		uint EIndex = FindEdge(ELabel);
		edge& Now = Edges[EIndex];
		if (ELabel>0) Now.Image.Prepend(PushedInverse);
		else Now.Image.Append(Pushed);
	} while (!I.AtOrigin());
	Vertices[VIndex].Image = From(PushedInverse[1]);
}

void graph::Subdivide(long Label, uint i)
{
	Split(Label);
	Push(Label, i);
}

void graph::SubdivideAllBut(long Label, uint i)
{
	Split (Label);
	uint ImageSize = Edges[FindEdge(Label)].Image.TopIndex();
	if (i>ImageSize) THROW("Trying to subdivide at illegal position",1);
	Push(Label, ImageSize-i);
}

void graph::SubdivideHere(long Label, uint i)
{
	uint k=0;
	uint Index = FindEdge(Label);
	uint ImageSize = Edges[Index].Image.TopIndex();
	if (i>ImageSize) THROW("Trying to subdivide at illegal position",1);
	if (Label>0)
		for (uint j=1; j<=i; j++)
			if (Edges[Index].Image[j] == Label || Edges[Index].Image[j] == -Label) k++;
	if (Label<0)
		for (uint j=1; j<=i; j++)
			if (Edges[Index].Image[ImageSize+1-j] == Label || Edges[Index].Image[ImageSize+1-j] == -Label) k++;
	Split(Label);
	Push(Label, i+k);
}

bool graph::PullTight()
{
	bool Result = false;
	bool Changed = true;
	while (Changed)
	{
		Changed = Tighten(); // Pull tight edge images
		vertexiterator I(Vertices);
		do
		{
			vertex& Now = I++;
			if (Now.Edges.TopIndex() == 1) //Valence one vertex
			{
				uint Index = FindEdge(Now.Edges[1]);
				Edges[Index].Image.Flush();
				Now.Image = Vertices[FindVertex(To(Now.Edges[1]))].Image;
				Collapse(Now.Edges[1]);
				Changed = true;
				break;
			}
			bool CanTighten = true;
			long First = Derivative(Now.Edges[1]);
			if (!First)
			{
				CanTighten = false;
				break;
			}
			for (uint i=2; i<=Now.Valence(); i++) if (Derivative(Now.Edges[i]) != First)
			{
				CanTighten = false;
				break;
			}
			if (CanTighten)
			{
				Changed = true;
				Push(Now.Edges[1],1);
			}
		} while (!I.AtOrigin());
		if (Changed) Result = true;
	}
	return Result;
}

void graph::ValenceTwoIsotopy(long Label)
{
	uint Index = FindEdge(Label);
	uint VLabel = (Label>0) ? Edges[Index].Start : Edges[Index].End;
	uint VIndex = FindVertex(VLabel);
	if (!Vertices[VIndex].Valence() == 2)
		THROW("Performing valence two isotopy on wrong valence vertex",1);
	Push(Label, Edges[Index].Image.TopIndex());
	Collapse(Label);
}

void graph::ValenceTwoIsotopy(uint Label)
{
	uint Index = FindVertex(Label);
	if (!Vertices[Index].Valence() == 2)
		THROW("Performing valence two isotopy on wrong valence vertex",1);
	long Label1 = Vertices[Index].Edges[1], Label2 = Vertices[Index].Edges[2];
	uint Index1 = FindEdge(Label1), Index2 = FindEdge(Label2);
	//If one edge is preperipheral, perform isotopy across that edge
	FindTypes();
	if (Edges[Index1].Type == Preperipheral)
	{
		ValenceTwoIsotopy(Label1);
		return;
	}
	if (Edges[Index2].Type == Preperipheral)
	{
		ValenceTwoIsotopy(Label2);
		return;
	}
	//Determine which edge has greater eigenvector entry
	matrix M(*this);
	uint i1 = 0, i2 = 0, Count = 0; //i1 and i2 will give indices in M corresponding to two edges
	for (uint i=1; i<=NumberEdges(); i++) if (Edges[i].Type == Main)
	{
		if (i==Index1) i1 = Count;
		if (i==Index2) i2 = Count;
		Count++;
	}
	if (M.IsBigger(i1, i2)) ValenceTwoIsotopy(Label1);
	else ValenceTwoIsotopy(Label2);
}

void graph::FoldAsMuchAsPossible(long Label1, long Label2, bool Care)
{
        if (Care)
        {
           CarefulFoldAsMuchAsPossible(Label1, Label2);
           return;
        }
	//Check that two edges are at same vertex and have same derivative
	if (Label1 == Label2) THROW("Trying to fold edge with itself",1);
	if (!(From(Label1) == From(Label2))) THROW("Trying to fold edges at different vertices",1);
	if (!(Derivative(Label1) == Derivative(Label2))) THROW("Trying to fold edges with different derivatives",1);
	vertex& Vertex = Vertices[FindVertex(From(Label1))];
	uint Edge1Posn = Vertex.Edges.Find(Label1), Edge2Posn = Vertex.Edges.Find(Label2);
	if (Edge1Posn > Edge2Posn)
	{
		long Temp = Label1; Label1 = Label2; Label2 = Temp;
		uint Temp2 = Edge1Posn; Edge1Posn = Edge2Posn; Edge2Posn = Temp2;
	}
	uint n = Vertex.Valence();
	uint FoldDepth;
	bool* ToFold = new bool[n+1];
	for (uint j=1; j<=2; j++)
	{
		Label1 = Vertex.Edges[Edge1Posn]; Label2 = Vertex.Edges[Edge2Posn];
		edge &Edge1 = Edges[FindEdge(Label1)], &Edge2 = Edges[FindEdge(Label2)];
		intarray Edge1Image = Edge1.Image, Edge2Image = Edge2.Image;
		if (Label1<0) Edge1Image.Invert();
		if (Label2<0) Edge2Image.Invert();
		for (uint i=1; i<=n; i++) ToFold[i] = false;
		//Find out which way around vertex edges with same derivative go
		bool FoldBetween = true;
		long Deriv = Derivative(Label1);
		for (uint i = Edge1Posn+1; i<Edge2Posn; i++)
			if (Derivative(Vertex.Edges[i])!=Deriv) FoldBetween = false;
		if (FoldBetween)	for (uint i=Edge1Posn; i<=Edge2Posn; i++) ToFold[i] = true;
		else for (uint i=1; i<=n; i=(i==Edge1Posn) ? Edge2Posn : i+1) ToFold[i] = true;
		//How much can we fold?
		FoldDepth = Edge1Image.AgreesTo(Edge2Image);
		for (uint i=1; i<=n; i++) if (ToFold[i])
		{
			uint ImageLength = Edges[FindEdge(Vertex.Edges[i])].Image.TopIndex();
			if (ImageLength<FoldDepth) FoldDepth = ImageLength;
		}
		//Check if marked vertex is end of edge which is being fully folded
		bool Bad = false;
        uint i;
		for (i=1; i<=n; i++) if (ToFold[i])
		{
			uint EdgeIndex = FindEdge(Vertex.Edges[i]);
			uint EndVertIndex = FindVertex(To(Vertex.Edges[i]));
			if (Edges[EdgeIndex].Image.TopIndex() == long(FoldDepth) && Vertices[EndVertIndex].Flag)
			{
				Bad = true;
				break;
			}
		}
		if (!Bad) break;
		if (FoldDepth>1)
		{
			FoldDepth--;
			break;
		}
		if (j==2)
		{
			delete[] ToFold;
			THROW("Bad Edge not removed in FoldAsMuchAsPossible()",1);
		}
		uint BadEdgeIndex = FindEdge(Vertex.Edges[i]);
		edge& BadEdge = Edges[BadEdgeIndex];
		while (BadEdge.Image.TopIndex() == 1)
		{
			long Current = BadEdge.Image[1];
			edge CurrentEdge = Edges[FindEdge(Current)];
			while (CurrentEdge.Image.TopIndex() == 1)
			{
				Current = CurrentEdge.Image[1];
				CurrentEdge = Edges[FindEdge(Current)];
			}
			SubdivideHere(Current, 1);
		}
	}
	//Fold edges described in ToFold up to depth FoldDepth.
	//Subdivide each edge so they all have the same image
	for (uint i=1; i<=n; i++) if (ToFold[i])
	{
		long NowLabel = Vertex.Edges[i];
		uint NowIndex = FindEdge(NowLabel);
		if (Edges[NowIndex].Image.TopIndex() == long(FoldDepth)) continue;
		if (NowLabel>0)
		{
			uint Counter = 0;
			for (uint j=1; j<=FoldDepth; j++)
				if (Edges[NowIndex].Image[j]==NowLabel || Edges[NowIndex].Image[j]==-NowLabel) Counter++;
			SubdivideHere(NowLabel, FoldDepth);
			FoldDepth+=Counter;
		}
		else
		{
			uint Counter = 0;
			intarray Inverted = Edges[NowIndex].Image; Inverted.Invert();
			for (uint j=1; j<=FoldDepth; j++)
				if (Inverted[j]==NowLabel || Inverted[j]==-NowLabel) Counter++;
			SubdivideHere(NowLabel,FoldDepth);
			FoldDepth+=Counter;
		}
	}
	intarray FinalImage = Edges[FindEdge(Vertex.Edges[Edge1Posn])].Image;
	if (Vertex.Edges[Edge1Posn]<0) FinalImage.Invert();
	//Create new edge and vertex
	long NewEdgeIndex = Edges.TopIndex()+1;
	uint NewVertexIndex = Vertices.TopIndex()+1;
	edge& NewEdge = Edges[NewEdgeIndex];
	vertex& NewVertex = Vertices[NewVertexIndex];
	NewEdge.Label = NextEdgeLabel++;
	NewVertex.Label = NextVertexLabel++;
	NewEdge.Type = Main;
	NewEdge.Start = Vertex.Label;
	NewEdge.End = NewVertex.Label;
	NewEdge.Image.Flush();
	NewEdge.Flag = NewVertex.Flag = false;
	NewVertex.Image = Vertex.Image;
	NewVertex.Edges.Flush();
	bool NewAdded = false;
	uint j=1;
	for (uint i=1; i<=n; i++)
	{
		if (ToFold[i]) NewVertex.Edges[j++] = Vertex.Edges[i];
		else if (!NewAdded)
		{
			NewAdded = true;
			NewVertex.Edges[j++] = -NewEdge.Label;
		}
	}
	if (!NewAdded) NewVertex.Edges[j] = -NewEdge.Label;
	intarray NewEdgesRound;
	NewAdded = false; j=1;
	for (uint i=1; i<=n; i++)
	{
		if (!ToFold[i]) NewEdgesRound[j++] = Vertex.Edges[i];
		else if (!NewAdded)
		{
			NewAdded = true;
			NewEdgesRound[j++] = NewEdge.Label;
		}
	}
	if (!NewAdded) NewEdgesRound[j] = NewEdge.Label;
	Vertex.Edges = NewEdgesRound;
	//Edges mapping over each of edges to be folded have image changed and set images of edges round new vertex
	NewEdge.Image = FinalImage;
	NewVertex.Image = To(FinalImage[FinalImage.TopIndex()]);
	intarray L, M; //M keeps track of labels to be flushed
	L[1] = NewEdge.Label;
	intiterator I(NewVertex.Edges);
	do
	{
		long NowLabel = I++;
		if (NowLabel != -NewEdge.Label)
		{
			L[2] = NowLabel;
			M.Add(NowLabel);
			Replace(NowLabel, L);
			edge& NowEdge = Edges[FindEdge(NowLabel)];
			NowEdge.Image.Flush();
			if (NowLabel>0) NowEdge.Start = NewVertex.Label;
			else NowEdge.End = NewVertex.Label;
		}
	} while (!I.AtOrigin());
	//Collapse each of the folded edges
	intiterator J(M);
	do Collapse(J++); while (!J.AtOrigin());
	delete [] ToFold;
}




void graph::CarefulFoldAsMuchAsPossible(long Label1, long Label2)
{
	//Check that two edges are at same vertex and have same derivative
	if (Label1 == Label2) THROW("Trying to fold edge with itself",1);
	if (!(From(Label1) == From(Label2))) THROW("Trying to fold edges at different vertices",1);
	if (!(Derivative(Label1) == Derivative(Label2))) THROW("Trying to fold edges with different derivatives",1);
	vertex& Vertex = Vertices[FindVertex(From(Label1))];
	uint Edge1Posn = Vertex.Edges.Find(Label1), Edge2Posn = Vertex.Edges.Find(Label2);
	if (Edge1Posn > Edge2Posn)
	{
		long Temp = Label1; Label1 = Label2; Label2 = Temp;
		uint Temp2 = Edge1Posn; Edge1Posn = Edge2Posn; Edge2Posn = Temp2;
	}
	uint n = Vertex.Valence();
	uint FoldDepth;
	bool* ToFold = new bool[n+1];
	for (uint j=1; j<=2; j++)
	{
		Label1 = Vertex.Edges[Edge1Posn]; Label2 = Vertex.Edges[Edge2Posn];
		edge &Edge1 = Edges[FindEdge(Label1)], &Edge2 = Edges[FindEdge(Label2)];
		intarray Edge1Image = Edge1.Image, Edge2Image = Edge2.Image;
		if (Label1<0) Edge1Image.Invert();
		if (Label2<0) Edge2Image.Invert();
		for (uint i=1; i<=n; i++) ToFold[i] = false;
		//Find out which way around vertex edges with same derivative go
		bool FoldBetween = true;
		long Deriv = Derivative(Label1);
		for (uint i = Edge1Posn+1; i<Edge2Posn; i++)
			if (Derivative(Vertex.Edges[i])!=Deriv) FoldBetween = false;
		if (FoldBetween)	for (uint i=Edge1Posn; i<=Edge2Posn; i++) ToFold[i] = true;
		else for (uint i=1; i<=n; i=(i==Edge1Posn) ? Edge2Posn : i+1) ToFold[i] = true;
		//How much can we fold?
		FoldDepth = Edge1Image.AgreesTo(Edge2Image);
		for (uint i=1; i<=n; i++) if (ToFold[i])
		{
			uint ImageLength = Edges[FindEdge(Vertex.Edges[i])].Image.TopIndex();
			if (ImageLength<FoldDepth) FoldDepth = ImageLength;
		}
		//Check if marked vertex is end of edge which is being fully folded
		bool Bad = false;
                uint i;
		for (i=1; i<=n; i++) if (ToFold[i])
		{
			uint EdgeIndex = FindEdge(Vertex.Edges[i]);
			uint EndVertIndex = FindVertex(To(Vertex.Edges[i]));
			if (Edges[EdgeIndex].Image.TopIndex() == long(FoldDepth) && Vertices[EndVertIndex].Flag)
			{
				Bad = true;
				break;
			}
		}
		if (!Bad) break;
                uint BadEdgeIndex = FindEdge(Vertex.Edges[i]);
		edge& BadEdge = Edges[BadEdgeIndex];
                FindTypes(); //NEW
		if (FoldDepth>1)
                {
                   bool CanReduce = false;   //Can't afford to fold only preperipheral edges
                   if (Vertex.Edges[i]>0)
                   {
                      for (uint k=1; k<FoldDepth; k++) if (Edges[FindEdge(BadEdge.Image[k])].Type == Main) CanReduce = true;
                   }
                   else
                   {
                      for (uint k=BadEdge.Image.TopIndex(); k>BadEdge.Image.TopIndex()-FoldDepth+1; k--)
                         if (Edges[FindEdge(BadEdge.Image[k])].Type == Main) CanReduce = true;
                   }
                   if (CanReduce)
		   {
			FoldDepth--;
			break;
		   }
                }
		if (j==2)
		{
			delete[] ToFold;
			THROW("Bad Edge not removed in FoldAsMuchAsPossible()",1);
		}

		while (BadEdge.Image.TopIndex() == 1)
		{
			long Current = BadEdge.Image[1];
			edge CurrentEdge = Edges[FindEdge(Current)];
			while (CurrentEdge.Image.TopIndex() == 1)
			{
				Current = CurrentEdge.Image[1];
				CurrentEdge = Edges[FindEdge(Current)];
			}
                        uint Place = 1;
                        long Guard = CurrentEdge.Image.TopIndex();
                        if (Current>0)
                        {
                           while (Edges[FindEdge(CurrentEdge.Image[Place])].Type != Main)
                              Place++;
                        }
                        else
                        {
                           while (Edges[FindEdge(CurrentEdge.Image[Guard-Place+1])].Type != Main)
                              Place++;
                        }
                        if (long(Place) >= Guard) THROW("Can't find an edge to fold!",4);
			SubdivideHere(Current, Place);
		}
	}
	//Fold edges described in ToFold up to depth FoldDepth.
	//Subdivide each edge so they all have the same image
	for (uint i=1; i<=n; i++) if (ToFold[i])
	{
		long NowLabel = Vertex.Edges[i];
		uint NowIndex = FindEdge(NowLabel);
		if (Edges[NowIndex].Image.TopIndex() == long(FoldDepth)) continue;
		if (NowLabel>0)
		{
			uint Counter = 0;
			for (uint j=1; j<=FoldDepth; j++)
				if (Edges[NowIndex].Image[j]==NowLabel || Edges[NowIndex].Image[j]==-NowLabel) Counter++;
			SubdivideHere(NowLabel, FoldDepth);
			FoldDepth+=Counter;
		}
		else
		{
			uint Counter = 0;
			intarray Inverted = Edges[NowIndex].Image; Inverted.Invert();
			for (uint j=1; j<=FoldDepth; j++)
				if (Inverted[j]==NowLabel || Inverted[j]==-NowLabel) Counter++;
			SubdivideHere(NowLabel,FoldDepth);
			FoldDepth+=Counter;
		}
	}
	intarray FinalImage = Edges[FindEdge(Vertex.Edges[Edge1Posn])].Image;
	if (Vertex.Edges[Edge1Posn]<0) FinalImage.Invert();
	//Create new edge and vertex
	long NewEdgeIndex = Edges.TopIndex()+1;
	uint NewVertexIndex = Vertices.TopIndex()+1;
	edge& NewEdge = Edges[NewEdgeIndex];
	vertex& NewVertex = Vertices[NewVertexIndex];
	NewEdge.Label = NextEdgeLabel++;
	NewVertex.Label = NextVertexLabel++;
	NewEdge.Type = Main;
	NewEdge.Start = Vertex.Label;
	NewEdge.End = NewVertex.Label;
	NewEdge.Image.Flush();
	NewEdge.Flag = NewVertex.Flag = false;
	NewVertex.Image = Vertex.Image;
	NewVertex.Edges.Flush();
	bool NewAdded = false;
	uint j=1;
	for (uint i=1; i<=n; i++)
	{
		if (ToFold[i]) NewVertex.Edges[j++] = Vertex.Edges[i];
		else if (!NewAdded)
		{
			NewAdded = true;
			NewVertex.Edges[j++] = -NewEdge.Label;
		}
	}
	if (!NewAdded) NewVertex.Edges[j] = -NewEdge.Label;
	intarray NewEdgesRound;
	NewAdded = false; j=1;
	for (uint i=1; i<=n; i++)
	{
		if (!ToFold[i]) NewEdgesRound[j++] = Vertex.Edges[i];
		else if (!NewAdded)
		{
			NewAdded = true;
			NewEdgesRound[j++] = NewEdge.Label;
		}
	}
	if (!NewAdded) NewEdgesRound[j] = NewEdge.Label;
	Vertex.Edges = NewEdgesRound;
	//Edges mapping over each of edges to be folded have image changed and set images of edges round new vertex
	NewEdge.Image = FinalImage;
	NewVertex.Image = To(FinalImage[FinalImage.TopIndex()]);
	intarray L, M; //M keeps track of labels to be flushed
	L[1] = NewEdge.Label;
	intiterator I(NewVertex.Edges);
	do
	{
		long NowLabel = I++;
		if (NowLabel != -NewEdge.Label)
		{
			L[2] = NowLabel;
			M.Add(NowLabel);
			Replace(NowLabel, L);
			edge& NowEdge = Edges[FindEdge(NowLabel)];
			NowEdge.Image.Flush();
			if (NowLabel>0) NowEdge.Start = NewVertex.Label;
			else NowEdge.End = NewVertex.Label;
		}
	} while (!I.AtOrigin());
	//Collapse each of the folded edges
	intiterator J(M);
	do Collapse(J++); while (!J.AtOrigin());
	delete [] ToFold;
}




void graph::UserInput()
{
	Flush();
	uint EdgeNo = 0, VertexNo = 0;
	Type = Unknown;
	std::cout << "Please ensure: i) that the edges around each vertex are given in their correct\n";
	std::cout << "cyclic (anticlockwise) order; and ii) that the graph map you enter can be\n";
	std::cout << "realised by an orientation-preserving surface homeomorphism.\n";
	std::cout << "Results are undefined if these rules are broken.\n\n";
	std::cout << "Enter number of peripheral loops, edges and vertices: ";
	std::cin >> Punctures >> EdgeNo >> VertexNo;
	std::cout << '\n';
	if (!EdgeNo || !VertexNo) THROW("Graph must have at least one edge and vertex", 0);
	NextEdgeLabel = EdgeNo+1; NextVertexLabel = VertexNo+1;
	uint *EdgeStart = new uint[EdgeNo+1], *EdgeEnd = new uint[EdgeNo+1];
    uint i;
	for (i=1; i<=EdgeNo; i++) EdgeStart[i] = EdgeEnd[i] = 0;
	for (i=1; i<=VertexNo; i++)
	{
		vertex& Now = Vertices[i];
		Now.Edges.Flush();
		std::cout << "Vertex number " << i << ":\n";
		Now.Label = i;
		std::cout << "Image vertex: ";
		std::cin >> Now.Image;
		if (Now.Image<1 || Now.Image>VertexNo)
		{
			delete[] EdgeStart; delete[] EdgeEnd;
			THROW("Vertex label out of range",0);
		}
		std::cout << "Enter labels of edges at vertex in cyclic order, ending with 0:\n";
		long Image;
		uint j=1;
		do {
			std::cin >> Image;
			if (Image == 0) continue;
			if (Image > 0)
			{
				if (Image > long(EdgeNo))
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Edge label out of range",0);
				}
				if (EdgeStart[Image])
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Edge start already assigned",0);
				}
				EdgeStart[Image] = i;
				Now.Edges[j++] = Image;
			}
			else
			{
				if (-Image > long(EdgeNo))
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Edge label out of range",0);
				}
				if (EdgeEnd[-Image])
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Edge end already assigned",0);
				}
				EdgeEnd[-Image] = i;
				Now.Edges[j++] = Image;
			}
		} while (Image != 0);
	}
	for (i=1; i<=EdgeNo; i++)
	{
		if (!(EdgeStart[i] && EdgeEnd[i]))
		{
			delete[] EdgeStart; delete[] EdgeEnd;
			THROW("Ends of edge not resolved",0);
		}
		Edges[i].Start = EdgeStart[i];
		Edges[i].End = EdgeEnd[i];
	}
	for (i=1; i<=EdgeNo; i++)
	{
		edge& Now = Edges[i];
		Now.Image.Flush();
		std::cout << "Edge number " << i << " from " << Now.Start << " to " << Now.End <<":\n";
		Now.Label = i;
		if (Punctures)
		{
			int IsPeripheral;
			std::cout << "Enter 1 if peripheral, 0 otherwise: ";
			std::cin >> IsPeripheral;
			if (IsPeripheral)
			{
				Now.Type = Peripheral;
				std::cout << "Enter puncture which edge is about: ";
				std::cin >> Now.Puncture;
				if (Now.Puncture<1 || Now.Puncture>Punctures)
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Puncture out of range",0);
				}
			}
			else Now.Type = Main;
		}
		else Now.Type = Main;
		std::cout << "Enter labels of image edges, ending with 0:\n";
		long Image;
		uint j=1;
		do {
			std::cin >> Image;
			if (Image == 0) continue;
			if (Image > 0)
			{
				if (Image > long(EdgeNo))
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Edge label out of range",0);
				}
				Now.Image[j++] = Image;
			}
			else
			{
				if (-Image > long(EdgeNo))
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Edge label out of range",0);
				}
				Now.Image[j++] = Image;
			}
		} while (Image != 0);
		(Now.Image).Tighten();
	}
	delete [] EdgeStart;
	delete [] EdgeEnd;
	OrientPeripheralEdges();
	if (!SanityCheck()) THROW("Insane graph map",0);
}

void graph::Set(braid& B)
{
	if (B.Size() < 3) THROW("Braid should have at least three strings",0);
	Flush();
	IdentityGraph(B.Size());
	for (uint i=1; i<=B.Length(); i++)
	{
		ActOn(B[i]);
		Tighten();
	}
	ReLabel();
}

void graph::Print(std::ostream& Out)
{
   FindTypes();
	Out << "Graph on surface with " << Punctures << " peripheral loops:\n";
	vertexiterator I(Vertices);
	do
	{
		(I++).Print(Out);
	} while (!I.AtOrigin());
	edgeiterator J(Edges);
	do
	{
		(J++).Print(Out);
	} while (!J.AtOrigin());
	switch(Type)
	{
		case fo:
			Out << "Finite order Isotopy class\n";
			break;

		case Reducible1:
			Out << "Reducible Isotopy class\n";
			Out << "The following main edges and their images constitute an invariant subgraph:\n";
			PrintReduction(Out);
			break;

		case Reducible2:
			Out << "Reducible Isotopy class\n";
			PrintGates(Out);
			break;

		case pA:
			Out << "Pseudo-Anosov Isotopy class\n";
			PrintGates(Out);
			break;
			
		default: ;
	}
}

graph::graph(braid &B)
{
	if (B.Size() < 3) THROW("Braid should have at least three strings",0);
	IdentityGraph(B.Size());
	for (uint i=1; i<=B.Length(); i++)
	{
		ActOn(B[i]);
		Tighten();
	}
	ReLabel();
}

void graph::IdentityGraph(uint n)
{
	Flush();
	Punctures = n;
	NextEdgeLabel = 2*n;
	NextVertexLabel = n;
	Type = Unknown;
	// Set up Vertices
    uint i;
	for (i=1; i<=n; i++)
	{
		vertex &Now = Vertices[i];
		Now.Edges.Flush();
		Now.Label = i;
		Now.Image = i;
		if (i==1)
		{
			Now.Edges[1] = 1;
			Now.Edges[2] = -1;
			Now.Edges[3] = n+1;
			continue;
		}
		if (i==n)
		{
			Now.Edges[1] = n;
			Now.Edges[2] = -long(n);
			Now.Edges[3] = -long(2*n-1);
			continue;
		}
		Now.Edges[1] = i;
		Now.Edges[2] = -long(i);
		Now.Edges[3] = i+n;
		Now.Edges[4] = -long(i+n-1);
	}
	// Set up Peripheral Edges
	for (i=1; i<=n; i++)
	{
		edge &Now = Edges[i];
		Now.Image.Flush();
		Now.Label = i;
		Now.Type = Peripheral;
		Now.Puncture = i;
		Now.Start = i;
		Now.End = i;
		Now.Image[1] = i;
	}
	// Set up Main Edges
	for (i=n+1; i<2*n; i++)
	{
		edge &Now = Edges[i];
		Now.Image.Flush();
		Now.Label = i;
		Now.Type = Main;
		Now.Start = i-n;
		Now.End = i-n+1;
		Now.Image[1] = i;
	}
}

void graph::ActOn(long Gen)
{
	intarray Temp;
	long n = long(Punctures);
	long i = (Gen>0) ? Gen : -Gen;
	VertexImageSwap(i, i+1);
	if (Gen == 1)
	{
		Temp[1] = -(n+1);
		Temp[2] = -1;
		Replace(n+1, Temp);
		Temp[1] = n+1;
		Temp[2] = n+2;
		Replace(n+2, Temp);
		return;
	}
	if (Gen == -1)
	{
		Temp[1] = -(n+1);
		Replace(n+1, Temp);
		Temp[1] = n+1;
		Temp[2] = 2;
		Temp[3] = n+2;
		Replace(n+2,Temp);
		return;
	}
	if (Gen == n-1)
	{
		Temp[1] = -(2*n-1);
		Replace(2*n-1, Temp);
		Temp[1] = 2*n-2;
		Temp[2] = n-1;
		Temp[3] = 2*n-1;
		Replace(2*n-2, Temp);
		return;
	}
	if (Gen == -(n-1))
	{
		Temp[1] = -n;
		Temp[2] = -(2*n-1);
		Replace(2*n-1, Temp);
		Temp[1] = 2*n-2;
		Temp[2] = 2*n-1;
		Replace(2*n-2, Temp);
		return;
	}
	if (Gen > 0)
	{
		Temp[1] = -(i+n);
		Temp[2] = -i;
		Replace(i+n, Temp);
		Temp[1] = i+n;
		Temp[2] = i+n+1;
		Replace(i+n+1, Temp);
		Temp[1] = (i+n-1);
		Temp[2] = i;
		Temp[3] = i+n;
		Replace(i+n-1, Temp);
		return;
	}
	if (Gen < 0)
	{
		Temp[1] = -(i+1);
		Temp[2] = -(i+n);
		Replace(i+n, Temp);
		Temp[1] = i+n-1;
		Temp[2] = i+n;
		Replace(i+n-1, Temp);
		Temp[1] = i+n;
		Temp[2] = i+1;
		Temp[3] = i+n+1;
		Replace(i+n+1, Temp);
		return;
	}
}

void graph::VertexImageSwap(uint i, uint j)
{
    uint k;
	for (k=1; k<=Punctures; k++)
	{
		if (Vertices[k].Image == i)
		{
			Vertices[k].Image = j;
			Edges[k].Image[1] = j;
		}
		else if (Vertices[k].Image == j)
		{
			Vertices[k].Image = i;
			Edges[k].Image[1] = i;
		}
	}
	for (k=1; k<Punctures; k++)
	{
		intarray& Im = Edges[Punctures+k].Image;
		for (uint l=1; long(l)<=Im.TopIndex(); l++)
		{
			if (Im[l] == long(i)) Im[l] = j;
			else if (Im[l] == long(j)) Im[l] = i;
			if (Im[l] == -long(i)) Im[l] = -long(j);
			else if (Im[l] == -long(j)) Im[l] = -long(i);
		}
	}
}

void graph::PrintTurns(std::ostream& Out)
{
	FindTurns();
	for (uint i=1; long(i)<=Turns.TopIndex(); i++) Out << Turns[i] << '\n';
}

void graph::PrintGates(std::ostream& Out)
{
	if (Type != pA && Type != Reducible2)
		THROW("Trying to print gates with unsuitable graph map", 1);
	for (uint i=1; i<=NumberVertices(); i++)
	{
		uint Label = Vertices[i].Label;
		Out << "Vertex " << Label << ":\nGates are: ";
		uint j=5; while (Reduction[j-3] || Reduction[j-2]!=long(Label) || Reduction[j-4]) j++;
		Out << '{';
		bool Finished = false;
		while (!Finished)
		{
			Out << Reduction[j];
			if (Reduction[++j]) Out << ", ";
			else
			{
				if (Reduction[++j]) Out << "}, {";
				else
				{
					Finished = true;
					Out << "}\n";
					j++;
				}
			}
		}
		Out << "Infinitesimal edges join ";
		bool First = true;
		for (j=1; long(j)<=Turns.TopIndex(); j++)
		{
			if (Turns[j].Level == Label)
			{
				if (First) First = false;
				else Out << ", ";
				Out << Turns[j].i << " to " << Turns[j].j;
			}
		}
		Out << '\n';
	}
}



void graph::ReLabel()
{
	FindTypes();
	uint ENo = NumberEdges(), VNo = NumberVertices();
	long *OldLabel = new long[ENo+1];
	uint i=1;
	//Start with peripheral edges about punctures in ascending order
    uint j;
	for (j=1; j<=Punctures; j++)
		for (uint k=1; k<=ENo; k++)
			if (Edges[k].Type == Peripheral && Edges[k].Puncture == j)
				OldLabel[i++] = Edges[k].Label;
	//Next preperipheral edges
	for (j=1; j<=ENo; j++)
		if (Edges[j].Type == Preperipheral) OldLabel[i++] = Edges[j].Label;
	//Finally main edges
	for (j=1; j<=ENo; j++)
		if (Edges[j].Type == Main) OldLabel[i++] = Edges[j].Label;
	//Error check
	if (i != ENo+1)
	{
		delete[] OldLabel;
		THROW("Something very wrong in ReLabel",1);
	}
	//Change edge labels
	for (i=1; i<=ENo; i++)
	{
		j=1; while (Edges[i].Label != OldLabel[j]) j++;
		Edges[i].Label = j;
	}
	//Change edge images
	for (i=1; i<=ENo; i++)
	{
		intarray& Now = Edges[i].Image;
		for (j=1; long(j)<=Now.TopIndex(); j++)
		{
			long Find = (Now[j]>0) ? Now[j] : -Now[j];
			long k=1; while (Find != OldLabel[k]) k++;
			Now[j] = (Now[j]>0) ? k : -k;
		}
	}
	//Change edges round vertices
	for (i=1; i<=VNo; i++)
	{
		intarray& Now = Vertices[i].Edges;
		for (j=1; long(j)<=Now.TopIndex(); j++)
		{
			long Find = (Now[j]>0) ? Now[j] : -Now[j];
			long k=1; while (Find != OldLabel[k]) k++;
			Now[j] = (Now[j]>0) ? k : -k;
		}
	}
	//Change reduction
	if (Type == Reducible1) for (i=1; long(i)<=Reduction.TopIndex(); i++)
	{
		j=1; while (Reduction[i] != OldLabel[j]) j++;
		Reduction[i] = j;
	}
	//Change edge indices
	edgelist Copy = Edges;
	for (i=1; i<=ENo; i++)
	{
		uint j=1; while (Copy[j].Label != long(i)) j++;
		Edges[i] = Copy[j];
	}

	//Relabel Vertices
	for (uint k=1; k<=VNo; k++)
	{
		uint OldVLabel = Vertices[k].Label;
		if (OldVLabel == k) continue;
		Vertices[k].Label = k;
		for (j=1; j<=ENo; j++)
		{
			if (Edges[j].Start == OldVLabel) Edges[j].Start = k;
			if (Edges[j].End == OldVLabel) Edges[j].End = k;
		}
		for (j=1; j<=VNo; j++) if (Vertices[j].Image == OldVLabel) Vertices[j].Image = k;
	}
	NextEdgeLabel = ENo+1;
	NextVertexLabel = VNo+1;
	delete[] OldLabel;
}


void graph::Save(char* Filename, const char*)
{
	std::ofstream File;
	if (!strrchr(Filename, '.')) strcat(Filename, ".grm");
	File.open(Filename);
	if (!File) THROW("Cannot open file for writing",3);
	ReLabel();
	File << Punctures << " " << NumberEdges() << " " << NumberVertices() << '\n';
    uint i;
	for (i=1; i<=NumberVertices(); i++)
	{
		vertex& Now = Vertices[i];
		File << Now.Image << '\n';
		for (uint j=1; long(j)<=Now.Edges.TopIndex(); j++) File << Now.Edges[j] << " ";
		File << 0 << '\n';
	}
	for (i=1; i<=NumberEdges(); i++)
	{
		edge& Now = Edges[i];
		if (Punctures)
		{
			if (Now.Type == Peripheral) File << 1 << " " << Now.Puncture << '\n';
			else File << 0 << '\n';
		}
		for (uint j=1; long(j)<=Now.Image.TopIndex(); j++) File << Now.Image[j] << " ";
		File << 0 << '\n';
	}
    File <<  Type << '\n';
	File.close();
}

void graph::Load(char* Filename, bool Sanity)
{
	std::ifstream File;
	if (!strrchr(Filename, '.')) strcat(Filename, ".grm");
	File.open(Filename);
	if (!File) THROW("Cannot open file for reading",0);
	Flush();
	uint EdgeNo = 0, VertexNo = 0;
	File >> Punctures >> EdgeNo >> VertexNo;
	NextEdgeLabel = EdgeNo+1; NextVertexLabel = VertexNo+1;
	uint *EdgeStart = new uint[EdgeNo+1], *EdgeEnd = new uint[EdgeNo+1];
    uint i;
	for (i=1; i<=EdgeNo; i++) EdgeStart[i] = EdgeEnd[i] = 0;
	for (i=1; i<=VertexNo; i++)
	{
		vertex& Now = Vertices[i];
		Now.Edges.Flush();
		Now.Label = i;
		File >> Now.Image;
		if (Now.Image<1 || Now.Image>VertexNo)
		{
			delete[] EdgeStart; delete[] EdgeEnd;
			File.close();
			THROW("Vertex label out of range",0);
		}
		long Image;
		uint j=1;
		do {
			File >> Image;
			if (Image == 0) continue;
			if (Image > 0)
			{
				if (Image > long(EdgeNo))
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					File.close();
					THROW("Edge label out of range",0);
				}
				if (EdgeStart[Image])
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					File.close();
					THROW("Edge start already assigned",0);
				}
				EdgeStart[Image] = i;
				Now.Edges[j++] = Image;
			}
			else
			{
				if (-Image > long(EdgeNo))
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					File.close();
					THROW("Edge label out of range",0);
				}
				if (EdgeEnd[-Image])
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					File.close();
					THROW("Edge end already assigned",0);
				}
				EdgeEnd[-Image] = i;
				Now.Edges[j++] = Image;
			}
		} while (Image != 0);
	}
	for (i=1; i<=EdgeNo; i++)
	{
		if (!(EdgeStart[i] && EdgeEnd[i]))
		{
			delete[] EdgeStart; delete[] EdgeEnd;
			File.close();
			THROW("Ends of edge not resolved",0);
		}
		Edges[i].Start = EdgeStart[i];
		Edges[i].End = EdgeEnd[i];
	}
	for (i=1; i<=EdgeNo; i++)
	{
		edge& Now = Edges[i];
		Now.Image.Flush();
		Now.Label = i;
		if (Punctures)
		{
			int IsPeripheral;
			File >> IsPeripheral;
			if (IsPeripheral)
			{
				Now.Type = Peripheral;
				File >> Now.Puncture;
				if (Now.Puncture<1 || Now.Puncture>Punctures)
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					File.close();
					THROW("Puncture out of range",0);
				}
			}
			else Now.Type = Main;
		}
		else Now.Type = Main;
		long Image;
		uint j=1;
		do {
			File >> Image;
			if (Image == 0) continue;
			if (Image > 0)
			{
				if (Image > long(EdgeNo))
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					File.close();
					THROW("Edge label out of range",0);
				}
				Now.Image[j++] = Image;
			}
			else
			{
				if (-Image > long(EdgeNo))
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					File.close();
					THROW("Edge label out of range",0);
				}
				Now.Image[j++] = Image;
			}
		} while (Image != 0);
		(Now.Image).Tighten();
	}
	delete[] EdgeStart;
	delete[] EdgeEnd;
	int graphtype;
        if (!File.eof()) {File >> graphtype; Type=static_cast<thurstontype>(graphtype);}
	File.close();
		OrientPeripheralEdges();
	if (Sanity && !SanityCheck()) THROW("Insane graph map",0);
}


bool graph::SanityCheck()
{
   uint i;
	for (i=1; i<=NumberEdges(); i++)
	{
		edge& Now = Edges[i];
		for (uint j=1; long(j)<=Now.Image.TopIndex(); j++)
		{
			if (j==1)
				if (Vertices[FindVertex(Now.Start)].Image != From(Now.Image[1])) return false;
			if (j>1) if (From(Now.Image[j]) != To(Now.Image[j-1])) return false;
			if (long(j)==Now.Image.TopIndex())
				if (Vertices[FindVertex(Now.End)].Image != To(Now.Image[j])) return false;
		}
	}
	for (i=1; i<=NumberVertices(); i++)
	{
		vertex& Now = Vertices[i];
		for (uint j=1; long(j)<=Now.Edges.TopIndex(); j++)
			if (From(Now.Edges[j]) != Now.Label) return false;
	}
	return true;
}

void graph::OrientPeripheralEdges()
{
	if (!Punctures) return;
	for (uint i=1; i<=NumberVertices(); i++)
	{
		vertex& Now = Vertices[i];
		if (!OnP(Now.Label)) continue;
		//Consider peripheral edges at Now
		for (uint j=1, k=2; long(j)<=Now.Edges.TopIndex(); j++, k++)
		{
			if (!IsPeripheral(Now.Edges[j])) continue;
			if (long(j)==Now.Edges.TopIndex()) k=1;
			if ((Now.Edges[j]>0 && !IsPeripheral(Now.Edges[k])) ||
				 (Now.Edges[j]<0 && IsPeripheral(Now.Edges[k])))
			{
				//Alter orientation of peripheral edge
				long Label = (Now.Edges[j]>0) ? Now.Edges[j] : -Now.Edges[j];
				edge& ToChange = Edges[FindEdge(Label)];
				uint Temp = ToChange.Start; ToChange.Start = ToChange.End; ToChange.End = Temp;
				ToChange.Image.Invert();
				for (uint l=1; l<=NumberVertices(); l++)
				{
					for (uint m=1; long(m)<=Vertices[l].Edges.TopIndex(); m++)
					{
						if (Vertices[l].Edges[m] == Label) Vertices[l].Edges[m] = -Label;
						else if (Vertices[l].Edges[m] == -Label) Vertices[l].Edges[m] = Label;
					}
				}
				intarray L(2,1); L[1] = -Label;
				Replace(Label, L);
			}
		}
	}
}




uint graph::FindEdge(long Label)
{
	for (uint i=1; long(i)<=Edges.TopIndex(); i++)
		if (Edges[i].Label == Label || Edges[i].Label == -Label) return i;
	return 0;
}

uint graph::FindVertex(uint Label)
{
	for (uint i=1; long(i)<=Vertices.TopIndex(); i++) if (Vertices[i].Label == Label) return i;
	return 0;
}

long graph::Derivative(long Label)
{
	uint Index = FindEdge(Label);
	if (!Edges[Index].Image.TopIndex()) return 0;
	if (Label>0) return (Edges[Index].Image[1]);
	return (-Edges[Index].Image[Edges[Index].Image.TopIndex()]);
}

long graph::Derivative(long Label, uint n)
{
	for (uint i=1; i<=n; i++)
	{
		Label = Derivative(Label);
		if (!Label) return 0;
	}
	return Label;
}

long graph::AltDerivative(long Label, uint n)
{
	for (uint i=1; i<=n; i++)
	{
		uint Index = FindEdge(Label);
		intarray Image = Edges[Index].Image;
		if (Label<0) Image.Invert();
		uint j=1;
		while (long(j)<=Image.TopIndex() && IsPeripheral(Image[j])) j++;
		if (long(j)>Image.TopIndex()) return 0;
		Label = Image[j];
	}
	return Label;
}

void graph::Replace(long Label, intarray& L)
{
	edgeiterator I(Edges);
	do
	{
		((I++).Image).Replace(Label, L);
	} while (!I.AtOrigin());
}

void graph::RemoveAll(long Label)
{
	edgeiterator I(Edges);
	do
	{
		((I++).Image).RemoveAll(Label);
	} while (!I.AtOrigin());
}

bool graph::Tighten()
{
	bool Result = false;
	edgeiterator I(Edges);
	do
	{
	  if (((I++).Image).Tighten()) Result = true;
	} while (!I.AtOrigin());
	return Result;
}

decimal graph::Growth()
{
	matrix M(*this);
	return M.GrowthRate();
}

bool graph::IntersectsP(long Label)
{
	uint Index = FindEdge(Label);
	edge& Now = Edges[Index];
	if (Now.Type == Peripheral) return true;
	return (OnP(Now.Start) || OnP(Now.End));
}

uint graph::OnPInd(uint Index)
{
   intiterator I(Vertices[Index].Edges);
   do
   {
   	uint EIndex = FindEdge(I++);
   	if (Edges[EIndex].Type == Peripheral) return Edges[EIndex].Puncture;
  } while (!I.AtOrigin());
   return 0;
}

uint graph::OnP(uint Label)
{
	uint Index = FindVertex(Label);
	intiterator I(Vertices[Index].Edges);
	do
	{
		uint EIndex = FindEdge(I++);
		if (Edges[EIndex].Type == Peripheral) return Edges[EIndex].Puncture;
	} while (!I.AtOrigin());
	return 0;
}

bool graph::IsPeripheral(long Label)
{
	uint Index = FindEdge(Label);
	return (Edges[Index].Type == Peripheral);
}

void graph::FindTypes()
{
	if (!Punctures)
	{
		for (uint i=1; i<=NumberEdges(); i++) Edges[i].Type = Main;
		return;
	}
	edgeiterator I(Edges);
	//First Flag all peripheral edges
	do
	{
		edge& Now = I++;
		Now.Flag = (Now.Type == Peripheral) ? true : false;
	} while (!I.AtOrigin());
	bool Changed = true;
	while (Changed)
	{
		Changed = false;
		do
		{
			edge& Now = I++;
			if (Now.Flag) continue;
			intiterator J(Now.Image);
			bool ShouldFlag = true;
			do
			{
				uint Index = FindEdge(J++);
				if (!Edges[Index].Flag)
				{
					ShouldFlag = false;
					continue;
				}
			} while (!J.AtOrigin());
			if (ShouldFlag)
			{
				Now.Flag = true;
				Now.Type = Preperipheral;
				Changed = true;
			}
		} while (!I.AtOrigin());
	}
}

uint graph::From(long Label)
{
	uint Index = FindEdge(Label);
	return ( (Label>0) ? Edges[Index].Start : Edges[Index].End );
}

void graph::Flush()
{
    uint i;
	for (i=1; i<=NumberEdges(); i++) Edges[i].Image.Flush();
	for (i=1; i<=NumberVertices(); i++) Vertices[i].Edges.Flush();
	Edges.Flush();
	Vertices.Flush();
	Turns.Flush();
	NextVertexLabel = 1; NextEdgeLabel = 1; Punctures = 0;
	Type = Unknown;
}


bool graph::IsProperSubForest(bool* Inset, uint n)
{
	bool Proper = false;      //First check subgraph is proper
    uint i;
	for (i=1; i<=n; i++) if (!Inset[i]) Proper = true;
	if (!Proper) return false;
	uint m = NumberVertices();
	bool *VertSet = new bool[m+1], *Changed = new bool[m+1], *NewChanged = new bool[m+1];
	bool Result = true;
	for (i=1; i<=n; i++) if (Inset[i]) //Look for loop in subgraph containing i
	{
		long Label = -Edges[i].Label; //Don't use this edge in making loop
		uint FromVertex = Edges[i].End; //Start here
		uint AimVertex = Edges[i].Start; //Aim to arrive here
        uint j;
		for (j=1; j<=m; j++) VertSet[j] = Changed[j] = NewChanged[j] = false;
		VertSet[FindVertex(FromVertex)] = Changed[FindVertex(FromVertex)] = true;
		bool SomeChanged = true;
		while (SomeChanged)
		{
			for (j=1; j<=m; j++) if (Changed[j])
			{
				intarray& Now = Vertices[j].Edges;
				intiterator I(Now);
				do
				{
					long NowLabel = (I++);
					uint Index = FindEdge(NowLabel);
					if (NowLabel == Label || !Inset[Index] || Index<i) continue; //Now have legitimate edge
					uint NewVertex = FindVertex(To(NowLabel));
					if (To(NowLabel)==AimVertex)
					{
						Result = false;
						break;
					}
					if (!VertSet[NewVertex]) VertSet[NewVertex] = NewChanged[NewVertex] = true;
				} while (!I.AtOrigin());
				if (!Result) break;
			}
			if (!Result) break;
			SomeChanged = false;
			for (j=1; j<=m; j++)
			{
				Changed[j] = NewChanged[j];
				if (NewChanged[j]) SomeChanged = true;
				NewChanged[j] = false;
			}
		}
		if (!Result) break;
	}
	delete[] VertSet;
	delete[] Changed;
	delete[] NewChanged;
	return Result;
}

void graph::IterateTurn(turn& T)
{
	T.i = Derivative(T.i);
	T.j = Derivative(T.j);
}

turn graph::FindTurns()
{
	Turns.Flush();
	turn Result, Current;
	turnlist T;
	Result.Level = 0;
	edgeiterator I(Edges);
        Current.Level=0;
	do
	{
		intarray& Image = (I++).Image;
		for (uint k=1; long(k)<Image.TopIndex(); k++)
		{
			Current.i = -Image[k];
			Current.j = Image[k+1];
			long Found;
			if ((Found = Turns.Find(Current)) != -1)
			{
				Current.Level = Turns[Found].Level;
				if (Current.Level && (!Result.Level || Current.Level<Result.Level)) Result = Current;
				continue;
			}
			T.Flush();
			T[1] = Current;
			bool Finished = false;
			while (!Finished)
			{
				IterateTurn(Current);
				Found = Turns.Find(Current);
				if (Found != -1)
				{
					Finished = true;
					uint FoundLevel = Turns[Found].Level;
					if (!FoundLevel) for (uint l=1; long(l)<=T.TopIndex(); l++) T[l].Level = 0;
					else for (uint l=1; long(l)<=T.TopIndex(); l++) T[l].Level = FoundLevel+T.TopIndex()+1-l;
				}
				else
				{
					if (T.Find(Current) != -1)
					{
						Finished = true;
						for (uint l=1; long(l)<=T.TopIndex(); l++) T[l].Level = 0;
					}
					else
					{
						if (Current.IsDegenerate())
						{
							Finished = true;
							for (uint l=1; long(l)<=T.TopIndex(); l++) T[l].Level = T.TopIndex()+1-l;
						}
						else T.Add(Current);
					}
				}
			}
			Turns.Append(T);
			if (T[1].Level && (!Result.Level || T[1].Level<Result.Level)) Result = T[1];
		}
	} while (!I.AtOrigin());
	return Result;
}


std::ostream& operator<<(std::ostream& Out, turn T)
{
	Out << "Turn " << T.i << ", " << T.j << " at level " << T.Level;
	return (Out);
}

turnplace graph::LocateTurn(turn& T)
{
	turnplace Result;
	edgeiterator I(Edges);
	do
	{
		intarray& Now = (I.Now()).Image;
		for (uint i=1; long(i)<Now.TopIndex(); i++)
			if ( (Now[i]==-T.i && Now[i+1]==T.j) || (Now[i]==-T.j && Now[i+1]==T.i) )
			{
				Result.Label = (I.Now()).Label;
				Result.Position = i;
				return Result;
			}
		I++;
	} while (!I.AtOrigin());
	THROW("Locating non-existent turn",1);
}







bool graph::HasIrreducibleMatrix()
{
	matrix M(*this);
	return M.IsIrreducible();
}

bool graph::RetractsOntoP(bool* Inset, uint n)
{
// Need to test whether we can get from one peripheral loop to another in Inset.
//First test whether Inset minus one edge from each peripheral loop is a proper subforest.
	bool *PunctureDone = new bool[Punctures+1];
    uint i;
	for (i=1; i<=Punctures; i++) PunctureDone[i] = false;
	for (i=1; i<=n; i++) if (IsPeripheral(i) && !PunctureDone[Edges[i].Puncture])
	{
		Inset[i] = false;
		PunctureDone[Edges[i].Puncture] = true;
	}
	delete[] PunctureDone;
	if (!IsProperSubForest(Inset, n)) return false;
	for (i=1; i<=n; i++) if (IsPeripheral(i)) Inset[i] = true; //Restore peripheral subgraph
	uint m = NumberVertices();
	bool *VertSet = new bool[m+1], *Changed = new bool[m+1], *NewChanged = new bool[m+1], Result = true;
	for (i=1; i<=m; i++) if (OnP(Vertices[i].Label))
	{
	//Determine set of vertices connected to Vertices[i]
		uint FromPuncture = OnP(Vertices[i].Label); //Start from this peripheral loop
        uint j;
		for (j=1; j<=m; j++) VertSet[j] = Changed[j] = NewChanged[j] = false;
		VertSet[i] = Changed[i] = true;
		bool SomeChanged = true;
		while (SomeChanged)
		{
			for (j=1; j<=m; j++) if (Changed[j])
			{
				intarray& Now = Vertices[j].Edges;
				intiterator I(Now);
				do
				{
					long NowLabel = (I++);
					uint Index = FindEdge(NowLabel);
					if (!Inset[Index]) continue;
					uint NewVertex = To(NowLabel);
					if (OnP(NewVertex) && (OnP(NewVertex) != FromPuncture) )
					{
						Result = false;
						break;
					}
					uint NewVertIndex = FindVertex(NewVertex);
					if (!VertSet[NewVertIndex]) VertSet[NewVertIndex] = NewChanged[NewVertIndex] = true;
				} while (!I.AtOrigin());
				if (!Result) break;
			}
			if (!Result) break;
			SomeChanged = false;
			for (j=1; j<=m; j++)
			{
				Changed[j] = NewChanged[j];
				if (NewChanged[j]) SomeChanged = true;
				NewChanged[j] = false;
			}
		}
		if (!Result) break;
	}
	delete[] VertSet; delete[] Changed; delete[] NewChanged;
	return Result;
}

bool graph::NeedToAbsorb()
{
	edgeiterator I(Edges);
	do
	{
		edge& Now = I++;
		if (Now.Type == Peripheral) continue;
		if (OnP(Now.Start) && IsPeripheral(Now.Image[1])) return true;
		if (OnP(Now.End) && IsPeripheral(Now.Image[Now.Image.TopIndex()])) return true;
	} while (!I.AtOrigin());
	return false;
}

bool graph::Collapses(intarray& L)
{
	intarray M;
	for (uint i=1; i<=2*NumberEdges(); i++) //INEFFICIENT
	{
		M.Flush();
		intarray Image = Edges[FindEdge(L[1])].Image;
		if (L[1]<0) Image.Invert();
		uint j = Image.TopIndex(); while (IsPeripheral(Image[j])) j--;
		while (long(j)<=Image.TopIndex()) M[M.TopIndex()+1] = Image[j++];
		for (j=2; long(j)<L.TopIndex(); j++) //Peripheral edges
		{
			Image = Edges[FindEdge(L[j])].Image;
			if (L[j]<0) Image.Invert();
			M.Append(Image);
		}
		Image = Edges[FindEdge(L[L.TopIndex()])].Image;
		if (L[L.TopIndex()]<0) Image.Invert();
		j=1; while (IsPeripheral(Image[j])) j++;
		for (uint k=1; k<=j; k++) M[M.TopIndex()+1] = Image[k];
		M.Tighten();
		if (!M.TopIndex()) return true;
		L = M;
	}
	return false;
}

void graph::FindReduction()
{
	if (!Type == Reducible1) THROW("Trying to find reduction with no invariant subgraph",1);
	Reduction.Flush();
	bool* Indices = new bool[NumberEdges()];
	matrix M(*this);
	M.IsIrreducible(Indices);
	uint i=0;
	for (uint j=1; j<=NumberEdges(); j++)
		if (Edges[j].Type == Main)
			if (Indices[i++]) Reduction.SureAdd(Edges[j].Label);
	delete[] Indices;
}

void graph::FindGates()
{
	if (Type != pA_or_red) THROW("Trying to find gates with non-efficient graph map",1);
	Reduction.Flush(); //Will hold gates in format (0,vert label,0,gate1,0,gate2,0,..,gaten,00,vertlabel..)
	Turns.Flush(); //Will hold infinitesimal edges i,j give gates, Level gives vertex label
	//Determine gates at each vertex in turn
    uint i;
	for (i=1; i<=NumberVertices(); i++)
	{
		Reduction.SureAdd(0); Reduction.SureAdd(0);
		intarray& Now = Vertices[i].Edges;
		intarray Class;
        uint j;
		for (j=1; long(j)<=Now.TopIndex(); j++) Class[j] = Derivative(Now[j], 2*NumberEdges());
		Reduction.SureAdd(Vertices[i].Label); Reduction.SureAdd(0);
		uint Start = 2; while (Class[Start] == Class[1]) Start++;
		j=Start;
		do
		{
			Reduction.SureAdd(Now[j]);
			uint Next = (long(j)==Now.TopIndex()) ? 1 : j+1;
			if (Class[j] != Class[Next]) Reduction.SureAdd(0);
			j = Next;
		} while (j!= Start);
	}
	Reduction.SureAdd(0);
	//Determine all infinitesimal edges connecting gates
	for (i=1; i<=NumberEdges(); i++)
	{
		intarray& Now = Edges[i].Image;
		if (Now.TopIndex()==1) continue;
		for (uint j=1; long(j)< Now.TopIndex(); j++)
		{
			bool Continue = true;
			long Label1 = -Now[j], Label2 = Now[j+1];
			while (Continue)
			{
				uint Vertex = From(Label2);
				//Find Vertex in gate list
				uint k=3; while ((Reduction[k] != long(Vertex)) || (Reduction[k-1]) || (Reduction[k-2])) k++;
				//Find canonical labels of  gates
				uint l=k+2; while (Reduction[l] != Label1) l++; while (Reduction[l-1]) l--;
				Label1 = Reduction[l];
				l=k+2; while (Reduction[l] != Label2) l++; while (Reduction[l-1]) l--;
				Label2 = Reduction[l];
				if (Label2<Label1)
				{
					long Temp = Label2; Label2 = Label1; Label1 = Temp;
				}
				turn T; T.i = Label1; T.j = Label2; T.Level = Vertex;
				Continue = Turns.Add(T);
				if (Continue)
				{
					Label1 = Derivative(Label1); Label2 = Derivative(Label2);
				}
			}
		}
	}
}

void graph::FindTrack()
{
   if (Type == pA || Type == Reducible2) return; //Should already have calculated
	FindGates();
	//Determine connectivity at each vertex
	Type = pA; //Change to reducible2 if any vertex is not connected
	for (uint i=1; i<=NumberVertices(); i++)
	{
		uint Count = 0;
		for (uint j=1; long(j)<=Turns.TopIndex(); j++) if (Turns[j].Level == Vertices[i].Label) Count++;
		//Find Vertex in gate list
		uint k=3; while (Reduction[k] != long(Vertices[i].Label) || Reduction[k-1]  || Reduction[k-2]) k++;
		//Count gates at vertex
		uint NumberGates = 0;
		k+=3;
		while (true)
		{
			if (!Reduction[k])
			{
				NumberGates++;
				if (!Reduction[++k]) break;
			}
			k++;
		}
		if (Count < NumberGates-1)
		{
			Type = Reducible2;
			Vertices[i].Flag = false;
		}
		else Vertices[i].Flag = true;
	}
}

/*void graph::TampDown()
{
   bool Finished = false;
   bool Touched = false;
   int Count = 0;
   while (!Finished)
   {
      Finished = true;
      Count++;
      if (Count > 10000) THROW("Tamping not converging", 4);
      //Ensure all vertices non-flagged
      for (uint i=1; i<=NumberVertices(); i++) Vertices[i].Flag = false;
      // Look for a non-peripheral vertex with two adjacent edges which have same derivative
      for (uint i=1; i<=NumberVertices(); i++)
      {
         if (OnPInd(i)) continue;
         intarray& E = Vertices[i].Edges;
         for (uint j=1; long(j)<=E.TopIndex(); j++)
         {
            uint k = (long(j)==E.TopIndex()) ? 1 : j+1;
            if (Derivative(E[j]) == Derivative(E[k]))
            {
               Finished = false;
               Touched = true;
               FoldAsMuchAsPossible(E[j],E[k]);
               AbsorbIntoP();
               PullTight();
               break;
            }
         }
         if (!Finished) break;
      }
   }
   if (Touched)
   {
      //Just to be sure...
      FindTrainTrack();
      FindTrack();
   }
}*/


void graph::TampDown()
{
   bool Finished = false;
   bool Touched = false;
   int Count = 0;
   while (!Finished)
   {
      Finished = true;
      Count++;
      if (Count > 10000) THROW("Tamping not converging", 4);
      //Ensure all vertices non-flagged
      for (uint i=1; i<=NumberVertices(); i++) Vertices[i].Flag = false;
      // Look for a non-peripheral vertex with two adjacent edges which have same derivative
      // Or for a peripheral vertex with three adjacent edges which have same derivative
      long Label1 = 0, Label2 = 0;
      uint Steps = 0;
      for (uint i=1; i<=NumberVertices(); i++)
      {
         if (OnPInd(i))
         {
 /*           //Look for 3 adjacent. Make sure Label1 and Label2 bracket the third
            intarray& E = Vertices[i].Edges;
            if (E.TopIndex()<5) continue;
            for (uint j=1; long(j)<=E.TopIndex(); j++)
            {
               uint k = j+2; if (long(k)>E.TopIndex()) k-=E.TopIndex();
               long D1 = Derivative(E[j],2*NumberEdges()), D2 = Derivative(E[k],2*NumberEdges());
               if (D1 == D2)
               {
                  uint l = (long(j)==E.TopIndex()) ? 1 : j+1;
                  if (D1 == Derivative(E[l],2*NumberEdges()))
                  {
                     Finished = false;
                     Touched = true;
                     long L1 = E[j], L2 = E[k], L3 = E[l];
                     uint s = 1;
                     while ((Derivative(L1)!=Derivative(L2)) || (Derivative(L1)!=Derivative(L3))) {s++; L1=Derivative(L1); L2=Derivative(L2); L3=Derivative(L3);}
                     if (Steps == 0 || s<Steps)
                     {
                        Steps=s; Label1=L1; Label2=L2;
                     }
                  }
               }
            }  */
         }
         else
         {
            intarray& E = Vertices[i].Edges;
            for (uint j=1; long(j)<=E.TopIndex(); j++)
            {
               uint k = (long(j)==E.TopIndex()) ? 1 : j+1;
               if (Derivative(E[j],2*NumberEdges()) == Derivative(E[k],2*NumberEdges()))
               {
                  Finished = false;
                  Touched = true;
                  long L1 = E[j], L2 = E[k];
                  uint s = 1;  while (Derivative(L1)!=Derivative(L2)) {s++; L1=Derivative(L1); L2=Derivative(L2);}
                  if (Steps == 0 || s<Steps)
                  {
                     Steps = s; Label1 = L1; Label2 = L2;
                  }
               }
            }
         }
      }
      if (!Finished)
      {
         FoldAsMuchAsPossible(Label1, Label2, false);
         AbsorbIntoP();
         PullTight();
      }
   }
   if (Touched)
   {
      //Just to be sure...
      FindTrainTrack();
      FindTrack();
   }
}


} // namespace trains


#endif
