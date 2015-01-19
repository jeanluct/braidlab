#ifndef __BATCH_H
#define __BATCH_H

#include "General.h"
#ifdef VS2005
#include "graph.h"
#endif

namespace trains {

bool BatchProcess(char* Filename, int Prec
#ifdef VS2005
				  ,graph& RemoteGraph
#endif
				  );  

bool BatchProcess(std::istream& iFile, int Prec
#ifdef VS2005
				  ,graph& RemoteGraph
#endif
				  );  
} // namespace trains

#endif
