// Algorithm Operations

#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "graph.h"
#include <fstream>

namespace trains {

using namespace std;

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
#ifdef __UNIXVERSION
			THROW("Growth not decreasing in fold.\nTry decreasing the tolerance\n or disable checking.",2);
			return false;
#endif
#ifdef __WINDOWSVERSION
#ifndef VS2005
			WinErr("Growth not decreasing in fold.\nTry decreasing the tolerance\n or disable checking.",1);
			return false;
#else
			return true;
#endif
#endif
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
#ifdef VS2005
		if (MakeIrreducible(false)) continue;

#else
		if (MakeIrreducible()) continue;

#endif
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
				for (uint j=1; j<=n; j++) if (Changed[j])
				{
					intarray& Im = Edges[j].Image;
					for (uint k=1; long(k)<=Im.TopIndex(); k++)
					{
						uint Index = FindEdge(Im[k]);
						if (Index < i && IntersectsP(Index) && !IsPeripheral(Index)) //CHANGED
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
						if (Embedding)
						{
							NewEdge.EI.Path.clear();
							NewEdge.EI.Start = NewEdge.EI.End = OldVertex.Region;
						}
						//Set up new vertex and change edges round old vertex, and ends of edges to old vertex
						NewVertex.Label = NewVertexLabel;
						NewVertex.Image = OldVertex.Image;
						NewVertex.Edges.Flush();
						if (Embedding) NewVertex.Region = OldVertex.Region;
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
						//Do the same with loops
						for (l=0; l<loops.size(); l++)
						{
							intarray& NowImage = loops[l];
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
				// JLT: Initialised IncludePeripheral to remove a compiler complaint.
				// In theory the loop could fail to assign any value to it.
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
					if (Embedding)
					{
						NewEdge.EI.Path.clear();
						NewEdge.EI.Start = NewEdge.EI.End = OldVertex.Region;
					}
					//Set up new vertex and change edges round old vertex, and ends of edges to old vertex
					NewVertex.Label = NewVertexLabel;
					NewVertex.Image = OldVertex.Image;
					NewVertex.Edges.Flush();
					if (Embedding) NewVertex.Region = OldVertex.Region;
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
					//Do the same with loops
					for (l=0; l<loops.size(); l++)
					{
						intarray& NowImage = loops[l];
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
//#pragma warn .lvc

bool graph::MakeIrreducible(bool OldVersion)
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
			if (OldVersion)
			{
				while (PullTight() || CollapseInvariantForest() || AbsorbIntoP());
			}
			else
			{
				while (PullTight() || CollapseInvariantForest() || AbsorbIntoP() || PerformValenceTwoIsotopies());
			}
			if (!HasIrreducibleMatrix()) break;
		}
	}
	return Result;
}

} // namespace trains
