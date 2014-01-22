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
    Jae Choon CHA <jccha@knot.kaist.ac.kr>

    Implementation of cbraid.h.
*/


#include "cbraid.h"

#include <ctime>

namespace CBraid {

// A class used to feed a seed to the random number generator of C
// library.

class _RandomSeedInitializer {
public:
    _RandomSeedInitializer() {
        std::srand(std::time(NULL));
    }
};

static _RandomSeedInitializer RandomSeedInitializer;


void ArtinPresentation::MeetSub(const sint16* a, const sint16* b, sint16* r,
                                sint16 s, sint16 t)
{
    static sint16 u[MaxBraidIndex], v[MaxBraidIndex], w[MaxBraidIndex];

    if (s >= t)
        return;
    sint16 m = (s+t)/2;
    MeetSub(a, b, r, s, m);
    MeetSub(a, b, r, m+1, t);

    u[m] = a[r[m]];
    v[m] = b[r[m]];
    if (s < m) {
        for(sint16 i = m-1; i >= s; --i) {
            u[i] = std::min(a[r[i]], u[i+1]);
            v[i] = std::min(b[r[i]], v[i+1]);
        }
    }
    u[m+1] = a[r[m+1]];
    v[m+1] = b[r[m+1]];
    if (t > m+1) {
        for(sint16 i = m+2; i <= t; ++i) {
            u[i] = std::max(a[r[i]], u[i-1]);
            v[i] = std::max(b[r[i]], v[i-1]);
        }
    }

    sint16 p = s;
    sint16 q = m+1;
    for(sint16 i = s; i <= t; ++i)
        w[i] = ((p > m) || (q <= t && u[p] > u[q] && v[p] > v[q])) ?
            r[q++] : r[p++];
    for(sint16 i = s; i <= t; ++i)
        r[i] = w[i];
}


BandBraid ToBandBraid(const ArtinBraid& a)
{
    sint32 n = a.Index();
    BandBraid b(n);
    sint32 l = a.LeftDelta, r = a.RightDelta;
    ArtinBraid::ConstFactorItr i = a.FactorList.begin();

    // First reduce to the case of positive braids, using D^2 = d^n.
    sint32 k;
    k = (l >= 0) ? l/2 : -((-l)/2)-1;
    l -= 2*k;
    b.LeftDelta = n*k;
    k = (r >= 0) ? r/2 : -((-r)/2)-1;
    r -= 2*k;
    b.RightDelta = n*k;

    ArtinBraid::CanonicalFactor f(n);
    BandBraid::CanonicalFactor g(n);
    while (true) {
        if (l > 0) {
            f.Delta(1);
            --l;
        } else if (i != a.FactorList.end()) {
            f = *(i++);
        } else if (r > 0) {
            f.Delta(1);
            --r;
        } else
            break;
        while (true) {
            for(k = 1; k < n && f[k] < f[k+1]; ++k)
                ;
            if (k >= n)
                break;
            std::swap(f[k], f[k+1]);
            g.Identity();
            g[k] = k+1;
            g[k+1] = k;
            b.FactorList.push_back(g);
        }
    }
    return b;
}


ArtinBraid ToArtinBraid(const BandBraid& b)
{
    sint32 n = b.Index();
    ArtinBraid a(n);
    sint32 l = b.LeftDelta, r = b.RightDelta;
    BandBraid::ConstFactorItr i = b.FactorList.begin();

    // First reduce to the case of positive braids, using D^2 = d^n.
    sint32 k;
    k = (l > 0) ? l/n : -((-l)/n)-1;
    l -= n*k;
    a.LeftDelta = 2*k;
    k = (r > 0) ? r/n : -((-r)/n)-1;
    r -= n*k;
    a.RightDelta = 2*k;

    BandBraid::CanonicalFactor f(n);
    ArtinBraid::CanonicalFactor g(n);
    while (true) {
        if (l > 0) {
            f.Delta(1);
            --l;
        } else if (i != b.FactorList.end()) {
            f = *(i++);
        } else if (r > 0) {
            f.Delta(1);
            --r;
        } else
            break;
        for(k = 1; k <= n; ++k)
            g[k] = f[k];
        a.FactorList.push_back(g);
    }
    return a;
}


#ifdef USE_CLN

void BallotSequence(sint16 n, cln::cl_I k, sint8* s)
{
    sint16 i;
    cln::cl_I r;

//    cout << flush << "BallotSequence: n=" << n << ", k=" << k;

    if (k <= (r = GetCatalanNumber(n-1)*GetCatalanNumber(0)))
        i = 1;
    else if (k > (r = GetCatalanNumber(n)-r)) {
        i = n;
        k = k-r;
    } else {
        for(i = 1; i <= n; ++i) {
            if (k <= (r = GetCatalanNumber(i-1)*GetCatalanNumber(n-i)))
                break;
            else
                k = k-r;
        }
    }

//    cout << ": i=" << i << endl << flush;

    cln::cl_I_div_t d = cln::floor2(k-1, GetCatalanNumber(n-i));

    s[1] = 1;
    s[2*i] = -1;
    if (i > 1)
        BallotSequence(i-1, d.quotient, s+1);
    if (i < n)
        BallotSequence(n-i, d.remainder, s+2*i);
}


class _CatalanNumber {
    friend const cln::cl_I& GetCatalanNumber(sint16);
public:
    _CatalanNumber();
private:
    cln::cl_I Table[MaxBraidIndex+1];
    cln::cl_I& C(sint16 n) { return Table[n]; }
};

static _CatalanNumber CatalanNumber;

_CatalanNumber::_CatalanNumber()
{
    C(0) = 1;
    for(sint16 n = 1; n < MaxBraidIndex; ++n) {
        C(n) = 0;
        for(sint16 k = 0; k < n; ++k) {
            C(n) = C(n)+C(k)*C(n-k-1);
        }
    }
}


const cln::cl_I& GetCatalanNumber(sint16 n)
{
    return CatalanNumber.C(n);
}

#endif // USE_CLN

} // namespace CBraid
