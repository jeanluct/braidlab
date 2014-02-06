#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "embedding.h"
#include <iterator>
#include <algorithm>

namespace trains {

using namespace std;

bool EmbeddingInformation::single_tighten()
{
	if (Path.empty()) return false;
	list<int>::iterator I = Path.begin();
	while (true)
	{
		list<int>::iterator J = I; ++J;
		if (J==Path.end()) return false;
		if (*I==*J)
		{
			++J;
			Path.erase(I, J);
			return true;
		}
		++I;
	}
}

void EmbeddingInformation::prepend(const EmbeddingInformation& EI)
{
	Path.insert(Path.begin(), EI.Path.begin(), EI.Path.end());
	Start = EI.Start;
}

void EmbeddingInformation::append(const EmbeddingInformation& EI)
{
	Path.insert(Path.end(), EI.Path.begin(), EI.Path.end());
	End = EI.End;
}

void EmbeddingInformation::prependinverse(EmbeddingInformation& EI)
{
	Path.insert(Path.begin(), EI.Path.rbegin(), EI.Path.rend());
	Start = EI.End;
}

void EmbeddingInformation::appendinverse(EmbeddingInformation& EI)
{
	Path.insert(Path.end(), EI.Path.rbegin(), EI.Path.rend());
	End = EI.Start;
}

ostream& operator<<(ostream& out, const EmbeddingInformation& EI)
{
	out << "Path (" << EI.Start << " -> " << EI.End << "):  ";
	copy(EI.Path.begin(), EI.Path.end(), ostream_iterator<int>(out, " "));
	return out;
}

} // namespace trains
