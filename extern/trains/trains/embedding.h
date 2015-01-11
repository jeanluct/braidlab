//---------------------------------------------------------------------------
#ifndef embeddingH
#define embeddingH

#include <list>
#include <iostream>

namespace trains {

class EmbeddingInformation {
public:
	EmbeddingInformation() : Start(-1), End(-1) {};
	int Start;
	int End; //Regions of start and end of edge. Redundant information, but convenient?
	std::list<int> Path; //List of boundaries crossed by edge.
	void append(int i) {Path.push_back(i);}
	void prepend(int i) {Path.push_front(i);}
	void prepend(const EmbeddingInformation& EI); //Put EI.Path at front. Changes Start to EI.Start.
	void append(const EmbeddingInformation& EI);
	void appendinverse(EmbeddingInformation& EI); //Put EI.Path^(-1) at end.  Changes End to EI.Start. Seems EI can't be const because of reverse iterator restrictions
	void prependinverse(EmbeddingInformation& EI);
	void tighten() {while (single_tighten());} //remove successive crossings of same boundary.
private:
	bool single_tighten();
};

std::ostream& operator<<(std::ostream& out, const EmbeddingInformation& EI);

} // namespace trains


//---------------------------------------------------------------------------
#endif
