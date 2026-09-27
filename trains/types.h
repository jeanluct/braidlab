// Named integer types for graph and braid quantities.
//
// These are plain aliases: the compiler sees long or uint, so they document
// intent in signatures but do not stop one kind from being passed as another.
// Never overload a function on two of them that share or differ only in
// signedness (see IsPeripheralLabel/IsPeripheralIndex).
//
// Edge images and vertex edge lists are intarrays (MyArray<long>) whose
// entries are EdgeLabels.
#ifndef __TYPES_H
#define __TYPES_H

#include "General.h"

namespace trains {

typedef long EdgeLabel;      // Signed: -L is edge L traversed backwards
typedef uint EdgeIndex;      // 1-based position in graph::Edges
typedef uint VertexLabel;    // Unique vertex id (edge Start/End, vertex Image)
typedef uint VertexIndex;    // 1-based position in graph::Vertices
typedef uint PunctureIndex;  // 1..Punctures; 0 means none
typedef long BraidGenerator; // i or -i for sigma_i or its inverse

} // namespace trains

#endif
