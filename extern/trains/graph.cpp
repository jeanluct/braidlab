//Graph Moves
#include <fstream>

#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "graph.h"

namespace trains {

using namespace std;

turnlist::turnlist(uint s, uint d, uint o) : p(new turn[s]), next(NULL), size(s), delta(d), origin(o), MaxAssigned(-1) {};


turnlist::~turnlist() {if (next) next->turnlist::~turnlist(); delete [] p;}

long turnlist::TopIndex() {return MaxAssigned+long(origin);}

turn& turnlist::operator [](uint i)
{                                                                                    
	return Element(i-origin);
}

turn& turnlist::Element(uint i)                                                           
{
	if (i > MAXARRAYLENGTH) THROW("Array Index Out of Bounds", 1); 
	if (long(i) >= MaxAssigned) MaxAssigned = long(i);
	if (i<size) return p[i];                                                           
	if (next) return next->Element(i-size);
	uint growby = (delta > i-size+1) ? delta : i-size+1;                                 
	next = new turnlist(growby, delta);
	if (!next) THROW("Out of Memory", 1);
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

void turnlist::Print(::std::ostream& Out)                                                 
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
		LoopReplace(Label, Temp);
		if (Embedding)
		{
			E.EI.Start = E.EI.End = OldE.EI.Start;
			E.EI.Path.clear();
			V.Region = (Vertices[VIndex]).Region;
		}
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
		//		#pragma warn -lvc
		long Tempo=-E.Label;
		(Vertices[VIndex].Edges).Replace(Label, Tempo);
		//		#pragma warn .lvc
		intarray Temp; Temp[1] = -E.Label; Temp[2] = Label;
		Replace(Label, Temp);
		LoopReplace(Label, Temp);
		if (Embedding)
		{
			E.EI.Start = E.EI.End = OldE.EI.End;
			E.EI.Path.clear();
			V.Region = (Vertices[VIndex]).Region;
		}
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
		Vertices[StartIndex].Edges.RemoveAll(Label);       //ASSUME nothing to do with embeddings here
	}
	else
	{
		if (OnP(E.Start) || !(OnP(E.End))) //Collapse end vertex to start vertex unless ends on P but doesn't start on P
		{
			//Edges starting at End vertex have start region moved, and prepend path with that of E
			//Edges ending at End vertex have end region moved, and append path with inverse of that of E
			if (Embedding)
			{
				for (uint i=1; i<=NumberEdges(); ++i) if (i != Index)
				{
					if (Edges[i].Start == E.End)
					{
						Edges[i].EI.prepend(E.EI);
						Edges[i].EI.tighten();
					}
					if (Edges[i].End == E.End)
					{
						Edges[i].EI.appendinverse(E.EI);
						Edges[i].EI.tighten();
					}
				}
			}
			uint i = Vertices[StartIndex].Edges.Find(Label);
			//		#pragma warn -lvc
			long Temp=-Label;
			uint j = Vertices[EndIndex].Edges.Find(Temp);
			//		#pragma warn .lvc
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
		else //Ends on P, doesn't start on P. Collapse start vertex to end vertex
		{
			//Edges starting at Start vertex have start region moved, and prepend path with inverse of that of E
			//Edges ending at Start vertex have end region moved, and append path with that of E
			if (Embedding)
			{
				for (uint i=1; i<=NumberEdges(); ++i) if (i != Index)
				{
					if (Edges[i].Start == E.Start)
					{
						Edges[i].EI.prependinverse(E.EI);
						Edges[i].EI.tighten();
					}
					if (Edges[i].End == E.Start)
					{
						Edges[i].EI.append(E.EI);
						Edges[i].EI.tighten();
					}
				}
			}
			uint i = Vertices[StartIndex].Edges.Find(Label);
			//		#pragma warn -lvc
			long Temp=-Label;
			uint j = Vertices[EndIndex].Edges.Find(Temp);
			//		#pragma warn .lvc
			Vertices[StartIndex].Edges.Rotate(i);
			Vertices[StartIndex].Edges.Remove(Vertices[StartIndex].Edges.TopIndex());
			Vertices[EndIndex].Edges.Rotate(j);
			Vertices[EndIndex].Edges.Remove(Vertices[EndIndex].Edges.TopIndex());
			Vertices[EndIndex].Edges.Append(Vertices[StartIndex].Edges);
			// Vertices with image E.Start now have image E.End
			vertexiterator I(Vertices);
			do
			{
				if (I.Now().Image == E.Start) I.Now().Image = E.End;
				I++;
			} while (!I.AtOrigin());
			//Edges with endpoints at E.End now have endpoints at E.Start
			edgeiterator J(Edges);
			uint start = E.Start, end = E.End;
			do
			{
				if (J.Now().Start == start) J.Now().Start = end;
				if (J.Now().End == start) J.Now().End = end;
				J++;
			} while (!J.AtOrigin());
			//Delete vertex from graph
			Vertices[StartIndex].Edges.Flush();
			Vertices.Remove(StartIndex);
		}
	}
	//Next remove all occurences of Edge in other edge images and in loops
	RemoveAll(Label);
	LoopRemoveAll(Label);
	//Finally delete edge from graph.
	Edges[Index].Image.Flush();
	Edges.Remove(Index);
	if (Embedding) TightenAllVertexEmbeddings();
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
			if (!First)  continue;
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
	if (!(Vertices[VIndex].Valence() == 2))
		THROW("Performing valence two isotopy on wrong valence vertex",1);
	Push(Label, Edges[Index].Image.TopIndex());
	Collapse(Label);
}

void graph::ValenceTwoIsotopy(uint Label)
{
	uint Index = FindVertex(Label);
	if (!(Vertices[Index].Valence() == 2))
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
	// JLT: Initialised i1 and i2 to remove a compiler complaint.
	// In theory the loop could fail to assign any values to them.
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
	if (Embedding)
	{
		NewEdge.EI.Path.clear();
		NewEdge.EI.Start = NewEdge.EI.End = NewVertex.Region = Vertex.Region;
	}
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
			LoopReplace(NowLabel, L);
			edge& NowEdge = Edges[FindEdge(NowLabel)];
			NowEdge.Image.Flush();
			if (NowLabel>0) NowEdge.Start = NewVertex.Label;
			else NowEdge.End = NewVertex.Label;
		}
	} while (!I.AtOrigin());
	//Collapse each of the folded edges
	intiterator J(M);
	do Collapse(J++); while (!J.AtOrigin());
	if (Embedding) TightenAllVertexEmbeddings();
	delete [] ToFold;
}




