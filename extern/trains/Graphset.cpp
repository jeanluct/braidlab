// Graph Set up, printing, etc.

#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "graph.h"
#include <fstream>
#include <sstream>
#include <map>
#ifndef VS2005
#include <cstring>
#include <cstdio>
#endif

namespace trains {

using namespace std;

#ifndef VS2005
void graph::UserInput()
{
	Flush();
	loops.clear();
	looplabels.clear();
	Embedding = false;
	uint EdgeNo = 0, VertexNo = 0;
	Type = Unknown;
	cout << "Please ensure: i) that the edges around each vertex are given in their correct\n";
	cout << "cyclic (anticlockwise) order; and ii) that the graph map you enter can be\n";
	cout << "realised by an orientation-preserving surface homeomorphism.\n";
	cout << "Results are undefined if these rules are broken.\n\n";
	cout << "Enter number of peripheral loops, edges and vertices: ";
	cin >> Punctures >> EdgeNo >> VertexNo;
	cout << '\n';
	if (!EdgeNo || !VertexNo) THROW("Graph must have at least one edge and vertex", 0);
	NextEdgeLabel = EdgeNo+1; NextVertexLabel = VertexNo+1;
	uint *EdgeStart = new uint[EdgeNo+1], *EdgeEnd = new uint[EdgeNo+1];
	uint i;
	for (i=1; i<=EdgeNo; i++) EdgeStart[i] = EdgeEnd[i] = 0;
	for (i=1; i<=VertexNo; i++)
	{
		vertex& Now = Vertices[i];
		Now.Edges.Flush();
		cout << "Vertex number " << i << ":\n";
		Now.Label = i;
		cout << "Image vertex: ";
		cin >> Now.Image;
		if (Now.Image<1 || Now.Image>VertexNo)
		{
			delete[] EdgeStart; delete[] EdgeEnd;
			THROW("Vertex label out of range",0);
		}
		cout << "Enter labels of edges at vertex in cyclic order, ending with 0:\n";
		long Image;
		uint j=1;
		do {
			cin >> Image;
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
		cout << "Edge number " << i << " from " << Now.Start << " to " << Now.End <<":\n";
		Now.Label = i;
		if (Punctures)
		{
			int IsPeripheral;
			cout << "Enter 1 if peripheral, 0 otherwise: ";
			cin >> IsPeripheral;
			if (IsPeripheral)
			{
				Now.Type = Peripheral;
				cout << "Enter puncture which edge is about: ";
				cin >> Now.Puncture;
				if (Now.Puncture<1 || Now.Puncture>Punctures)
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Puncture out of range",0);
				}
			}
			else Now.Type = Main;
		}
		else Now.Type = Main;
		cout << "Enter labels of image edges, ending with 0:\n";
		long Image;
		uint j=1;
		do {
			cin >> Image;
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
#endif

void graph::Set(braid& B)
{
	if (B.Size() < 3) THROW("Braid should have at least three strings",0);
	Embedding = DesireEmbedding;
	Flush();
	IdentityGraph(B.Size());
	for (uint i=1; i<=B.Length(); i++)
	{
		ActOn(B[i]);
		Tighten();
	}
	ReLabel();
}

void graph::BoundaryPeripheralSet(braid& B)
{
	if (B.Size() < 3) THROW("Braid should have at least three strings",0);
	Embedding = DesireEmbedding;
	Flush();
	//First calculate action of braid on n-1 loops from boundary around first n-1 braid string punctures
	int n = B.Size();
	vector<list<int> >  Images(n-1);
	for (int i=0; i<n-1; ++i) Images[i].assign(1, i+1);
	for (int i=1; i<=static_cast<int>(B.Length()); ++i)
	{
		for (vector<list<int> >::iterator I = Images.begin(); I != Images.end(); ++I)
		{
			if (B[i] > 0)
			{
				//replace each B[i] with B[i] B[i]+1 -B[i], and each B[i]+1 with B[i]
				for (list<int>::iterator J = I->begin(); J != I->end(); ++J)
				{
					if (*J == B[i]+1) *J = B[i];
					else if (*J == B[i])
					{
						++J;
						J = I->insert(J, B[i]+1);
						++J;
						J = I->insert(J, -B[i]);
					}
					else if (*J == -(B[i]+1)) *J = -B[i];
					else if (*J == -B[i])
					{
						J = I->insert(J, -(B[i]+1));
						J = I->insert(J, B[i]);
						++J; ++J;
					}
				}
			}
			else //B[i] < 0
			{
				//replace each B[i] with B[i]+1 and each B[i]+1 with -(B[i]+1) B[i] B[i}+1
				int absgen = -B[i];
				for (list<int>::iterator J = I->begin(); J != I->end(); ++J)
				{
					if (*J == absgen)
					{
						*J = absgen+1;
						continue;
					}
					if (*J == absgen+1)
					{
						J = I->insert(J, absgen);
						J = I->insert(J, -(absgen+1));
						++J; ++J;
						continue;
					}
					if (*J == -absgen) 
					{
						*J = -(absgen+1);
						continue;
					}
					if (*J == -(absgen+1))
					{
						++J;
						J = I->insert(J, -absgen);
						++J;
						J = I->insert(J, absgen+1);
					}
				}
			}
			tighten(*I);
		}
	}
	//Determine which punctures have peripheral loops around them
	vector<uint> punctureImages(n+1); //punctureImages[0] is not used
	for (int i=1; i<=n; ++i) punctureImages[i] = B.Permute(i);
	vector<bool> nonPeripheral(n+1, false); //nonPeripheral[0] is not used
	int numberNonPeripheral = 0;
	int i=n;
	do
	{
		++numberNonPeripheral;
		nonPeripheral[i] = true;
		i = punctureImages[i];
	} while (i != n);
	vector<int> vertexNumbers(n, 0); //For peripheral values, gives number of vertex on that loop
	int nextVertexNumber = 2;
	for (int i=1; i<n; ++i) if (!nonPeripheral[i]) vertexNumbers[i] = nextVertexNumber++;

	//Set up graph 
	Flush();
	Punctures = n + 1 - numberNonPeripheral;
	NextEdgeLabel = 2*n + 1 - numberNonPeripheral;
	NextVertexLabel = n + 2 - numberNonPeripheral;
	Type = Unknown;
	//Vertices
	int boundayVertexRegion = n/2;
	//Vertex 1 is on boundary
	vertex& Now = Vertices[1];
	Now.Edges.Flush();
	Now.Label = 1;
	Now.Image = 1;
	Now.Region = boundayVertexRegion;
	Now.Edges.SureAdd(-n); 
	for (int i=1; i<n; ++i)
	{
		Now.Edges.SureAdd(i);
		if (nonPeripheral[i]) Now.Edges.SureAdd(-i);
	}
	Now.Edges.SureAdd(n);
	//Other vertices are on peripheral loops about braid strings
	for (int i=1; i<n; ++i) if (!nonPeripheral[i])
	{
		vertex& Now = Vertices[vertexNumbers[i]];
		Now.Edges.Flush();
		Now.Label = vertexNumbers[i];
		Now.Image = vertexNumbers[punctureImages[i]];
		Now.Region = (i <= boundayVertexRegion) ? i : i-1;
		Now.Edges.SureAdd(-i);
		Now.Edges.SureAdd(vertexNumbers[i] + n - 1);
		Now.Edges.SureAdd(1 - n - vertexNumbers[i]);
	}
	//Next set up peripheral edges INCLUDING IMAGES
	for (int i=n; i<=2*n-numberNonPeripheral; ++i)
	{
		edge& Now = Edges[i];
		Now.Image.Flush();
		Now.Label = i;
		Now.Type = Peripheral;
		Now.Puncture = i + 1 - n;
		Now.Start = i + 1 - n;
		Now.End = i + 1 - n;
		if (i == n) Now.Image[1] = i;
		else 
		{
			int stringNumber = -Vertices[i + 1 - n].Edges[1];
			int imageStringNumber = punctureImages[stringNumber];
			Now.Image[1] = vertexNumbers[imageStringNumber] + n - 1;
		}
		if (Embedding)
		{
			Now.EI.Path.clear();
			Now.EI.Start = Now.EI.End = Vertices[i + 1 - n].Region;
			if (i == n)
			{
				for (int j = boundayVertexRegion + 1; j <= n; ++j) Now.EI.append(j);
				for (int j = -n; j <= -1; ++j) Now.EI.append(j);
				for (int j = 1; j <= boundayVertexRegion; ++j) Now.EI.append(j);
			}
			else
			{
				int stringNumber = -Vertices[i + 1 - n].Edges[1];
				if (stringNumber <= boundayVertexRegion)
				{
					Now.EI.append(stringNumber); Now.EI.append(-stringNumber);
				}
				else
				{
					Now.EI.append(-stringNumber); Now.EI.append(stringNumber);
				}
			}

		}
	}
	//Next set up main edges OMITTING IMAGES
	for (int i = 1; i < n; ++i)
	{
		edge& Now = Edges[i];
		Now.Image.Flush();
		Now.Label = i;
		Now.Type = Main;
		Now.Start = 1;
		Now.End = (nonPeripheral[i]) ? 1 : vertexNumbers[i];
		if (Embedding)
		{
			Now.EI.Path.clear();
			Now.EI.Start = boundayVertexRegion;
			Now.EI.End = (nonPeripheral[i]) ? boundayVertexRegion : Vertices[vertexNumbers[i]].Region;
			if (nonPeripheral[i])
			{
				if (i <= boundayVertexRegion)
				{
					for (int j = boundayVertexRegion; j >= i; --j) Now.EI.append(j);
					Now.EI.append(-i);
					for (int j = i+1; j<=boundayVertexRegion; ++j) Now.EI.append(j);
				}
				else
				{
					for (int j = boundayVertexRegion+1; j < i; ++j) Now.EI.append(j);
					Now.EI.append(-i);
					for (int j = i; j > boundayVertexRegion; --j) Now.EI.append(j);
				}
			}
			else
			{
				if (i <= boundayVertexRegion)
					for (int j = boundayVertexRegion; j > i; --j) Now.EI.append(j);
				else
					for (int j = boundayVertexRegion+1; j < i; ++j) Now.EI.append(j);
			}
		}
	}
	//Finally set up main edge images.
	map<int, vector<long> > replacements;
	for (int i = 1; i < n; ++i)
	{
		if (nonPeripheral[i])
		{
			replacements[i] = vector<long>(1, i);
			replacements[-i] = vector<long>(1, -i);
		}
		else
		{
			vector<long> v;
			v.push_back(i); v.push_back(n - 1 + vertexNumbers[i]); v.push_back(-i);
			replacements[i] = v;
			v[1] = 1 - n - vertexNumbers[i];
			replacements[-i] = v;
		}
	}
	vector<long> v;
	for (int i = 1-n; i <= -1; ++i) v.insert(v.end(), replacements[i].begin(), replacements[i].end());
	v.push_back(-n); 
	replacements[n] = v;
	vector<long> u;
	for (vector<long>::reverse_iterator I = v.rbegin(); I != v.rend(); ++I) u.push_back(-*I);
	replacements[-n] = u;

	for (int i = 1; i < n; ++i)
	{
		vector<long>& CurrentImage = Edges[i].Image.p;
		for (list<int>::iterator I = Images[i-1].begin(); I != Images[i-1].end(); ++I) CurrentImage.insert(CurrentImage.end(), replacements[*I].begin(), replacements[*I].end());
		tighten(CurrentImage);
		if (!nonPeripheral[i]) //cut off half way down
		{
			CurrentImage.erase(CurrentImage.begin() + CurrentImage.size()/2, CurrentImage.end());
		}
	}


	ReLabel();
}

void graph::Print(ostream& Out, bool showimages)
{
	FindTypes();
	Out << "Graph on surface with " << Punctures << " peripheral loops:\n";
	vertexiterator I(Vertices);
	do
	{
		(I++).Print(Out, Embedding);
		Out << endl;
	} while (!I.AtOrigin());
	edgeiterator J(Edges);
	do
	{
		(J++).Print(Out, showimages, Embedding);
		if (!showimages) Out << endl;
		Out << endl;
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

graph::graph(braid &B) : Factor(true), DesireEmbedding(true), UtilityFlag(false)
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
		Now.Region = i-1;
		if (i==1)
		{
			Now.Edges[1] = 1;
			Now.Edges[2] = -1;
			Now.Edges[3] = n+1;
			Now.Region = 1;
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
		if (Embedding)
		{
			Now.EI.Path.clear();
			Now.EI.Start = Now.EI.End = ((i==1) ? 1 : i-1);
			Now.EI.append((i==1) ? 1 : -static_cast<int>(i));
			Now.EI.append((i==1) ? -1 : static_cast<int>(i));
		}
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
		if (Embedding)
		{
			Now.EI.Path.clear();
			Now.EI.Start = ((i==n+1) ? 1 : i-n-1);
			Now.EI.End = i-n;
			if (i>n+1) Now.EI.append(i-n);
		}
	}
	// Set up loops
	loops.clear();
	looplabels.clear();
	for (i=1; i<n; ++i)
	{
		intarray Loop;
		Loop[1] = i;
		Loop[2] = n+i;
		Loop[3] = i+1;
		Loop[4] = -static_cast<long>(n+i);
		loops.push_back(Loop);
		ostringstream oss;
		oss << i;
		looplabels.push_back(oss.str());
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

void graph::PrintTurns(ostream& Out)
{
	FindTurns();
	for (uint i=1; long(i)<=Turns.TopIndex(); i++) Out << Turns[i] << '\n';
}

void graph::PrintLoops(ostream& Out)
{
	for (vector<int>::size_type i=0; i<loops.size(); ++i) {
		Out << looplabels[i] << ": ";
		loops[i].Print(Out);
	}    
}


void graph::PrintSingularities(ostream& Out, bool Abbreviated)
{
	FindSingularities();
	int currentProngs = 0;
	// JLT: Initialised total to remove a compiler complaint.
	// In theory the loop could fail to assign any value to it.
	int total = 0;
	for (vector<singularityOrbit>::iterator I = singularities.begin(); I != singularities.end(); ++I)
	{
		if (I->singularities.front().prongs != currentProngs)
		{
			currentProngs = I->singularities.front().prongs;
			//Count total number of singularities with this many prongs
			total = 0;
			for (vector<singularityOrbit>::iterator J = I; (J != singularities.end()) && (J->singularities.front().prongs == currentProngs); ++J)
				total += J->singularities.size();
			if (!Abbreviated) Out << "\n";
			if (total > 1) Out << total << " " << currentProngs << "-pronged singularities\n";
			else Out << total << " " << currentProngs << "-pronged singularity\n";
		}
		if (!Abbreviated)
		{
			if (I->singularities.size()>1) Out << "Period " << I->singularities.size() << " orbit:   ";
			else if (total>1) Out << "Fixed:   ";
			for(vector<singularity>::iterator J = I->singularities.begin(); J != I->singularities.end(); ++J)
			{
				if (J->interior) Out << "("; else Out << "[";
				copy(J->location.begin(), --(J->location.end()), ostream_iterator<long>(Out, " "));
				Out << J->location.back();
				if (J->interior) Out << ")"; else Out << "]";
				if (J != I->singularities.end()-1) Out << " -> ";
			}
			Out << "\n";
		}
	}
}

void graph::PrintGates(ostream& Out)
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



//#pragma warn -lvc
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
	//Change loops
	for (i=0; i<loops.size(); ++i)
	{
		intarray& Now = loops[i];
		for (j=1; long(j)<=Now.TopIndex(); ++j)
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

//#pragma warn .lvc

void graph::Save(string Filename)
{
	if (Filename.find('.')==string::npos) Filename += ".grm";
	ofstream File;
	File.open(Filename.c_str());
	if (!File) THROW("Cannot open file for writing", 3);
	File << "V " << VERSION_NUMBER << endl;
	File << Punctures << " " << NumberEdges() << " " << NumberVertices() << " " <<  Embedding <<  " " << NextVertexLabel << " " << NextEdgeLabel << endl;
	for (uint i=1; i<=NumberVertices(); ++i) //Output vertices in turn
	{
		vertex& Now = Vertices[i];
		File << Now.Label << " " << Now.Image << endl;
		if (Embedding) File << Now.Region << endl;
		for (uint j=1; long(j)<=Now.Edges.TopIndex(); ++j) File << Now.Edges[j] << endl;
		File << 0 << endl;
	}
	for (uint i=1; i<=NumberEdges(); ++i) //Output edges in turn
	{
		edge& Now = Edges[i];
		File << Now.Start << " " << Now.End << " " << Now.Label << endl;
		File << Now.Type;
		if (Now.Type == Peripheral) File << " " << Now.Puncture;
		File << endl;
		for (uint j=1; long(j)<=Now.Image.TopIndex(); ++j) File << Now.Image[j] << " ";
		File << 0 << endl;
		if (Embedding)
		{
			File << Now.EI.Start << " " << Now.EI.End << endl;
			for (list<int>::iterator I = Now.EI.Path.begin(); I!=Now.EI.Path.end(); ++I) File << *I << " ";
			File << 0 << endl;
		}
	}
	File << Type << endl;
	if (Type == Reducible1)
	{
		for (uint i=1; long(i)<=Reduction.TopIndex(); ++i) File << Reduction[i] << " ";
		File << 0 << endl;
	}
	File << loops.size() << endl;
	for (vector<intarray>::size_type i=0; i<loops.size(); ++i)
	{
		File << looplabels[i] << endl;
		for (uint j=1; long(j)<=loops[i].TopIndex(); ++j) File << loops[i][j] << " ";
		File << 0 << endl;
	}
#ifdef VS2005
	File << isHorseshoeBraid << '\n';
#endif
	File.close();
}

void graph::Load(string Filename)
{
	if (Filename.find('.')==string::npos) Filename += ".grm";
	ifstream File;
	File.open(Filename.c_str());
	if (!File) THROW("Cannot open file for reading", 0);
	Load(File);
	File.close();
}

void graph::Load(istream& In)
{
	char c = static_cast<char>(In.peek());
	if (c != 'V')
	{
		if (!UtilityFlag) 
#ifndef VS2005
			Report("Old format file.");
#else
			Messages.push_back("Old format file.");
#endif
		UtilityFlag = false;
		OldLoad(In);
		return;
	}
	In >> c;
	double version;
	In >> version;
	//File.ignore(200,'\n');
	Flush();
	uint NumberOfEdges, NumberOfVertices;
	In >> Punctures >> NumberOfEdges >> NumberOfVertices >> Embedding >> NextVertexLabel >> NextEdgeLabel;
	if (Embedding && !DesireEmbedding) 
#ifndef VS2005
		Report("Embedding information is present, and will be discarded");
#else
		Messages.push_back("Embedding information is present, and will be discarded");
#endif
	for (uint i=1; i<=NumberOfVertices; ++i)
	{
		vertex& Now = Vertices[i];
		Now.Edges.Flush();
		In >> Now.Label >> Now.Image;
		if (Embedding) In >> Now.Region;
		long Image;
		uint j=1;
		In >> Image;
		while (Image != 0)
		{
			Now.Edges[j++] = Image;
			In >> Image;
		}
	}
	for (uint i=1; i<=NumberOfEdges; ++i)
	{
		edge& Now = Edges[i];
		Now.Image.Flush();
		Now.EI.Path.clear();
		In >> Now.Start >> Now.End >> Now.Label;
		int type; In >> type; Now.Type = static_cast<edgetype>(type);
		if (Now.Type == Peripheral) In >> Now.Puncture;
		long Image;
		uint j=1;
		In >> Image;
		while (Image != 0)
		{
			Now.Image[j++] = Image;
			In >> Image;
		}
		if (Embedding)
		{
			In >> Now.EI.Start >> Now.EI.End;
			In >> Image;
			while (Image != 0)
			{
				if (DesireEmbedding) Now.EI.Path.push_back(Image);
				In >> Image;
			}
		}
	}
	int type; In >> type; Type = static_cast<thurstontype>(type);
	if (Type == Reducible1)
	{
		long EdgeNo;
		uint j=1;
		In >> EdgeNo;
		while (EdgeNo != 0)
		{
			Reduction[j++] = EdgeNo;
			In >> EdgeNo;
		}
	}
	int NumberOfLoops; In >> NumberOfLoops;
	for (int i=0; i<NumberOfLoops; ++i)
	{
		string c;
		In.ignore(200,'\n');
		getline(In,c);
		looplabels.push_back(c);
		loops.push_back(intarray());
		long LoopEntry;
		uint j=1;
		In >> LoopEntry;
		while (LoopEntry != 0)
		{
			loops[i][j++] = LoopEntry;
			In >> LoopEntry;
		}
	}
	if (Type == Reducible2 || Type == pA) FindGates();
#ifdef VS2005
	if (version > 3.99) In >> isHorseshoeBraid;
#endif
}





void graph::OldLoad(istream& In)
{
	Flush();
	uint EdgeNo = 0, VertexNo = 0;
	In >> Punctures >> EdgeNo >> VertexNo;
	NextEdgeLabel = EdgeNo+1; NextVertexLabel = VertexNo+1;
	uint *EdgeStart = new uint[EdgeNo+1], *EdgeEnd = new uint[EdgeNo+1];
	uint i;
	for (i=1; i<=EdgeNo; i++) EdgeStart[i] = EdgeEnd[i] = 0;
	for (i=1; i<=VertexNo; i++)
	{
		vertex& Now = Vertices[i];
		Now.Edges.Flush();
		Now.Label = i;
		In >> Now.Image;
		if (Now.Image<1 || Now.Image>VertexNo)
		{
			delete[] EdgeStart; delete[] EdgeEnd;
			THROW("Vertex label out of range",0);
		}
		long Image;
		uint j=1;
		do {
			In >> Image;
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
		Now.Label = i;
		if (Punctures)
		{
			int IsPeripheral;
			In >> IsPeripheral;
			if (IsPeripheral)
			{
				Now.Type = Peripheral;
				In >> Now.Puncture;
				if (Now.Puncture<1 || Now.Puncture>Punctures)
				{
					delete[] EdgeStart; delete[] EdgeEnd;
					THROW("Puncture out of range",0);
				}
			}
			else Now.Type = Main;
		}
		else Now.Type = Main;
		long Image;
		uint j=1;
		do {
			In >> Image;
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
	delete[] EdgeStart;
	delete[] EdgeEnd;
	int graphtype;
	if (!In.eof()) {In >> graphtype; Type=static_cast<thurstontype>(graphtype);}
	OrientPeripheralEdges();
	if (Type == pA || Type == Reducible2) FindGates();
	loops.clear(); looplabels.clear();
	Embedding = false;
	if (!SanityCheck()) THROW("Insane graph map",0);
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

} // namespace trains
