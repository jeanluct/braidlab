//Graph Utilities



#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "trains/graph.h"
#include <sstream>
#include <map>

#ifdef __CHARPOLY
#include <NTL/mat_ZZ.h>
#include <NTL/ZZX.h>
#include <NTL/ZZXFactoring.h>
#include <NTL/mat_poly_ZZ.h>
#endif

namespace trains {

using namespace std;


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

void graph::LoopReplace(long label, intarray& L)
{
	for (vector<int>::size_type i=0; i < loops.size(); ++i)
	{
		loops[i].Replace(label, L);
	}    
}    

void graph::RemoveAll(long Label)
{
	edgeiterator I(Edges);
	do
	{
		((I++).Image).RemoveAll(Label);
	} while (!I.AtOrigin());
}

void graph::LoopRemoveAll(long Label)
{
	for (vector<int>::size_type i=0; i<loops.size(); ++i)
	{
		loops[i].RemoveAll(Label);
	}    
}    

bool graph::Tighten()
{
	// Tighten loops
	for (vector<int>::size_type i=0; i<loops.size(); ++i) loops[i].CyclicTighten();
	// Tighten edge images
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

std::vector<std::string> graph::TransitionMatrix(matrixformat format, bool includeNonMain)
{
	matrix M(*this, includeNonMain);
	std::vector<std::string> result;
	if (format==raw)
	{
		//Determine longest output length of entries in each column
		std::vector<uint> longest(M.size(),1);
		for (uint i=0; i<M.size(); ++i) for (uint j=0; j<M.size(); ++j)
		{
			ostringstream oss; 
			oss << M.element(i,j);
			if (oss.str().length()>longest[j]) longest[j]=static_cast<uint>(oss.str().length());
		}
		for (uint i=0; i<M.size(); ++i)
		{
			result.push_back(std::string());
			for (uint j=0; j<M.size(); ++j)
			{
				if (j>0) result.back() += " ";
				ostringstream oss;
				oss.width(longest[j]);
				oss << right << M.element(i,j);
				result.back() += oss.str();
			}
		}
	}
	if (format==maple) 
	{
		result.push_back(std::string("<"));
		for (uint i=0; i<M.size(); ++i)
		{
			result.push_back(std::string("<"));
			for (uint j=0; j<M.size(); ++j)
			{
				ostringstream oss; oss << M.element(j,i);
				result.back() += oss.str();
				if (j<M.size()-1) result.back() += ",";
				else
				{
					result.back() += ">";
					if (i<M.size()-1) result.back() += "|";
				}
			}
		}
		result.push_back(std::string(">"));
	}
	if (format==latex)
	{
		result.push_back(std::string("\\left("));
		result.push_back(std::string("\\begin{array}{"));
		result.back() += (std::string(M.size(), 'c') + "}");
		for (uint i=0; i<M.size(); ++i)
		{
			if (i>0) result.back() += " \\\\";
			result.push_back(std::string());
			for (uint j=0; j<M.size(); ++j)
			{
				ostringstream oss;
				if (j>0) oss << " & ";
				oss << M.element(i,j);
				result.back() += oss.str();
			}
		}
		result.push_back(std::string("\\end{array}"));
		result.push_back(std::string("\\right)"));
	}
	return result;
}

#ifdef __CHARPOLY
std::string graph::CharacteristicPolynomial(bool factorise, bool includeNonMain)
{
	using namespace std;
	using namespace NTL;
	mat_ZZ M;
	uint i;
	//First load up transition matrix in NTL matrix
	//Identify main edges
	FindTypes();
	uint GEdges = Edges.TopIndex(); //Total number of edges in G
	uint n = 0;
	if (includeNonMain)
	{
		n = GEdges;
		M.SetDims(n, n);
		for (i=0; i<n; ++i) for (uint j=0; j<n; ++j)
		{
			M[i][j] = 0;
			intarray& Im = Edges[j+1].Image;
			long Target = Edges[i+1].Label;
			if (!Im.TopIndex()) continue;
			intiterator I(Im);
			do
			{
				long Shot = (I++);
				if (Shot == Target || Shot == -Target) ++M[i][j];
			} while (!I.AtOrigin());
		}
	}
	else
	{
		uint* MainEdges = new uint[GEdges]; //Will Store Indices of main edges
		for (i=1; i<=GEdges; i++)
			if (Edges[i].Type == Main) MainEdges[n++]=i;
		//Set up remaining data members

		M.SetDims(n,n);
		//Calculate matrix entries
		for (i=0; i<n; i++) for (uint j=0; j<n; j++)
		{
			M[i][j]=0;
			intarray& Im = Edges[MainEdges[j]].Image;
			long Target = Edges[MainEdges[i]].Label;
			if (!Im.TopIndex()) continue;
			intiterator I(Im);
			do
			{
				long Shot = (I++);
				if (Shot == Target || Shot == -Target) ++M[i][j];
			} while (!I.AtOrigin());
		}
		delete [] MainEdges;
	}
	//Now find the characteristic polynomial
	ZZX f;
	CharPoly(f,M);
	if (factorise)
	{
		//Then factorise it...
		vec_pair_ZZX_long factors;
		ZZ c;

		factor(c, factors, f);
		//Make a string out of the factors
		ostringstream out;
		out << factors;
		//Convert into friendly notation
		istringstream in(out.str()); 
		ostringstream friendly;
		bool readingpoly = true;
		char ch;
		int coefficient;
		int power = 0;
		bool first = true;
		friendly << '(';
		while (in.good())
		{
			ch = static_cast<char>(in.get());
			if (ch == '-') //negative coefficient. Must be reading a polynomial.
			{
				friendly << '-';
				in >> coefficient;
				if (coefficient>0) 
				{
					if (coefficient>1 || power == 0) friendly << coefficient;
					if (power==1) friendly << 'X';
					if (power>1) friendly << "X^" << power;
					first = false;
				}    
				++power;
			}    
			if ( (ch >= '0') && (ch <= '9') ) //positive coefficient. May be reading a polynomial, or the power
			{
				in.putback(ch);
				in >> coefficient;
				if (readingpoly)
				{
					if (coefficient>0)
					{
						if (!first) friendly << '+';
						if (coefficient>1 || power == 0) friendly << coefficient;
						if (power==1) friendly << 'X';
						if (power>1) friendly << "X^" << power;
						first = false;
					}    
					++power;
				}    
				else if (coefficient>1)
				{
					friendly << "^" << coefficient;
				}    
			}  
			if (ch==']')
			{
				if (readingpoly) friendly << ')';
				else friendly << '(';
				readingpoly = !readingpoly;
				power = 0;
				first = true;
			}      
		}    
		string result = friendly.str();
		if (result[result.length()-2]=='(')
		{
#ifdef __WINDOWSVERSION
			result.erase(result.end()-2,result.end());
#else
			result.erase(--result.end()); result.erase(--result.end());
#endif
		}    
		return result;
	}
	else //return unfactored charpoly
	{
		ostringstream out;
		out << f;
		istringstream in(out.str());
		ostringstream friendly;
		char ch;
		int power = 0;
		int coefficient;
		bool first = true;
		while (in.good())
		{
			ch = static_cast<char>(in.get());
			if (ch == '-') //negative coefficient. 
			{
				friendly << '-';
				in >> coefficient;
				if (coefficient>0) 
				{
					if (coefficient>1 || power == 0) friendly << coefficient;
					if (power==1) friendly << 'X';
					if (power>1) friendly << "X^" << power;
					first = false;
				}    
				++power;
			} 
			if ( (ch >= '0') && (ch <= '9') ) //positive coefficient. 
			{
				in.putback(ch);
				in >> coefficient;
				if (coefficient>0)
				{
					if (!first) friendly << '+';
					if (coefficient>1 || power == 0) friendly << coefficient;
					if (power==1) friendly << 'X';
					if (power>1) friendly << "X^" << power;
					first = false;
				}    
				++power;   
			}   
		} 
		return friendly.str();   
	}        
}   
#endif 

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
			if (Now.Image.TopIndex()>0)
			{
				do
				{
					uint Index = FindEdge(J++);
					if (!Edges[Index].Flag)
					{
						ShouldFlag = false;
						continue;
					}
				} while (!J.AtOrigin());
			}
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
	for (i=1; i<=NumberEdges(); i++)
	{
		Edges[i].Image.Flush();
		Edges[i].EI.Path.clear();
	}
	for (i=1; i<=NumberVertices(); i++) Vertices[i].Edges.Flush();
	Edges.Flush();
	Vertices.Flush();
	Turns.Flush();
	Reduction.Flush();
	NextVertexLabel = 1; NextEdgeLabel = 1; Punctures = 0;
	Type = Unknown;
	loops.clear();
	looplabels.clear();
	singularities.clear();
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


ostream& operator<<(ostream& Out, turn T)
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
	if (!(Type == Reducible1)) THROW("Trying to find reduction with no invariant subgraph",1);
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

void graph::FindSingularities()
{
	if (Type !=pA) THROW("Trying to find singularities for non pA graph map",1);
	if (!singularities.empty()) return;
	//I believe that we must already have found gates to reach this stage. Also must have relabelled.
	//Make a nicer list of gates and infinitesimal edges
	//First the gates
	std::vector<vertexGateInformation> v(Vertices.TopIndex()+1);
	uint j=3; //index into Reduction
	for (uint i=1; static_cast<long>(i)<=Vertices.TopIndex(); ++i)
	{
		vector<vertexGateInformation>::size_type CurrentVertexNumber = static_cast<vector<vertexGateInformation>::size_type>(Reduction[j]);
		j+=2;
		vector<long> CurrentGate;
		while (Reduction[j]!=0)
		{
			while (Reduction[j]!=0) CurrentGate.push_back(Reduction[j++]);
			v[CurrentVertexNumber].gates.push_back(CurrentGate);
			CurrentGate.clear();
			j++;
		}
		j+=2;
	}
	//Then the infinitesimal edges
	for (uint i=1; static_cast<long>(i)<=Turns.TopIndex(); ++i)
	{
		v[Turns[i].Level].infinitesimalEdges.push_back(make_pair(Turns[i].i,Turns[i].j));
	}
	map<long, cuspCounter> cusps;
	set<pair<uint, int> > interiorSingularities; //uint is vertex label, int is number of prongs
	for (vector<vertexGateInformation>::size_type i = 1; i<v.size(); ++i)
	{
		if (v[i].infinitesimalEdges.size() != v[i].gates.size() && v[i].infinitesimalEdges.size() != v[i].gates.size()-1)
			THROW("Error in FindSingularities",1);
		if (v[i].infinitesimalEdges.size() == v[i].gates.size()) //All gates connected
		{
			//Add a new interior singularity
			interiorSingularities.insert(interiorSingularities.end(), make_pair(static_cast<uint>(i), static_cast<int>(v[i].gates.size())));
			//Fill in exterior edge connections
			for (vector<vector<long> >::size_type k = 0; k < v[i].gates.size(); ++k)
			{
				for (vector<long>::size_type l = 0; l<v[i].gates[k].size()-1; ++l) cusps[-v[i].gates[k][l]] = cuspCounter(v[i].gates[k][l+1],1);
				if (k<v[i].gates.size()-1) cusps[-v[i].gates[k][v[i].gates[k].size()-1]] = cuspCounter(v[i].gates[k+1][0],0);
				else cusps[-v[i].gates[k][v[i].gates[k].size()-1]] = cuspCounter(v[i].gates[0][0],0);
			}
		}
		else //One missing infinitesimal edge
		{
			//Fill in exterior edge connections as if all present
			for (vector<vector<long> >::size_type k = 0; k < v[i].gates.size(); ++k)
			{
				for (vector<long>::size_type l = 0; l<v[i].gates[k].size()-1; ++l) cusps[-v[i].gates[k][l]] = cuspCounter(v[i].gates[k][l+1],1);
				if (k<v[i].gates.size()-1) cusps[-v[i].gates[k][v[i].gates[k].size()-1]] = cuspCounter(v[i].gates[k+1][0],0);
				else cusps[-v[i].gates[k][v[i].gates[k].size()-1]] = cuspCounter(v[i].gates[0][0],0);
			}
			//Then modify one due to missing edge
			//First find which gates have only one infinitesimal edge to them
			std::set<int> onlyOne;
			for (vector<vector<long> >::size_type k = 0; k<v[i].gates.size(); ++k)
			{
				int count = 0;
				for (vector<pair<long, long> >::size_type l = 0; l<v[i].infinitesimalEdges.size(); ++l)
					if (Find(v[i].gates[k],v[i].infinitesimalEdges[l].first) || Find(v[i].gates[k],v[i].infinitesimalEdges[l].second)) ++count;

				if (count != 1 && count != 2) THROW("error in findSingularities", 1);
				if (count == 1) onlyOne.insert(onlyOne.end(), static_cast<int>(k));
			}
			if (onlyOne.size() != 2) THROW("Error in findSingularities", 1);
			set<int>::iterator I = onlyOne.begin();
			int first = *I; ++I; int second = *I;
			if (first == 0 && second != 1)
			{
				cusps[-v[i].gates[second][v[i].gates[second].size()-1]].cusps = v[i].gates.size()-2;
			}
			else
			{
				cusps[-v[i].gates[first][v[i].gates[first].size()-1]].cusps = v[i].gates.size()-2;
			}
		}
	}
	//Load interior singularities into list
	while (!interiorSingularities.empty())
	{
		singularityOrbit O;
		pair<uint, int> P = *interiorSingularities.begin();
		list<long> S(1, P.first);
		O.singularities.push_back(singularity(P.second, S, true));
		interiorSingularities.erase(interiorSingularities.begin());
		uint Target = P.first;
		uint Image = Vertices[FindVertex(P.first)].GetImage();
		while (Image != Target)
		{
			set<pair<uint, int> >::iterator I = interiorSingularities.begin(); 
			while (I->first != Image) ++I;
			list<long> T(1,I->first);
			O.singularities.push_back(singularity(I->second,T,true));
			Image = Vertices[FindVertex(I->first)].GetImage();
			interiorSingularities.erase(I);
		}
        singularities.push_back(O);
	}

	//Load exterior singularities
	while (!cusps.empty())
	{
		singularityOrbit O;
		//Take any initial edge and follow it round, counting cusps as we go.
		long initialEdge = cusps.begin()->first;
		int prongs = 0;
		list<long> path;
		long currentEdge = initialEdge;
		do
		{
			prongs += cusps[currentEdge].cusps;
			cusps[currentEdge].considered = true;
			path.push_back(currentEdge);
			currentEdge = cusps[currentEdge].nextEdge;
		} while (currentEdge != initialEdge);
		O.singularities.push_back(singularity(prongs, path, false));
		//Now find other singularities in the orbit. Iterating the bounding path and cyclically cancelling
		//Gives bounding path of image singularity. We just need to search for a single edge in this cyclic path
		//to detect closure of the orbit.
		long Target = path.front();
		bool finished = false;
		do
		{
			//Calculate image loop
			list<long> image;
			for (list<long>::iterator I = path.begin(); I != path.end(); ++I)
			{
				if (*I>0)
				{
					intarray& A = Edges[FindEdge(*I)].Image;
					for (uint i=1; static_cast<long>(i)<=A.TopIndex(); ++i) image.push_back(A[i]);
				}
				else
				{
					intarray& A = Edges[FindEdge(-(*I))].Image;
					for (uint i=A.TopIndex(); i>=1; --i) image.push_back(-A[i]);
				}
			}
			//tighten. First remove interior cancellations
			tighten(image);
			//Then remove cancellations across the end
			while (image.front() == -image.back())
			{
				image.erase(image.begin());
				list<long>::iterator I = image.end(); 
				--I;
				image.erase(I);
			}
			//Have we returned to starting singularity?
			if (Find(image, Target))
			{
				finished = true;
			}
			else
			{
				O.singularities.push_back(singularity(prongs, image, false));
				for (list<long>::iterator I = image.begin(); I != image.end(); ++I) cusps[*I].considered = true;
				path = image;
			}
		} while (!finished);


		singularities.push_back(O);
		
		finished = false;
		while (!finished)
		{
			finished = true;
			for (map<long, cuspCounter>::iterator I = cusps.begin(); I != cusps.end(); ++I)
			{
				if (I->second.considered)
				{
					cusps.erase(I);
					finished = false;
					break;
				}
			}
		}
	}

	stable_sort(singularities.begin(), singularities.end());
}

void graph::FindGates()
{
	if (Type != pA_or_red && Type != pA && Type != Reducible2) THROW("Trying to find gates with non-efficient graph map",1);
	Reduction.Flush(); //Will hold gates in format (0,vert label,0,gate1,0,gate2,0,..,gaten,000,vertlabel..)
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
		// JLT: Initialised Label1 and Label2 to remove a compiler complaint.
		// In theory the loop could fail to assign any values to them.
		long Label1 = 0, Label2 = 0; uint Steps = 0;
		for (uint i=1; i<=NumberVertices(); i++)
		{
			if (OnPInd(i))
			{

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

bool graph::SingleVertexEmbeddingTighten(uint Index)
{
	vertex& Now = Vertices[Index];
	if (Now.Edges.TopIndex()<=1) return false;
	//Count the number of edges starting with each of four possible starts of path.
	int TL=0, TR=0, BL=0, BR=0;
	for (uint i=1; static_cast<long>(i)<=Now.Edges.TopIndex(); ++i) if (!(Edges[FindEdge(Now.Edges[i])].EI.Path.empty()))
	{
		int Crossing = (Now.Edges[i]>0) ? Edges[FindEdge(Now.Edges[i])].EI.Path.front() : Edges[FindEdge(Now.Edges[i])].EI.Path.back();
		if (Crossing == Now.Region) ++TL;
		if (Crossing == -Now.Region) ++BL;
		if (Crossing == Now.Region+1) ++TR;
		if (Crossing == -(Now.Region+1)) ++BR;
	}
	int Majority = 0;
	if (static_cast<double>(TL)> Now.Edges.TopIndex()/2.0) {Majority = Now.Region; --Now.Region;}
	if (static_cast<double>(BL)> Now.Edges.TopIndex()/2.0) {Majority = -Now.Region; --Now.Region;}
	if (static_cast<double>(TR)> Now.Edges.TopIndex()/2.0) {Majority = Now.Region+1; ++Now.Region;}
	if (static_cast<double>(BR)> Now.Edges.TopIndex()/2.0) {Majority = -(Now.Region+1); ++Now.Region;}

	if (Majority==0) return false;
	for (uint i=1; static_cast<long>(i)<=Now.Edges.TopIndex(); ++i)
	{
		uint Index = FindEdge(Now.Edges[i]);
		if (Now.Edges[i]>0)
		{
			if (!Edges[Index].EI.Path.empty() && Edges[Index].EI.Path.front() == Majority) Edges[Index].EI.Path.erase(Edges[Index].EI.Path.begin());
			else Edges[Index].EI.Path.insert(Edges[Index].EI.Path.begin(), Majority);
			Edges[Index].EI.Start = Now.Region;
		}
		else
		{

			if (!Edges[Index].EI.Path.empty() && Edges[Index].EI.Path.back() == Majority) 
			{
				std::list<int>::iterator I = Edges[Index].EI.Path.end();
				Edges[Index].EI.Path.erase(--I);
			}
			else Edges[Index].EI.Path.push_back(Majority);
			Edges[Index].EI.End = Now.Region;
		}
	}
	return true;
}

} // namespace trains
