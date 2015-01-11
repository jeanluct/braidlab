#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "trains/Matrix.h"

namespace trains {

matrix::matrix(uint size) : n(size), p(new long*[n]), GrowthDone(false),
IrredDone(false), Evec(new decimal[n])
{
	for (uint i=0; i<n; i++) p[i] = new long[n];
}

matrix::matrix(graph& G, bool includeNonMain) : GrowthDone(false), IrredDone(false)
{
	if (includeNonMain)
	{
		n = G.Edges.TopIndex();
		Evec = new decimal[n];
		p = new long*[n];
		for (uint i = 0; i<n; ++i) p[i] = new long[n];
		for (uint i = 0; i<n; ++i) for (uint j = 0; j<n; ++j)
		{
			p[i][j] = 0;
			intarray& Im = G.Edges[j+1].Image;
			long Target = G.Edges[i+1].Label;
			if (!Im.TopIndex()) continue;
			intiterator I(Im);
			do
			{
				long Shot = (I++);
				if (Shot == Target || Shot == -Target) ++p[i][j];
			} while (!I.AtOrigin());
		}
	}
	else
	{
		uint i;
		//Identify main edges
		G.FindTypes();
		uint GEdges = G.Edges.TopIndex(); //Total number of edges in G
		n = 0;
		uint* MainEdges = new uint[GEdges]; //Will Store Indices of main edges
		for (i=1; i<=GEdges; i++)
			if (G.Edges[i].Type == Main) MainEdges[n++]=i;
		//Set up remaining data members
		Evec = new decimal[n];
		p = new long*[n];
		for (i=0; i<n; i++) p[i] = new long[n];
		//Calculate matrix entries
		for (i=0; i<n; i++) for (uint j=0; j<n; j++)
		{
			p[i][j] = 0;
			intarray& Im = G.Edges[MainEdges[j]].Image;
			long Target = G.Edges[MainEdges[i]].Label;
			if (!Im.TopIndex()) continue;
			intiterator I(Im);
			do
			{
				long Shot = (I++);
				if (Shot == Target || Shot == -Target) p[i][j] = p[i][j]+1;
			} while (!I.AtOrigin());
		}
		delete [] MainEdges;
	}
}

matrix::~matrix()
{
	for (uint i=0; i<n; i++) delete [] p[i];
	delete [] p;
	delete [] Evec;
}


void matrix::GrowthCalc()
{
	if (GrowthDone) return;
	if (! IsIrreducible()) return;
	// Ensure convergence by adding identity matrix
	uint i;
	for (i=0; i<n; i++) p[i][i]+=1;
	GrowthDone = true;
	decimal* Temp = new decimal[n];
	for (i=0; i<n; i++) Temp[i] = 1.0/SQRT(static_cast<long double>(n));
	decimal Eval = 1.0;
	bool Finished = false;
	while (!Finished)
	{
		Growth = Eval;
		for (i=0; i<n; i++)
		{
			Evec[i] = 0.0;
			for (uint j=0; j<n; j++) Evec[i] += decimal(p[i][j])*Temp[j];
		}
		Eval = EvecModulus();
		Finished = true;
		for (i=0; i<n; i++)
		{
			decimal Test = Evec[i]/Eval;
			if (FABS(Test-Temp[i])>TOL/10.0) Finished = false;
			Temp[i] = Test;
		}
	}
	for (i=0; i<n; i++) Evec[i] = Temp[i];
	Growth = Eval-1.0; //Compensate for added identity
	for (i=0; i<n; i++)  p[i][i]-=1;
	delete [] Temp;
}

decimal matrix::EvecModulus()
{
	decimal Sum = 0.0;
	for (uint i=0; i<n; i++) Sum += (Evec[i]*Evec[i]);
	return SQRT(Sum);
}

decimal matrix::GrowthRate()
{
	if (! IsIrreducible())
		THROW("Trying to compute growth rate of reducible matrix",1);
	GrowthCalc();
	return Growth;
}

bool matrix::IsBigger(uint i, uint j)
{
	if (! IsIrreducible())
		THROW("Trying to compare eigenvector entries of reducible matrix",1);
	GrowthCalc();
	if (Evec[i] > Evec[j]) return true;
	return false;
}


bool matrix::IsIrreducible(bool* Indices)
{
	if (IrredDone) return Irreducible;
	IrredDone = true;
	Irreducible = false;
	bool *InSet = new bool[n], *Changed = new bool[n], *NewChanged = new bool[n];
	for (uint i=0; i<n; i++) // See if i contained in invariant proper subset
	{
		uint j;
		for (j=0; j<n; j++)
			InSet[j] = Changed[j] = NewChanged[j] = false;
		InSet[i] = Changed[i] = true;
		bool Finished = false;
		bool Bad = false;
		while (!Finished)
		{
			Finished = true;
			for (j=i; j<n; j++)
			{
				if (Changed[j])
				{
					uint k;
					for (k=0; k<i; k++) if (p[k][j]) Bad = true;
					for (k=i+1; k<n; k++)
						if ((p[k][j]) && (!InSet[k]))
						{
							InSet[k] = true; NewChanged[k] = true; Finished = false;
						}
				}
				if (Bad) break;
			}
			if (Bad) break;
			for (j=0; j<n; j++)
			{
				if (NewChanged[j]) Changed[j] = true; else Changed[j] = false;
				NewChanged[j] = false;
			}
		}
		if (!Bad)
		{
			if (i>0)
			{
				if (Indices) for (i=0; i<n; i++) Indices[i] = InSet[i];
				delete[] InSet; delete[] Changed; delete[] NewChanged; return false;
			}
			bool Result = false;
			for (j=1; j<n; j++) if (!InSet[j]) Result = true;
			if (Result)
			{
				if (Indices) for (i=0; i<n; i++) Indices[i] = InSet[i];
				delete[] InSet; delete[] Changed; delete[] NewChanged; return false;
			}
		}
	}
	Irreducible = true;
	delete [] InSet; delete [] Changed; delete[] NewChanged;
	return Irreducible;
}



void matrix::Transpose()
{
	for (uint i=0; i<n; ++i)
		for (uint j=0; j<i; ++j)
		{
			long temp  = p[i][j];
			p[i][j] = p[j][i];
			p[j][i] = temp;
		}
		GrowthDone = false;
}

} // namespace trains
