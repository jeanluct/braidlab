/*
    Copyright (C) 2000-2001 Jae Choon Cha.

    This file is part of CBraid.

    CBraid is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    any later version.

    CBraid is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with CBraid; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/


/*
    $Id: cbraid_implementation.h,v 1.9 2001/12/07 10:12:13 jccha Exp $
    Jae Choon Cha <jccha@knot.kaist.ac.kr>

    Implementation of cbraid library.
*/


template<class ForItr, class BinFunc>
inline ForItr apply_binfun(ForItr first, ForItr last, BinFunc f)
{
    ForItr i, j;
    if ((i = j = first) == last)
        return first;
    while (++j != last && f(*(i++), *j))
        ;
    return j;
}


template<class BiItr, class BinFunc>
inline BiItr reverse_apply_binfun(BiItr first, BiItr last, BinFunc f)
{
    BiItr i, j;
    if (first == (i = j = last))
        return first;
    --i;
    while ((j = i) != first && f(*--i, *j))
        ;
    return --j;
}


template <class ForItr, class BinFun>
inline void bubble_sort(ForItr first, ForItr last, BinFun f)
{
    ForItr i;
    if (first == (i = last))
        return;
    while (i != first)
        apply_binfun(--i, last, f);
}


/*
template <class ForItr, class BinFun>
inline void bubble_sort(ForItr first, ForItr last, BinFun f)
{
    ForItr i, j, b;
    if (first == last)
        return;
    do {
        b = last;
        for(i = last, j = --i, --i; j != first; --i, --j) {
            if (f(*i, *j))
                b = j;
        }
        first = b;
    } while (first != last);
}
*/


template <class Seq, class UnaPre>
inline typename Seq::difference_type erase_front_if(Seq& s, UnaPre f)
{
    typename Seq::difference_type c = 0;
    typename Seq::iterator i = s.begin();
    while (i != s.end() && f(*(i))) {
        ++c;
        ++i;
    }
    s.erase(s.begin(), i);
    return c;
}


template <class Seq, class UnaPre>
inline typename Seq::difference_type erase_back_if(Seq& s, UnaPre f)
{
    typename Seq::difference_type c = 0;
    typename Seq::reverse_iterator i = s.rbegin();
    while (i != s.rend() && f(*i)) {
        ++i;
        ++c;
    }
    s.erase(i.base(), s.end());
    return c;
}


inline ArtinPresentation::ArtinPresentation(sint16 n)
{

#ifdef DEBUG
    if (n <= 0) {
        std::cerr << "ArtinPresentation::ArtinPresentation: "
            "Bad argument (n <= 0).\n";
        exit(1);
    }
#endif

    PresentationIndex = n;
}


inline sint16 ArtinPresentation::Index() const
{
    return PresentationIndex;
}


inline sint16 ArtinPresentation::DeltaTable(sint16 i, sint32 k) const
{
    return (k & 1) ? Index()-i+1 : i;
}


inline void ArtinPresentation::Randomize(sint16* r) const
{
    // The present implementation generates a random permutation using
    // rand() function of C library. A better pseudo random number
    // generator could be used.

    for(sint16 i = 1; i <= Index(); ++i)
        r[i] = i;
    for(sint16 i = 1; i < Index(); ++i) {
        sint16 j = i+sint16(std::rand()/(RAND_MAX+1.0)*(Index()-i+1));
        sint16 z = r[i];
        r[i] = r[j];
        r[j] = z;
    }
}


inline void ArtinPresentation::LeftMeet(
    const sint16* a, const sint16* b, sint16* r) const
{
    static sint16 s[MaxBraidIndex];

    for(sint16 i = 1; i <= Index(); ++i)
        s[i] = i;
    MeetSub(a, b, s, 1, Index());
    for(sint16 i = 1; i <= Index(); ++i)
        r[s[i]] = i;
}


inline void ArtinPresentation::RightMeet(
    const sint16* a, const sint16* b, sint16* r) const
{
    static sint16 u[MaxBraidIndex], v[MaxBraidIndex];

    for(sint16 i = 1; i <= Index(); ++i) {
        u[a[i]] = i;
        v[b[i]] = i;
    }
    for(sint16 i = 1; i <= Index(); ++i)
        r[i] = i;
    MeetSub(u, v, r, 1, Index());
}


