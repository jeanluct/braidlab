#include <iostream>
#include <sstream>
#include <string>

#include "trains/General.h"
#include "trains/edgevert.h"
#include "trains/help.h"

#include "test_util.h"

using trains::Error;
using trains::edge;
using trains::edgelist;
using trains::intarray;
using trains::vertex;
using trains::vertexlist;

int main() {
    // General utilities
    char s[] = "AbC123";
    trains::LowerCase(s);
    CHECK_TRUE(std::string(s) == "abc123");

    Error e("example", 3);
    CHECK_EQ(e.GetType(), 3);

    // edge/vertex setup and list containers
    intarray im;
    im[1] = 1;
    im[2] = -1;
    edge ed;
    ed.Set(1, trains::Main, 1, 2, im, 0);
    CHECK_EQ(ed.GetLabel(), 1L);
    CHECK_EQ(ed.GetType(), trains::Main);
    CHECK_EQ(ed.GetImage().TopIndex(), 2L);

    intarray ve;
    ve[1] = 1;
    ve[2] = -1;
    vertex vx;
    vx.Set(1, ve, 1);
    CHECK_EQ(vx.GetLabel(), static_cast<trains::uint>(1));
    CHECK_EQ(vx.GetImage(), static_cast<trains::uint>(1));
    CHECK_EQ(vx.Valence(), static_cast<trains::uint>(2));

    edgelist el;
    el[1] = ed;
    CHECK_EQ(el.TopIndex(), 1L);
    CHECK_EQ(el[1].GetLabel(), 1L);

    vertexlist vl;
    vl[1] = vx;
    CHECK_EQ(vl.TopIndex(), 1L);
    CHECK_EQ(vl[1].GetLabel(), static_cast<trains::uint>(1));

    // Help text path with explicit topic (non-interactive)
    char topic[] = "train";
    trains::Help(topic);

    std::cout << "test_misc_components: ok\n";
    return 0;
}
