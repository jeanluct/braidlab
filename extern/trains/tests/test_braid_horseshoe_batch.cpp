#include <iostream>
#include <sstream>
#include <string>

#include "trains/Batch.h"
#include "trains/braid.h"
#include "trains/hshoe.h"

#include "test_util.h"

using trains::BatchProcess;
using trains::Error;
using trains::braid;
using trains::horseshoe;
using trains::intarray;

static horseshoe make_horseshoe_10010() {
    horseshoe h;
    h.n = 1;
    h.L[1].s.Flush();
    const char* code = "10010";
    for (unsigned i = 0; code[i] != '\0'; ++i) {
        h.L[1].s[i + 1] = (code[i] == '1') ? 1 : 0;
    }
    return h;
}

int main() {
    // braid::Set and automatic tightening
    braid b;
    intarray w;
    w[1] = 1;
    w[2] = -2;
    w[3] = 2;
    w[4] = -1;
    b.Set(3, w);
    CHECK_EQ(b.Size(), static_cast<trains::uint>(3));
    CHECK_EQ(b.Length(), static_cast<trains::uint>(0));

    // Invalid generator must throw
    bool threw = false;
    try {
        intarray bad;
        bad[1] = 3;
        b.Set(3, bad);
    } catch (const Error&) {
        threw = true;
    }
    CHECK_TRUE(threw);

    // Stream input path for braid
    std::istringstream bin("4\n1 -2 3 0\n");
    bin >> b;
    CHECK_EQ(b.Size(), static_cast<trains::uint>(4));
    CHECK_EQ(b.Length(), static_cast<trains::uint>(3));
    CHECK_EQ(b.Permute(1), static_cast<trains::uint>(4));

    // Horseshoe conversion path into braid
    horseshoe h = make_horseshoe_10010();
    CHECK_TRUE(h.FindPermutation() != 0);
    b.Set(h);
    CHECK_TRUE(b.Size() >= static_cast<trains::uint>(3));
    CHECK_TRUE(b.Length() > 0);

    // Batch parser/runner path on in-memory script
    std::ostringstream script;
    script << "out b/t.g/\n";
    script << "br 1 -2 0\n";
    script << "hs 10010\n";
    script << "ss\n";
    script << "ls\n";
    script << "raw\n";
    script << "maple\n";
    script << "latex\n";
    script << "ifpa\n";
    script << "ifreset\n";
    script << "boundaryperipheral\n";
    script << "boundarynonperipheral\n";
    script << "print batch-ok\n";
    std::istringstream batch_in(script.str());
    CHECK_TRUE(BatchProcess(batch_in, 6));

    std::cout << "test_braid_horseshoe_batch: ok\n";
    return 0;
}