inline BandPresentation::BandPresentation(sint16 n)
{

#ifdef DEBUG
    if (n <= 0) {
        std::cerr << "BandPresentation::BandPresentation: "
            "Bad argument (n <= 0).\n";
        exit(1);
    }
#endif

    PresentationIndex = n;
}


inline sint16 BandPresentation::Index() const
{
    return PresentationIndex;
}


inline sint16 BandPresentation::DeltaTable(sint16 i, sint32 k) const
{
    // Because the bahavior of / and % operators for negative integers
    // is implementation dependent in C++, we use the following trick
    // to make k a non-negative integer with the same residue class
    // modulo index.
    if (k < 0)
        k = k-Index()*k;
    return (i+k-1)%Index()+1;
}


inline void BandPresentation::PTtoDCDT(const sint16* a, sint16* x) const
{
    for(sint16 i = 1; i <= Index(); ++i)
        x[i] = 0;
    for(sint16 i = Index(); i >= 1; --i) {
        if (x[i] == 0)
            x[i] = i;
        if (a[i] < i)
            x[a[i]] = x[i];
    }
}


inline void BandPresentation::DCDTtoPT(const sint16* x, sint16* a) const
{
    static sint16 z[MaxBraidIndex];

    for(sint16 i = 1; i <= Index(); ++i)
        z[i] = 0;
    for(sint16 i = 1; i <= Index(); ++i) {
        a[i] = (z[x[i]] == 0) ? x[i] : z[x[i]];
        z[x[i]] = i;
    }
}


inline void BandPresentation::BStoPT(const sint8* s, sint16* a) const
{
    static sint16 stack[MaxBraidIndex];
    sint16 sp = 0;

//    cout << flush << "BStoPT: ";
//    for(sint16 i = 1; i <= 2*Index(); ++i)
//        cout << ((s[i] == 1) ? "+" : "-");
//    cout << " -> ";

    for(sint16 i = 1; i <= 2*Index(); ++i) {
        if (s[i] == 1) {
            stack[sp++] = i;
        } else {
            sint16 j = stack[--sp];
            if ((i/2)*2 != i)
                a[(i+1)/2] = j/2;
            else
                a[(j+1)/2] = i/2;
        }
    }

//    for(sint16 i = 1; i <= Index(); ++i)
//        cout << a[i] << " ";
//    cout << endl << flush;
}


inline void BandPresentation::Randomize(sint16* r) const
{
#ifdef USE_CLN

    static sint8 s[MaxBraidIndex];
    static sint16 a[MaxBraidIndex];
    cln::cl_I k =
        cln::random_I(cln::default_random_state, GetCatalanNumber(Index()))+1;
    BallotSequence(Index(), k, s);
    BStoPT(s, a);
    for(sint16 i = 1; i <= Index(); ++i)
        r[a[i]] = i;

#else

    std::cerr << std::flush
         << "! BandPresentation::Randomize(): CLN is required.\n"
         << std::flush;
    exit(1);

#endif
}
 

#ifdef BAND_PRESENTATION_SORT_BY_COMPARISON
// A comparator class for std::sort().
class Compare {
    const sint16 *a, *b;
public:
    Compare(const sint16* x, const sint16* y) : a(x), b(y) {}
    bool operator()(const sint16 p, const sint16 q) {
        return (a[p] > a[q]) || (a[p] == a[q] && b[p] > b[q]) ||
            (a[p] == a[q] && b[p] == b[q] && p > q);
    }
};
#endif


