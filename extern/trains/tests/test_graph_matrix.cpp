#include <iostream>
#include <string>

#include "trains/Matrix.h"
#include "trains/graph.h"

#include "test_util.h"

using trains::braid;
using trains::graph;
using trains::intarray;
using trains::matrix;

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

    matrix m(g);
    CHECK_EQ(m.size(), static_cast<trains::uint>(2));

    // Transition matrix output formats
    auto raw = g.TransitionMatrix(trains::raw, true);
    auto maple = g.TransitionMatrix(trains::maple, true);
    auto latex = g.TransitionMatrix(trains::latex, true);
    CHECK_TRUE(!raw.empty());
    CHECK_TRUE(!maple.empty());
    CHECK_TRUE(!latex.empty());
    CHECK_TRUE(maple.front().find("<") != std::string::npos);
    CHECK_TRUE(latex.front().find("\\left(") != std::string::npos);

    // Basic algorithm classification path
    CHECK_TRUE(g.HasIrreducibleMatrix());
    g.SetType(trains::pA_or_red);
    g.FindTrack();
    CHECK_TRUE(g.GetType() == trains::pA || g.GetType() == trains::Reducible2);

    std::cout << "test_graph_matrix: ok\n";
    return 0;
}
