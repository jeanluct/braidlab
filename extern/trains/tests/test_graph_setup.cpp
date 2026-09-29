#include <iostream>

#include "trains/graph.h"

#include "test_util.h"

using trains::braid;
using trains::graph;
using trains::intarray;

static braid make_braid_3(const intarray& word) {
    braid b;
    b.Set(3, word);
    return b;
}

int main() {
    graph g;

    // Identity graph and invariants
    g.IdentityGraph(4);
    CHECK_EQ(g.Punctures, static_cast<trains::uint>(4));
    CHECK_EQ(g.NumberEdges(), static_cast<trains::uint>(7));
    CHECK_EQ(g.NumberVertices(), static_cast<trains::uint>(4));
    CHECK_TRUE(g.SanityCheck());

    // ActOn + relabel path
    g.ActOn(1);
    g.ActOn(-1);
    g.ReLabel();
    CHECK_TRUE(g.SanityCheck());

    // Braid setup path
    intarray w;
    w[1] = 1;
    w[2] = -2;
    braid b = make_braid_3(w);
    g.Set(b);
    CHECK_TRUE(g.SanityCheck());
    CHECK_EQ(g.NumberEdges(), static_cast<trains::uint>(5));
    CHECK_EQ(g.NumberVertices(), static_cast<trains::uint>(3));

    // Boundary peripheral setup path
    g.BoundaryPeripheralSet(b);
    CHECK_TRUE(g.SanityCheck());
    CHECK_TRUE(g.Punctures >= static_cast<trains::uint>(1));

    std::cout << "test_graph_setup: ok\n";
    return 0;
}