inline void BandPresentation::LeftMeet(
    const sint16* a, const sint16* b, sint16* r) const
{
    static sint16 x[MaxBraidIndex], y[MaxBraidIndex], u[MaxBraidIndex];
    sint16 i, j, k;

    for(i = 1; i <= Index(); ++i)
        u[a[i]] = i;
    PTtoDCDT(u, x);
    for(i = 1; i <= Index(); ++i)
        u[b[i]] = i;
    PTtoDCDT(u, y);

    for(i = 1; i <= Index(); ++i)
        u[i] = Index()-i+1;

    // Here we need to sort u[i] such that (x[u[i]], y[u[i]], u[i]) is
    // decreasing w.r.t. the lexcographic order.  In order to maximize
    // speed, we use a radix sorting algorithm that uses an workspace
    // array of size n(n+1).  It would be reduced to 2n by using a
    // list-based radix sorting, which sacrificing speed.

#ifdef BAND_PRESENTATION_SORT_BY_COMPARISON
    std::sort(u+1, u+Index()+1, Compare(x, y));
#else
    for(sint16* z = x; z; z = (z == x) ? y : 0) {
        static sint16 N[MaxBraidIndex], P[MaxBraidIndex][MaxBraidIndex];
        for(k = 1; k <= Index(); ++k)
            N[k] = 0;
        for(i = 1; i <= Index(); ++i) {
            k = z[u[i]];
            P[k][N[k]++] = u[i];
        }
        i = 1;
        for(k = Index(); k >= 1; --k) {
            for(j = 0; j < N[k]; ++j) {
                u[i++] = P[k][j];
            }
        }
    }
#endif

    j = u[1];
    r[j] = j;
    for(i = 2; i <= Index(); ++i) {
        if (x[j] != x[u[i]] || y[j] != y[u[i]])
            j = u[i];
        r[u[i]] = j;
    }
    DCDTtoPT(r, u);
    for(i = 1; i <= Index(); ++i)
        r[u[i]] = i;
}


inline void BandPresentation::RightMeet(
    const sint16* a, const sint16* b, sint16* r) const
{
    LeftMeet(a, b, r);
}


template<class P>
inline Factor<P>::Factor(sint16 n, sint32 k)
    : Pres(n)
{
    pTable = new sint16[Index()];

#ifdef DEBUG
    if (pTable == 0) {
        std::cerr << "Factor<P>::Factor<P>(): Memory allocation error.\n";
        exit(1);
    }
#endif

    if ((uint32)k != Uninitialize) {
        Delta(k);
    }
}


template <class P>
inline Factor<P>::Factor(const Factor& f)
    : Pres(f.Index())
{
    pTable = new sint16[Index()];

#ifdef DEBUG
    if (pTable == 0) {
        std::cerr << "Factor<P>::Factor<P>(): Memory allocation error.\n";
        exit(1);
    }
#endif

    Assign(f);
}


template<class P>
inline Factor<P>::operator sint16*()
{
    return pTable-1;
}


template<class P>
inline Factor<P>::operator const sint16*() const
{
    return pTable-1;
}


template<class P>
inline Factor<P>::~Factor()
{
    delete[] pTable;
}


template<class P>
inline Factor<P>& Factor<P>::Delta(sint32 k)
{
    for(register sint16 i = 1; i <= Index(); ++i)
        At(i) = Pres.DeltaTable(i, k);
    return *this;
}


template<class P>
inline Factor<P>& Factor<P>::Identity()
{
    return Delta(0);
}


template<class P>
inline Factor<P>& Factor<P>::LowerDelta(sint32 k)
{
    if (Index() % 2)
        throw OddIndexError();
    sint16 n = Index()/2;

    Factor lf(n, k);
    for(sint32 i = 1; i <= n; ++i) {
        At(i) = lf[i];
        At(i+n) = i+n;
    }
    return *this;
}


template<class P>
inline Factor<P>& Factor<P>::UpperDelta(sint32 k)
{
    if (Index() % 2)
        throw OddIndexError();
    sint16 n = Index()/2;

    Factor lf(n, k);
    for(sint32 i = 1; i <= n; ++i) {
        At(i) = i;
        At(i+n) = lf[i]+n;
    }
    return *this;
}


template<class P>
inline sint16 Factor<P>::Index() const
{
    return Pres.Index();
}


template<class P>
inline sint16& Factor<P>::At(sint16 n)
{
    return pTable[n-1];
}


template<class P>
inline sint16 Factor<P>::At(sint16 n) const
{
    return pTable[n-1];
}


template<class P>
inline sint16& Factor<P>::operator[](sint16 n)
{
    return At(n);
}


template<class P>
inline sint16 Factor<P>::operator[](sint16 n) const {
    return At(n);
}


