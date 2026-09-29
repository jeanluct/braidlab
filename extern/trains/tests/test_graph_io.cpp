#include <cstdio>
#include <iostream>
#include <string>

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

    const std::string fn = "tmp_graph_roundtrip.grm";
    g.Save(fn);

    graph loaded;
    loaded.Load(fn);
    std::remove(fn.c_str());

    CHECK_TRUE(loaded.SanityCheck());
    CHECK_EQ(loaded.NumberEdges(), g.NumberEdges());
    CHECK_EQ(loaded.NumberVertices(), g.NumberVertices());

    std::cout << "test_graph_io: ok\n";
    return 0;
}