void graph::CarefulFoldAsMuchAsPossible(long Label1, long Label2)
{
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
		//Start with old method since it almost always works... have new method if it fails just in case
		//HACK
		bool OldMethodFailed = false;
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
			if (long(Place) >= Guard) 
			{
				OldMethodFailed = true;
				break;
			}
			else SubdivideHere(Current, Place);
		}
		if (OldMethodFailed) //Then here is the new method
		{
			while (BadEdge.Image.TopIndex() == 1)
			{
				::std::list<int> CurrentEdgePath(1, BadEdge.Image[1]);
				bool done = false;
				while(!done)
				{
					::std::list<int> NewEdgePath;
					for (::std::list<int>::iterator I = CurrentEdgePath.begin(); I != CurrentEdgePath.end(); ++I)
					{
						if (*I>0) NewEdgePath.insert(NewEdgePath.end(), Edges[FindEdge(*I)].Image.p.begin(), Edges[FindEdge(*I)].Image.p.end());
						else for (::std::vector<long>::reverse_iterator J = Edges[FindEdge(*I)].Image.p.rbegin(); J != Edges[FindEdge(*I)].Image.p.rend(); ++J)
							NewEdgePath.insert(NewEdgePath.end(), -(*J));
					}
					for (::std::list<int>::iterator I = NewEdgePath.begin(); I != NewEdgePath.end(); ++I)
					{
						//long Current = *I;
						edge CurrentEdge = Edges[FindEdge(*I)];
						if (CurrentEdge.Image.TopIndex() > 1)
						{
							uint Place = 1;
							long Guard = CurrentEdge.Image.TopIndex();
							if (*I>0)
							{
								while (Edges[FindEdge(CurrentEdge.Image[Place])].Type != Main)
									Place++;
							}
							else
							{
								while (Edges[FindEdge(CurrentEdge.Image[Guard-Place+1])].Type != Main)
									Place++;
							}
							if (long(Place) < Guard)
							{
								SubdivideHere(*I, Place);
								done = true;
								break;
							}
						}
					}
					if (!done) CurrentEdgePath = NewEdgePath;
				}
			}
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
	if (Embedding)
	{
		NewEdge.EI.Path.clear();
		NewEdge.EI.Start = NewEdge.EI.End = NewVertex.Region = Vertex.Region;
	}
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
			LoopReplace(NowLabel, L);
			edge& NowEdge = Edges[FindEdge(NowLabel)];
			NowEdge.Image.Flush();
			if (NowLabel>0) NowEdge.Start = NewVertex.Label;
			else NowEdge.End = NewVertex.Label;
		}
	} while (!I.AtOrigin());
	//Collapse each of the folded edges
	intiterator J(M);
	do Collapse(J++); while (!J.AtOrigin());
	if (Embedding) TightenAllVertexEmbeddings();
	delete [] ToFold;
}

} // namespace trains