template<class P>
inline Factor<P>& Factor<P>::Assign(const Factor<P>& f)
{

#ifdef DEBUG
    if (Index() != f.Index()) {
        std::cerr << "Factor<P>::Assign(): Index mismatch.\n";
        exit(1);
    }
#endif

    if (&f != this) {
        for(register sint16 i = 1; i <= Index(); ++i) {
            At(i) = f[i];
        }
    }
    return *this;
}


template<class P>
inline Factor<P>& Factor<P>::operator=(const Factor& f)
{
    return Assign(f);
}


template<class P>
inline bool Factor<P>::Compare(const Factor<P>& f) const
{

#ifdef DEBUG
    if (Index() != f.Index()) {
        std::cerr << "Factor<P>::Compare(): Index mismatch.\n";
        exit(1);
    }
#endif

    for(register sint16 i = 1; i <= Index(); ++i) {
        if (At(i) != f[i])
            return false;
    }
    return true;
}


template<class P>
inline bool Factor<P>::operator==(const Factor& f) const
{
    return Compare(f);
}


template<class P>
inline bool Factor<P>::operator!=(const Factor& f) const
{
    return !Compare(f);
}


template<class P>
inline bool Factor<P>::CompareWithDelta(sint32 k) const
{
    for(register sint16 i = 1; i <= Index(); ++i) {
        if (At(i) != Pres.DeltaTable(i, k))
            return false;
    }
    return true;
}


template<class P>
inline bool Factor<P>::CompareWithIdentity() const
{
    return CompareWithDelta(0);
}


template<class P>
inline Factor<P> Factor<P>::Composition(
    const Factor<P>& a) const
{
#ifdef DEBUG
    if (Index() != a.Index()) {
        std::cerr << "Factor<P>::Composition(): Index mismatch.\n";
        exit(1);
    }
#endif
    Factor f(Index());
    for(register sint16 i = 1; i <= Index(); ++i)
        f[i] = a[At(i)];
    return f;
}


template<class P>
inline Factor<P>& Factor<P>::AssignComposition(
    const Factor& a)
{
#ifdef DEBUG
    if (Index() != a.Index()) {
        std::cerr << "Factor<P>::Composition(): Index mismatch.\n";
        exit(1);
    }
#endif
    for(register sint16 i = 1; i <= Index(); ++i)
        At(i) = a[At(i)];
    return *this;
}


template<class P>
inline Factor<P>& Factor<P>::operator*=(const Factor& a)
{
    return AssignComposition(a);
}


template<class P>
inline Factor<P> Factor<P>::operator*(const Factor& a) const
{
    return Composition(a);
}


template<class P>
inline Factor<P> Factor<P>::Inverse() const
{
    Factor f(Index());
    for(register sint16 i = 1; i <= Index(); ++i)
        f[At(i)] = i;
    return f;
}


template<class P>
inline Factor<P>& Factor<P>::AssignInverse()
{
    return *this = Inverse();
}


template<class P>
inline Factor<P> Factor<P>::operator!() const
{
    return Inverse();
}


template<class P>
inline Factor<P> Factor<P>::Flip(sint32 k) const
{
    Factor f(Index());
    for(register sint16 i = 1; i <= Index(); ++i)
        f[i] = Pres.DeltaTable(At(Pres.DeltaTable(i, -k)), k);
    return f;
}


template<class P>
inline Factor<P>& Factor<P>::AssignFlip(sint32 k)
{
    return *this = Flip(k);
}


template<class P>
inline Factor<P> Factor<P>::LeftMeet(const Factor<P>& a) const
{

#ifdef DEBUG
    if (Index() != a.Index()) {
        std::cerr << "Factor<P>::LeftMeet(): Index mismatch.\n";
        exit(1);
    }
#endif

    Factor<P> r(Index());
    Pres.LeftMeet(*this, a, r);
    return r;
}


template<class P>
inline Factor<P> Factor<P>::RightMeet(const Factor<P>& a) const
{

#ifdef DEBUG
    if (Index() != a.Index()) {
        std::cerr << "Factor<P>::RightMeet(): Index mismatch.\n";
        exit(1);
    }
#endif

    Factor<P> r(Index());
    Pres.RightMeet(*this, a, r);
    return r;
}


