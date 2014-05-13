//---------------------------------------------------------------------------
#ifndef tttH
#define tttH

#include <list>
#include <map>
#include <queue>
#include "graph.h"

namespace trains {

using namespace std;
//---------------------------------------------------------------------------

typedef list<int> intlist;
typedef list<intlist> intintlist;
typedef map<int, intlist> key;

class TTT {
	intlist Type; //list of edges around track
	intintlist Image; //list of images
	key Key; //Correspondence with edges of G. Key[i] gives edges of G corr edge i
	int NumEdges; //Number of new style edges
public:
	explicit TTT(graph& G); //load up from G.
	friend ostream& operator << (ostream& Out, TTT& T);
	bool operator<(TTT& T); //Returns true if *this is contained in T
	int Euler(); //Calculates sum over vertices of valence >=3 of valence-2. Should be declength+1
};

} // namespace trains

#endif
