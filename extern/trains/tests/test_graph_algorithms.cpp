#include <iostream>

#include "trains/graph.h"

#include "test_util.h"

using trains::braid;
using trains::graph;
using trains::intarray;

static graph make_sample_graph() {
    intarray w;
    w[1] = 1;
    w[2] = -2;
    braid b;
    b.Set(3, w);

    graph g;
    g.Set(b);
    return g;
}

int main() {
    graph g = make_sample_graph();
    CHECK_TRUE(g.SanityCheck());

    g.FindTypes();
    CHECK_TRUE(g.HasIrreducibleMatrix());

    // Exercise algorithmic mutators and validate graph remains consistent.
    g.PullTight();
    CHECK_TRUE(g.SanityCheck());

    g.SetType(trains::pA_or_red);
    g.FindTrack();
    CHECK_TRUE(g.GetType() == trains::pA || g.GetType() == trains::Reducible2);
    CHECK_TRUE(g.SanityCheck());

    std::cout << "test_graph_algorithms: ok\n";
    return 0;
}