template<class P>
inline Factor<P>& Factor<P>::Randomize()
{
    Pres.Randomize(*this);
    return *this;
}


template<class P>
Factor<P> LeftMeet(const Factor<P>& a, const Factor<P>& b)
{
    return a.LeftMeet(b);
}


template<class P>
Factor<P> RightMeet(const Factor<P>& a, const Factor<P>& b)
{
    return a.RightMeet(b);
}


template<class P>
inline bool MakeLeftWeighted(Factor<P>&a, Factor<P>&b)
{

#ifdef DEBUG
    if (a.Index() != b.Index()) {
        std::cerr << "MakeLeftWeighted(Factor<P>, Factor<P>): Index mismatch.\n";
        exit(1);
    }
#endif

    Factor<P> x = LeftMeet((!a)*Factor<P>(a.Index(), 1), b);
    if (x.CompareWithIdentity())
        return false;
    else {
        a *= x;
        b = (!x)*b;
        return true;
    }
}


template<class P>
inline bool MakeRightWeighted(Factor<P>& a, Factor<P>& b)
{

#ifdef DEBUG
    if (a.Index() != b.Index()) {
        std::cerr << "MakeRightWeighted(Factor<P>, Factor<P>): Index mismatch.\n";
        exit(1);
    }
#endif

    Factor<P> x = RightMeet(a, Factor<P>(b.Index(), 1)*!b);
    if (x.CompareWithIdentity())
        return false;
    else {
        a *= !x;
        b = x*b;
        return true;
    }
}


template<class P>
inline std::ostream& operator<<(std::ostream& os, const Factor<P>& f)
{
    os << "[";
    for(sint16 i = 1; i < f.Index(); ++i)
        os << f[i] << " ";
    os << f[f.Index()] << "]";
    return os;
}


template<class P>
inline Braid<P>::Braid(sint16 n)
    : Pres(n)
{
    Identity();
}


template<class P>
inline Braid<P>::Braid(const Braid& b)
    : Pres(b.Pres),
    LeftDelta(b.LeftDelta),
    RightDelta(b.RightDelta),
    FactorList(b.FactorList)
{}


template<class P>
inline Braid<P>::Braid(const Factor<P>& f)
    : Pres(f.Index()),
    LeftDelta(0),
    RightDelta(0),
    FactorList(1, f)
{
}


template<class P>
inline Braid<P>::~Braid()
{
}


template<class P>
inline sint16 Braid<P>::Index() const
{
    return Pres.Index();
}


template<class P>
inline Braid<P>& Braid<P>::Identity()
{
    LeftDelta = RightDelta = 0;
    FactorList.clear();
    return *this;
}


template<class P>
inline Braid<P>& Braid<P>::Assign(const Braid& b)
{

#ifdef DEBUG
    if (Index() != b.Index()) {
        std::cerr << "Braid<P>::Assign(): Index mismatch.\n";
        exit(1);
    }
#endif

    Pres = b.Pres;
    LeftDelta = b.LeftDelta;
    RightDelta = b.RightDelta;
    FactorList = b.FactorList;
    return *this;
}


template<class P>
inline Braid<P>& Braid<P>::operator=(const Braid& b)
{
    return Assign(b);
}


template<class P>
inline bool Braid<P>::Compare(const Braid& b) const
{

#ifdef DEBUG
    if (Index() != b.Index()) {
        std::cerr << "Braid<P>::Compare(): Index mismatch.\n";
        exit(1);
    }
#endif

    return (LeftDelta == b.LeftDelta && RightDelta == b.RightDelta &&
            FactorList == b.FactorList);
}


template<class P>
inline bool Braid<P>::operator==(const Braid& b) const
{
    return Compare(b);
}


template<class P>
inline bool Braid<P>::operator!=(const Braid& b) const
{
    return !Compare(b);
}


template<class P>
inline bool Braid<P>::CompareWithIdentity() const
{
    return (LeftDelta == 0 && RightDelta == 0 && FactorList.empty());
}


