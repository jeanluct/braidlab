#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

//---------------------------------------------------------------------------

#include "ttt.h"
//---------------------------------------------------------------------------


namespace trains {

TTT::TTT(graph& G)
{
	G.TampDown();
	for (uint u=1; u<=G.NumberEdges(); u++) G.Edges[u].Key = 0; // Marks whether edge seen before
	uint CurrentVertex = G.From(1); //Assumption is that there's a single loop about puncture 1.
	uint NewEdge = 1;
	//Find other edge emanating from first puncture. Assumption is there's only 1 of them
	intarray& E = (G.Vertices[G.FindVertex(CurrentVertex)]).Edges;
	long l = -1;
	uint u = uint(E.Find(l));
	long CurrentEdge = (u==uint(E.TopIndex())) ? E[1] : E[u+1];
	long EndEdge = -CurrentEdge;
	//add this edge to key for edge 1, and add 1 to Type
	Type.push_back(NewEdge);
	(Key[NewEdge]).push_back(int(CurrentEdge));
	//mark edge as seen
	G.Edges[G.FindEdge(CurrentEdge)].Key = NewEdge;
	//Now move around graph...
	do {
		CurrentEdge = -CurrentEdge;
		CurrentVertex = G.From(CurrentEdge);
		if (G.OnP(CurrentVertex) == G.Punctures) Type.push_back(-1);
		intarray& F = (G.Vertices[G.FindVertex(CurrentVertex)]).Edges;
		int i = F.TopIndex(); //Number of edges at vertex.
		if (G.OnP(CurrentVertex)>0) i-=2; //Ignore peripheral edges
		u = uint(F.Find(CurrentEdge));
		do {
			u++; if (long(u)>F.TopIndex()) u=1;
		} while (G.IsPeripheral(F[u]));
		CurrentEdge = F[u];
		if (i!=2) // start new edge
		{
			uint v = G.FindEdge(CurrentEdge);
			if (G.Edges[v].Key == 0) //edge not seen before
			{
				NewEdge++;
				Type.push_back(NewEdge);
				(Key[NewEdge]).push_back(int(CurrentEdge));
				G.Edges[v].Key = NewEdge;
			}
			else //edge seen before
			{
				Type.push_back(G.Edges[v].Key);
			}
		}
		else // continue with current edge
		{
			int& K=G.Edges[G.FindEdge(CurrentEdge)].Key;
			if (K==0)
			{
				(Key[NewEdge]).push_back(int(CurrentEdge));
				K = NewEdge;
			}
		}

	} while (CurrentEdge != EndEdge);


	NumEdges = NewEdge;

	//Now work out images of TTT edges

	intlist Void;
	for (int i=1; i<=int(NewEdge); i++) Image.push_back(Void);
	intintlist::iterator iteriter = Image.begin();
	for (int i=1; i<=int(NewEdge); i++)        // Loop over new style edges
	{
		intlist::iterator iter;
		long NowEdge = 0, LastEdge = 0;
		for (iter = Key[i].begin(); iter != Key[i].end(); iter++)    // Loop over old edges in new edge
		{
			long Label = long (*iter);
			intarray E = G.Edges[G.FindEdge(Label)].Image;
			int Start, Inc;
			if (Label>0) //traverse forward
			{
				Start = 1; Inc=1;
			}
			else
			{
				Start = E.TopIndex(); Inc=-1;
			}
			for (int j=Start; j<=E.TopIndex() && j>=1; j+=Inc)
			{
				int K = G.Edges[G.FindEdge(E[j])].Key;
				long Test = (Label>0) ? -LastEdge : LastEdge;
				if (K>0 && (K != NowEdge || E[j] == Test))
				{
					NowEdge = K;
					(*iteriter).push_back(K);
				}
				if (K>0) LastEdge = (Label>0) ? E[j] : -E[j];
			}
		}
		iteriter++;
	}
}


ostream& operator << (ostream& Out, TTT& T)
{
	intlist::iterator iter;
	intintlist::iterator iteriter;
	for (iter = T.Type.begin(); iter != T.Type.end(); iter++)
		if (*iter >= 0) Out << *iter << " ";
		else Out << "* ";
		Out << '\n';
		int i=0;
		for (iteriter = T.Image.begin(); iteriter != T.Image.end(); iteriter++)
		{
			i++;
			Out << i << " -> ";
			for (iter = (*iteriter).begin(); iter != (*iteriter).end(); iter++) Out << *iter << " ";
			Out << '\n';
		}
		return Out;
}

bool TTT::operator<(TTT& T)
{
	if (Type != T.Type) return false;
	intintlist::iterator I1 = Image.begin(), I2 = T.Image.begin();
	//First check whether first image of *this is a subset of first image of T
	intlist::iterator J1=(*I1).begin(), J2 = (*I2).begin();
	int n = static_cast<int>((*I1).size()), m=static_cast<int>((*I2).size());
	if (n > m) return false;
	for (int i=0; i<m-n; i++) J2++;
	for (;J2 != (*I2).end(); J1++, J2++) if (*J2 != *J1) return false;

	//Other images must be identical
	for (I1++, I2++; I1 != Image.end(); I1++, I2++)
		if (*I1 != *I2) return false;
	return true;
}

int TTT::Euler()
{
	queue<intlist::iterator> Q;
	Q.push(Type.begin());
	int Result = 0;
	while (!Q.empty())
	{
		intlist::iterator I = Q.front();
		Q.pop();
		int Count = 1;
		int ReturnTo = *I;
		do
		{
			I++; if (*I<0) I++; Count++;
			if (*I != ReturnTo)
			{
				intlist::iterator J=I;
				J++; if (*J<0) J++;
				if (*J==*I)
				{
					I++; if (*I<0) I++; Count++;
				}
				else
				{
					Q.push(I);
					int Search = *I;
					I = find(J, Type.end(), Search);
					Count++;
				}
			}
		} while (*I != ReturnTo);
		Result += (Count/2 - 2);
	}
	return Result;
}

} // namespace trains
