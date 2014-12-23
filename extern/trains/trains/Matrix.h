#ifndef __MATRIX_H
#define __MATRIX_H

#include "decimal.h"
#include "General.h"
#include "graph.h"
#include <iostream>
#include <cstdlib>

namespace trains {

using namespace std;

class matrix {
	uint n; // Size of square matrix
	long** p; //Pointer to data entries
	bool GrowthDone;  //Has growth rate been calculated
	decimal Growth;
	bool IrredDone;  // Has irreducibility been determined
	bool Irreducible;
	decimal* Evec;
	void GrowthCalc();
	decimal EvecModulus();
public:
	matrix(uint size);
	matrix(graph& G, bool includeNonMain = false); //Construct transition matrix from Graph
	~matrix();
	uint size() {return n;}
	long element(uint i, uint j) {return p[i][j];}
	decimal GrowthRate();
	bool IsBigger(uint i, uint j); // Is entry i in PF evec bigger than entry j
	decimal EvecEntry(uint i) {GrowthCalc(); return Evec[i];}
	bool IsIrreducible(bool* Indices = NULL); //if Indices is non-null, returns invariant edges here
	void Transpose();
};

} // namespace trains

#endif