template<class P>
inline Braid<P> Braid<P>::Inverse() const
{
    Braid b(Index());
    b.LeftDelta = -RightDelta;
    b.RightDelta = 0;
    Factor<P> f(Index());
    for(ConstRevFactorItr it = FactorList.rbegin();
        it != FactorList.rend();
        ++it) {
        // Compute f such that (*it)*f = Delta.
        for(sint16 i = 1; i <= Index(); ++i)
            f[(*it)[i]] = Pres.DeltaTable(i, 1);
        // Rewrite a_1...a_k Delta^r (*it)^(-1) as
        // a_1...a_k (Delta^r f Delta^(-r)) Delta^(r-1)
        b.FactorList.push_back(f.Flip(-b.RightDelta));
        --b.RightDelta;
    }
    b.RightDelta -= LeftDelta;
    return b;
}


template<class P>
inline Braid<P> Braid<P>::operator!() const
{
    return Inverse();
}


template<class P>
inline Braid<P>& Braid<P>::LeftMultiply(const Factor<P>& f)
{

#ifdef DEBUG
    if (Index() != f.Index()) {
        std::cerr << "Braid<P>::LeftMultiply(): Index mismatch.\n";
        exit(1);
    }
#endif

    FactorList.push_front(f.Flip(LeftDelta));
    return *this;
}


template<class P>
inline Braid<P>& Braid<P>::RightMultiply(const Factor<P>& f)
{

#ifdef DEBUG
    if (Index() != f.Index()) {
        std::cerr << "Braid<P>::RightMultiply(): Index mismatch.\n";
        exit(1);
    }
#endif

    FactorList.push_back(f.Flip(-RightDelta));
    return *this;
}


template<class P>
inline Braid<P>& Braid<P>::LeftMultiply(const Braid& a)
{

#ifdef DEBUG
    if (Index() != a.Index()) {
        std::cerr << "Braid<P>::LeftMultiply(): Index mismatch.\n";
        exit(1);
    }
#endif

    LeftDelta += a.RightDelta;
    for(ConstRevFactorItr it = a.FactorList.rbegin();
        it != a.FactorList.rend();
        ++it) {
        LeftMultiply(*it);
    }
    LeftDelta += a.LeftDelta;
    return *this;
}


template<class P>
inline Braid<P>& Braid<P>::RightMultiply(const Braid& a)
{

#ifdef DEBUG
    if (Index() != a.Index()) {
        std::cerr << "Braid<P>::RightMultiply(): Index mismatch.\n";
        exit(1);
    }
#endif

    RightDelta += a.LeftDelta;
    for(ConstFactorItr it = a.FactorList.begin();
        it != a.FactorList.end();
        ++it) {
        RightMultiply(*it);
    }
    RightDelta += a.RightDelta;
    return *this;
}


template<class P>
inline Braid<P>& Braid<P>::Multiply(const Braid& a, const Braid& b)
{
    *this = a; return RightMultiply(b);
}


template<class P>
inline Braid<P> Braid<P>::operator*(const Braid& a) const
{
    Braid b(*this);
    return b.RightMultiply(a);
}


template<class P>
inline Braid<P>& Braid<P>::operator*=(const Braid& a)
{
    return RightMultiply(a);
}


template<class P>
typename Braid<P>::CanonicalFactor Braid<P>::GetPerm() const
{
    Factor<P> p(Index(), LeftDelta);
    FactorItr it = FactorList.begin();
    while (it != FactorList.end())
        p *= *(it++);
    return p *= Factor<P>(Index(), RightDelta);
}


template<class P>
Braid<P>& Braid<P>::MakeLCF()
{
    if (RightDelta != 0) {
        transform(FactorList.begin(), FactorList.end(), FactorList.begin(),
                 std::bind2nd(std::mem_fun_ref(&Factor<P>::Flip), RightDelta));
        LeftDelta += RightDelta;
        RightDelta = 0;
    }
    bubble_sort(FactorList.begin(), FactorList.end(),
                std::ptr_fun(MakeLeftWeighted<P>));
    LeftDelta += erase_front_if(
        FactorList, std::bind2nd(std::mem_fun_ref(&Factor<P>::CompareWithDelta), 1));
    erase_back_if(FactorList, std::mem_fun_ref(&Factor<P>::CompareWithIdentity));
    return *this;
}


