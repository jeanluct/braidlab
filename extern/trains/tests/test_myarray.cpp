// Edge-case tests for MyArray<T> (trains/newarray.h): assignment, indexing
// and auto-growth, rotation, splitting, and the cyclic iterator.

#include <initializer_list>
#include <iostream>
#include <vector>

#include "trains/newarray.h"

#include "test_util.h"

using trains::intarray;
using trains::intiterator;

namespace {

intarray make(std::initializer_list<long> values) {
    intarray a;
    for (long v : values) a.SureAdd(v);
    return a;
}

// Read elements 1..TopIndex(); in-range reads do not grow the array.
std::vector<long> contents(intarray& a) {
    std::vector<long> out;
    for (long i = 1; i <= a.TopIndex(); ++i)
        out.push_back(a[static_cast<trains::uint>(i)]);
    return out;
}

bool same(intarray& a, std::initializer_list<long> expected) {
    return contents(a) == std::vector<long>(expected);
}

void test_assignment() {
    // empty = empty
    intarray e1, e2;
    e1 = e2;
    CHECK_EQ(e1.TopIndex(), 0L);

    // non-empty = empty
    intarray a = make({1, 2, 3});
    a = e2;
    CHECK_EQ(a.TopIndex(), 0L);

    // empty = non-empty
    intarray b;
    intarray src = make({4, -5, 6});
    b = src;
    CHECK_TRUE(same(b, {4, -5, 6}));

    // self-assignment (through a reference to dodge -Wself-assign)
    intarray& alias = b;
    b = alias;
    CHECK_TRUE(same(b, {4, -5, 6}));

    // assignment is a deep copy: mutating either side is independent
    b[1] = 40;
    CHECK_TRUE(same(src, {4, -5, 6}));
    src.SureAdd(7);
    CHECK_EQ(b.TopIndex(), 3L);

    // repeated assignment under mutation, as in MakeIrreducible's
    // CurrentPreP = NextPreP loop
    intarray current, next;
    for (long round = 1; round <= 5; ++round) {
        next.Flush();
        for (long k = 1; k <= round; ++k) next.SureAdd(k * round);
        current = next;
        CHECK_EQ(current.TopIndex(), round);
        CHECK_EQ(current[static_cast<trains::uint>(round)], round * round);
    }
    next.Flush();
    current = next;
    CHECK_EQ(current.TopIndex(), 0L);

    // copy construction
    intarray copy(src);
    CHECK_TRUE(same(copy, {4, -5, 6, 7}));
}

void test_indexing_and_growth() {
    intarray a;
    CHECK_EQ(a.TopIndex(), 0L);  // origin 1, so empty means TopIndex 0

    // Writing past the end grows the array, zero-filling any gap.
    a[3] = 9;
    CHECK_EQ(a.TopIndex(), 3L);
    CHECK_TRUE(same(a, {0, 0, 9}));

    // Reading past the end also grows it (legacy behavior callers rely on).
    long v = a[5];
    CHECK_EQ(v, 0L);
    CHECK_EQ(a.TopIndex(), 5L);

    // Find returns a 1-based index, or -1.
    intarray b = make({7, 8, 9});
    CHECK_EQ(b.Find(7), 1L);
    CHECK_EQ(b.Find(9), 3L);
    CHECK_EQ(b.Find(10), -1L);

    // Add rejects duplicates; SureAdd does not.
    CHECK_TRUE(!b.Add(8));
    CHECK_TRUE(b.Add(10));
    b.SureAdd(10);
    CHECK_TRUE(same(b, {7, 8, 9, 10, 10}));
}

void test_rotate() {
    // Rotate(k): NewArray[i] = Array[i+k], cyclically.
    intarray a = make({1, 2, 3, 4});
    a.Rotate(1);
    CHECK_TRUE(same(a, {2, 3, 4, 1}));
    a.Rotate(3);
    CHECK_TRUE(same(a, {1, 2, 3, 4}));

    // Angle equal to, or a multiple of, the size is the identity.
    a.Rotate(4);
    CHECK_TRUE(same(a, {1, 2, 3, 4}));
    a.Rotate(8);
    CHECK_TRUE(same(a, {1, 2, 3, 4}));

    // Angles larger than the size wrap.
    a.Rotate(6);
    CHECK_TRUE(same(a, {3, 4, 1, 2}));

    // Negative angles rotate the other way (used to be undefined behavior).
    a.Rotate(-2);
    CHECK_TRUE(same(a, {1, 2, 3, 4}));
    a.Rotate(-5);
    CHECK_TRUE(same(a, {4, 1, 2, 3}));

    // Empty array: a no-op (used to loop forever).
    intarray e;
    e.Rotate(1);
    e.Rotate(0);
    CHECK_EQ(e.TopIndex(), 0L);

    // Single element.
    intarray s = make({5});
    s.Rotate(3);
    CHECK_TRUE(same(s, {5}));

    // The idiom in graph::Collapse: rotate by Find(x) so x moves to the end,
    // then Remove(TopIndex()) drops it and keeps the cyclic order.
    intarray star = make({10, -20, 30, -40});
    long idx = star.Find(30);
    star.Rotate(idx);
    CHECK_TRUE(same(star, {-40, 10, -20, 30}));
    star.Remove(static_cast<trains::uint>(star.TopIndex()));
    CHECK_TRUE(same(star, {-40, 10, -20}));
}

void test_structural_edits() {
    intarray a = make({1, 2, 3, 4, 5});
    a.Remove(2);  // removes position 2
    CHECK_TRUE(same(a, {1, 3, 4, 5}));
    a.Remove(2, 1);  // removes positions 2..3
    CHECK_TRUE(same(a, {1, 5}));

    a.Insert(2, 9);  // a[2] = 9, rest shifted up
    CHECK_TRUE(same(a, {1, 9, 5}));
    a.Insert(1, 0);
    CHECK_TRUE(same(a, {0, 1, 9, 5}));

    intarray tail;
    a.Split(2, tail);  // split after position 2
    CHECK_TRUE(same(a, {0, 1}));
    CHECK_TRUE(same(tail, {9, 5}));

    intarray head = make({-1});
    a.Append(tail);
    a.Prepend(head);
    CHECK_TRUE(same(a, {-1, 0, 1, 9, 5}));

    // Split at the end leaves an empty tail.
    intarray t2;
    a.Split(static_cast<trains::uint>(a.TopIndex()), t2);
    CHECK_EQ(t2.TopIndex(), 0L);
    CHECK_EQ(a.TopIndex(), 5L);

    // RemoveAll removes both Value and -Value.
    intarray r = make({3, -3, 4, 3, -4});
    r.RemoveAll(3);
    CHECK_TRUE(same(r, {4, -4}));

    // Replace with an empty array acts like RemoveAll.
    intarray empty;
    intarray q = make({2, 5, -2});
    q.Replace(2, empty);
    CHECK_TRUE(same(q, {5}));

    // Invert on an odd length negates the middle element.
    intarray odd = make({1, 2, 3});
    odd.Invert();
    CHECK_TRUE(same(odd, {-3, -2, -1}));
    intarray none;
    none.Invert();
    CHECK_EQ(none.TopIndex(), 0L);
}

void test_tighten_edge_cases() {
    intarray e;
    CHECK_TRUE(!e.Tighten());
    e.CyclicTighten();
    CHECK_EQ(e.TopIndex(), 0L);

    // Nested cancellation.
    intarray n = make({1, 2, 3, -3, -2, 4});
    CHECK_TRUE(n.Tighten());
    CHECK_TRUE(same(n, {1, 4}));

    // Nothing to cancel.
    intarray c = make({1, 2, 1});
    CHECK_TRUE(!c.Tighten());
    CHECK_TRUE(same(c, {1, 2, 1}));

    // Cyclic cancellation that leaves a single element or nothing.
    intarray c1 = make({1, 2, -1});
    c1.CyclicTighten();
    CHECK_TRUE(same(c1, {2}));
    intarray c2 = make({1, 2, -2, -1});
    c2.CyclicTighten();
    CHECK_EQ(c2.TopIndex(), 0L);
    intarray c3 = make({1, 2, 3, -1});
    c3.CyclicTighten();
    CHECK_TRUE(same(c3, {2, 3}));
}

void test_agrees() {
    intarray a = make({1, 2, 3});
    intarray b = make({1, 2, 4, 5});
    CHECK_TRUE(a.Agrees(2, b));
    CHECK_TRUE(!a.Agrees(3, b));
    CHECK_TRUE(!a.Agrees(4, b));  // longer than a
    CHECK_EQ(a.AgreesTo(b), 2u);

    intarray prefix = make({1, 2});
    CHECK_EQ(prefix.AgreesTo(a), 2u);
    CHECK_EQ(a.AgreesTo(prefix), 2u);
    intarray e;
    CHECK_EQ(e.AgreesTo(a), 0u);
    CHECK_EQ(a.AgreesTo(e), 0u);
}

void test_iterator() {
    intarray a = make({10, 20, 30});
    intiterator I(a);
    CHECK_TRUE(I.AtOrigin());
    CHECK_EQ(I.Now(), 10L);

    // Pre-increment wraps cyclically.
    CHECK_EQ(++I, 20L);
    CHECK_EQ(++I, 30L);
    CHECK_EQ(++I, 10L);
    CHECK_TRUE(I.AtOrigin());

    // Post-increment returns the old element and wraps too.
    CHECK_EQ(I++, 10L);
    CHECK_EQ(I++, 20L);
    CHECK_EQ(I++, 30L);
    CHECK_TRUE(I.AtOrigin());

    ++I;
    I.Reset();
    CHECK_EQ(I.Now(), 10L);

    // Single element: every increment stays put.
    intarray one = make({7});
    intiterator J(one);
    CHECK_EQ(++J, 7L);
    CHECK_EQ(J++, 7L);
    CHECK_TRUE(J.AtOrigin());
}

}  // namespace

int main() {
    test_assignment();
    test_indexing_and_growth();
    test_rotate();
    test_structural_edits();
    test_tighten_edge_cases();
    test_agrees();
    test_iterator();
    std::cout << "test_myarray: ok\n";
    return 0;
}
