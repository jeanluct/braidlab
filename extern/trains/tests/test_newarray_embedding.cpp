#include <iostream>
#include <list>

#include "trains/embedding.h"
#include "trains/newarray.h"

#include "test_util.h"

using trains::EmbeddingInformation;
using trains::intarray;

int main() {
    // Generic tighten helper on std::list
    std::list<int> path = {1, -1, 2, -2, 3};
    CHECK_TRUE(trains::tighten(path));
    CHECK_EQ(static_cast<int>(path.size()), 1);
    CHECK_EQ(path.front(), 3);

    // intarray core operations
    intarray a;
    a[1] = 1;
    a[2] = 2;
    a[3] = -2;
    a[4] = -1;
    CHECK_TRUE(a.Tighten());
    CHECK_EQ(a.TopIndex(), 0L);

    intarray b;
    b[1] = 1;
    b[2] = 2;
    b[3] = 3;
    b.Invert();
    CHECK_EQ(b[1], -3);
    CHECK_EQ(b[2], -2);
    CHECK_EQ(b[3], -1);

    intarray repl;
    repl[1] = 7;
    repl[2] = 8;
    intarray c;
    c[1] = 5;
    c[2] = -5;
    c[3] = 9;
    c.Replace(5, repl);
    CHECK_EQ(c[1], 7);
    CHECK_EQ(c[2], 8);
    CHECK_EQ(c[3], -8);
    CHECK_EQ(c[4], -7);
    CHECK_EQ(c[5], 9);

    intarray cyc;
    cyc[1] = 1;
    cyc[2] = 2;
    cyc[3] = -1;
    cyc.CyclicTighten();
    CHECK_EQ(cyc.TopIndex(), 1L);
    CHECK_EQ(cyc[1], 2);

    // EmbeddingInformation path composition
    EmbeddingInformation e1;
    e1.Start = 1;
    e1.End = 2;
    e1.append(10);
    e1.append(20);

    EmbeddingInformation e2;
    e2.Start = 2;
    e2.End = 3;
    e2.append(30);
    e2.append(40);

    e1.append(e2);
    CHECK_EQ(e1.End, 3);

    EmbeddingInformation e3;
    e3.Start = 0;
    e3.End = 1;
    e3.append(5);
    e1.prepend(e3);
    CHECK_EQ(e1.Start, 0);

    e1.tighten();
    std::ostringstream oss;
    oss << e1;
    CHECK_TRUE(oss.str().find("Path (") != std::string::npos);

    std::cout << "test_newarray_embedding: ok\n";
    return 0;
}