template<class P>
Braid<P>& Braid<P>::MakeRCF()
{
    if (LeftDelta != 0) {
        transform(FactorList.begin(), FactorList.end(), FactorList.begin(),
                 std::bind2nd(std::mem_fun_ref(&Factor<P>::Flip), -LeftDelta));
        RightDelta += LeftDelta;
        LeftDelta = 0;
    }
    bubble_sort(FactorList.begin(), FactorList.end(),
                std::ptr_fun(&MakeRightWeighted<P>));
    RightDelta += erase_back_if(
        FactorList, std::bind2nd(std::mem_fun_ref(&Factor<P>::CompareWithDelta), 1));
    erase_front_if(FactorList, std::mem_fun_ref(&Factor<P>::CompareWithIdentity));
    return *this;
}


template<class P>
Braid<P> Braid<P>::ReduceLeftLower()
{
    return ReduceLeftSub(Factor<P>(Index()).LowerDelta());
}


template<class P>
Braid<P> Braid<P>::ReduceLeftUpper()
{
    return ReduceLeftSub(Factor<P>(Index()).UpperDelta());
}


template<class P>
Braid<P> Braid<P>::ReduceRightLower()
{
    return ReduceRightSub(Factor<P>(Index()).LowerDelta());
}


template<class P>
Braid<P> Braid<P>::ReduceRightUpper()
{
    return ReduceRightSub(Factor<P>(Index()).UpperDelta());
}


template<class P>
Braid<P> Braid<P>::ReduceLeftSub(const Factor<P>& SmallDelta)
{
    MakeLCF();
    if (LeftDelta < 0)
        throw NegativeBraidError();

    Braid b(Index());
    while (1) {
        Factor<P> f(Index());
        if (LeftDelta > 0) {
            --LeftDelta;
            f.Delta(1);
        } else if (FactorList.empty()) {
            break;
        } else {
            f = FactorList.front();
            FactorList.pop_front();
        }
        Factor<P> p = LeftMeet(f, SmallDelta);
        LeftMultiply((!p)*f);
        if (p.CompareWithIdentity())
            break;
        b.RightMultiply(p);
        apply_binfun(FactorList.begin(), FactorList.end(),
                     std::ptr_fun(MakeLeftWeighted<P>));
        erase_back_if(FactorList, std::mem_fun_ref(&Factor<P>::CompareWithIdentity));
    }
    return b;
}


template<class P>
Braid<P> Braid<P>::ReduceRightSub(const Factor<P>& SmallDelta)
{
    MakeRCF();
    if (RightDelta < 0)
        throw NegativeBraidError();

    Braid b(Index());
    while (1) {
        Factor<P> f(Index());
        if (RightDelta > 0) {
            --RightDelta;
            f.Delta(1);
        } else if (FactorList.empty()) {
            break;
        } else {
            f = FactorList.back();
            FactorList.pop_back();
        }
        Factor<P> p = RightMeet(f, SmallDelta);
        RightMultiply(f*!p);
        if (p.CompareWithIdentity())
            break;
        b.LeftMultiply(p);
        reverse_apply_binfun(FactorList.begin(), FactorList.end(),
                     std::ptr_fun(MakeRightWeighted<P>));
        erase_front_if(FactorList, std::mem_fun_ref(&Factor<P>::CompareWithIdentity));
    }
    return b;
}


template<class P>
Braid<P>& Braid<P>::Randomize(sint32 cl)
{

#ifdef DEBUG
    if (cl < 0) {
        std::cerr << "Braid<P>::Randomize(): Bad argument.\n";
        exit(1);
    }
#endif

    Identity();
    while (cl-- > 0) {
        FactorList.push_back(Factor<P>(Index()).Randomize());
    }
    return *this;
}   


template<class P>
std::ostream& operator<<(std::ostream& os, const Braid<P>& b)
{
    os << "(" << b.LeftDelta << "|";
    typename Braid<P>::ConstFactorItr i;
    for(i = b.FactorList.begin(); i != b.FactorList.end(); ++i) {
        for(sint16 k = 1; k < b.Index(); ++k)
            os << i->At(k) << " ";
        os << i->At(b.Index()) << "|";
    }
    os << b.RightDelta << ")";
    return os;
}
