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
    $Id: cbraid_interface.h,v 1.11 2001/12/07 10:12:13 jccha Exp $
    Jae Choon CHA <jccha@knot.kaist.ac.kr>

    This is interface declarations of cbraid library.
*/


// For portablity, we use our own primitive types. The following
// definitions may need to be modified for your compiler.

typedef char sint8;
typedef unsigned char uint8;
/* JLT: Don't use short ints... */
// typedef short sint16;
// typedef unsigned short uint16;
typedef int sint16;
typedef unsigned int uint16;
typedef int sint32;
typedef unsigned int uint32;
typedef long long sint64;
typedef unsigned long long uint64;


// Implementation limits.

// Maximum braid index.
const sint16 MaxBraidIndex = 300;


// Algorithms useful in managing standard containers of Factor objects.

// Apply a binary function f on pairs (first,first+1),
// (first+1,first+2), ... , sequentially, where f is allowed to change
// the arguments.  The algorithm stops if either the binary function f
// returns false or (last-2,last-1) has been processed.  An iterator
// pointing the first untouched element is returned.  For example, if
// the entire [first, last[ has been processed, then last is returned.
// One may easily recognize that this can be used is for the inner
// loop of the bubble sort algorithm.  In Cbraid, this is used to make
// a given sequence of canonical factors weighted, under the
// assumption that all adjancent pairs but the first one are weighted.
// Obviously the execution time is linear in the length of the
// sequence.
template<class ForItr, class BinFunc>
ForItr apply_binfun(ForItr first, ForItr last, BinFunc f);

// The reverse version of apply_binfun.  By reverse_apply_binfun, f is
// applied on (last-2,last-1), (last-3,last-2), ... , sequentially.
// It returns the first(leftmost) element that has been processed.
template<class BiItr, class BinFunc>
BiItr reverse_apply_binfun(BiItr first, BiItr last, BinFunc f);

// A bubble sort algorithm.  It executes apply_binfun for
// [last-2,last[, [last-3,last[, ... , [first, last[ sequentialy.  To
// sort a sequence with respect to an order "<", f(x, y) should be a
// function that swaps x and y and returns true if x > y, and unless
// does nothing but returns false.  This is an O(l^2) algorithm, where
// l is the length of the range.
template <class ForItr, class BinFun>
void bubble_sort(ForItr first, ForItr last, BinFun f);

// Erase consecutive elements at the beginning of a sequence
// satisfying a given predicate, and return the number of erased
// elements.  In order to remove elements from the sequence really,
// the container must have erase() member function.
template <class Seq, class UnaPre>
typename Seq::difference_type erase_front_if(Seq& s, UnaPre f);

// Reverse version of erase_front_if.  It erases consecutive elements
// at the end of the sequence which satisfies a given predicate.
template <class Seq, class UnaPre>
typename Seq::difference_type erase_back_if(Seq& s, UnaPre f);


// Exception class.
struct OddIndexError {};
struct NegativeBraidError {};


// Class describing the Artin presentation and the band generator
// presentation.  Basically they consist of the description of delta
// and the meet operation.

class ArtinPresentation {

protected:
    sint16 PresentationIndex;

public:
    ArtinPresentation(sint16 n);
    sint16 Index() const;

    // Return the i-th entry of the permutation table of delta^k.
    sint16 DeltaTable(sint16 i, sint32 k = 1) const;

    // Compute the meet r of the two factors a and b.  A factor is
    // given as the associated permutation, which is viewed as a
    // bijection on the set {1,...n} and represented as an array whose
    // i-th entry is the image of i under the inverse of the
    // permutation (this convention is different from that in the
    // AsiaCrypt 2001 paper of the author).  The range of indices is
    // [1,n], not [0,n[.  We use a C style array of size (n+1) to
    // represent an n-permutation (the first entry is not used).

    // We define the left meet of two factors a and b to be the
    // longest factor r such that a=ra' and b=rb' for some factors a'
    // and b'.  This coincides with the convention of the paper of
    // Birman, Ko, and Lee, but different from that of the article of
    // Thurston (in Epstein's book).  Indeed, Thurston's is the
    // "right" meet in our sense.
    void LeftMeet(const sint16* a, const sint16* b, sint16* r) const;
    void RightMeet(const sint16* a, const sint16* b, sint16* r) const;

    // Generate a random factor.
    void Randomize(sint16* r) const;

private:
    // Subroutine called by LeftMeet() and RightMeet()
    static void MeetSub(const sint16* a, const sint16* b, sint16* r,
                        sint16 s, sint16 t);
};

class BandPresentation {
protected:
    sint16 PresentationIndex;

public:
    BandPresentation(sint16 n);
    sint16 Index() const;

    // Return the i-th entry of the permutation table of delta^k.
    sint16 DeltaTable(sint16 i, sint32 k = 1) const;

    // Conversions between permutation table and disjoint cycle
    // decomposition table.  They are those described in the AsiaCrypt
    // 2001 paper of the author, which uses different convention of
    // permutation table.  (In other parts of this program, a[i] is
    // the inverse image of i, but in the paper and in these
    // conversion functions, a[i] is the image of i.)
    void PTtoDCDT(const sint16* a, sint16* x) const;
    void DCDTtoPT(const sint16* x, sint16* a) const;

    // Conversion of a ballot sequence into a permutation table.  The
    // convention of the AsiaCrypt 2001 paper is also used here (see
    // the above remark).
    void BStoPT(const sint8* s, sint16* a) const;

    // Generate a random factor.  It works properly only if USE_CLN
    // macro is defined at compile time.
    void Randomize(sint16* r) const;

    // Compute the meet r of two factors a and b.
    void LeftMeet(const sint16* a, const sint16* b, sint16* r) const;
    void RightMeet(const sint16* a, const sint16* b, sint16* r) const;
};


// Class for a canonical factor, which is represented as a
// permutation.

template<class P> class Factor {

private:
    // The presentation description.
    P Pres;

    // Permutation table.
    sint16* pTable;

public:

    // Constructor.  The permutation table is initialized as
    // delta^k. If k == Uninitialize, the table is left uninitialized.
    enum { Uninitialize = 0x80000000 };
    Factor(sint16 n, sint32 k = Uninitialize);

    // Copy constructor.
    Factor(const Factor& f);

    // Conversion operator to the sint16* type.  The address of the
    // permutation table is returned.  Recall that the index range is
    // [1..n], not [0,n[; when the return value is r, r[1], ... , r[n]
    // contains the permutation table.  r[0] may be an invalid memory
    // and must not be accessed.
    operator sint16*();
    operator const sint16*() const;

    // Destructor.
    ~Factor();

    // Initialize as a power of delta.
    Factor& Delta(sint32 k = 1);
    Factor& Identity();

    // Initialize as a power of lower/upper delta.
    Factor& LowerDelta(sint32 k = 1);
    Factor& UpperDelta(sint32 k = 1);

    // Get the index.
    sint16 Index() const;

    // Access to the n-th element of the permutation table. We follow
    // the standard mathematical convention; the argument should be
    // between 1 and Index.
    sint16& At(sint16 n);
    sint16 At(sint16 n) const;
    sint16& operator[](sint16 n);
    sint16 operator[](sint16 n) const;

    // Assignment operator.
    Factor& Assign(const Factor& f);
    Factor& operator=(const Factor& f);

    // Comparison operator.
    bool Compare(const Factor& f) const;
    bool operator==(const Factor& f) const;
    bool operator!=(const Factor& f) const;

    // Comparison with special elements.
    bool CompareWithDelta(sint32 k = 1) const;
    bool CompareWithIdentity() const;

    // Composition operators, viewing factors as elements of the
    // permutation group.  We have several variants:

    // b.Composition(a)        return the composition of a and b
    // b.AssignComposition(a)  assign to b the composition of b and a.
    // a*b                     the operator form of b.Composition(a).
    // b *= a                  the operator form of b.AssignComposition(a).
    Factor Composition(const Factor& a) const;
    Factor& AssignComposition(const Factor& a);
    Factor& operator*=(const Factor& a);
    Factor operator*(const Factor& a) const;

    // Inversion operators.  We also have variants:

    // a.Inverse()        return the inverse of a.
    // a.AssignInverse()  invert a.
    // !a                 the operator form of a.Inverse().
    Factor Inverse() const;
    Factor& AssignInverse();
    Factor operator!() const;

    // Complement operations.  For a factor a, ~a=a^(-1) delta is
    // called the complement (i.e. a(~a) = delta).  We provide
    // variants similar to those of inversion.
    /* JLT: bugfix: the function Complement was using ~a (which
       doesn't even compile) rather than the inverse of *this.  Juan
       Gonzales-Menenes had noticed the same thing in his "braiding"
       code; he had used !(*this) rather than this->Inverse(). */
    /* Factor Complement() const { return ~a*Factor(Index(), -1); } */
    Factor Complement() const { return this->Inverse()*Factor(Index(), 1); }
    Factor& AssignComplement() { return *this = Complement(); }
    Factor operator~() const { return Complement(); }

    // Flip operations (conjugation by delta^k, i,e. delta^(-k) a
    // delta^k).
    Factor Flip(sint32 k = 1) const;
    Factor& AssignFlip(sint32 k = 1);

    // Meet operations.  b.LeftMeet(a) (resp. b.RightMeet(a)) returns
    // the left (resp. right) meet of b and a.
    Factor LeftMeet(const Factor& a) const;
    Factor RightMeet(const Factor& a) const;

    // Generate a random factor.
    Factor& Randomize();
};

// Binary function form of the meet operators.
template<class P>
Factor<P> LeftMeet(const Factor<P>& a, const Factor<P>& b);
template<class P>
Factor<P> RightMeet(const Factor<P>& a, const Factor<P>& b);

// Make two factors left (or right) weighted.  false is returned if
// and only if they are already weighted.
template<class P> bool MakeLeftWeighted(Factor<P>& a, Factor<P>& b);
template<class P> bool MakeRightWeighted(Factor<P>& a, Factor<P>& b);

// Output (the permutation table of) a factor through ostream.
template<class P>
std::ostream& operator<<(std::ostream& os, const Factor<P>& f);

// Short type names for canonical factors in Artin's and the band
// generator presentation.
typedef Factor<ArtinPresentation> ArtinFactor;
typedef Factor<BandPresentation> BandFactor;


// Class for a braid.  A braid is represented as a triple (l,
// A_1...A_n, r), where l and r represent the powers of deltas at the
// left and right ends, and A_1,...,A_n is a list of canonical
// factors.
template<class P> class Braid;

// Friend functions.
template<class P>
std::ostream& operator<<(std::ostream& os, const Braid<P>& b);

// Real declaration.
template<class P> class Braid {

public:
    // Type for canonical factors.
    /* JLT: the old code was typedef Factor<P> Factor, which is no
       longer legal C++.  Hence, Factor had to be changed to Factor<P>
       or CanonicalFactor in many places. */
    typedef Factor<P> CanonicalFactor;

private:
    // Presentation description.
    P Pres;

    // We allow direct access to the internal data structure, because
    // their meanings are clear without any additional interfaces, and
    // this is efficient for time-critical jobs.
public:
    // Powers of deltas at ends.
    sint32 LeftDelta, RightDelta;

    // Length of the canonical factor list.
    sint32 CLength;

    // List of canonical factors.  According to my experiments, usual
    // operations on a list of pointers to objects is much faster
    // (about twice) than corresponding operations on a list of
    // objects, especially in the case of STL lists.  Because of this,
    // the following type declaration will be changed later.
    std::list<Factor<P> > FactorList;

public:
    // Iterator types for canonical factors.
    typedef typename std::list<Factor<P> >::iterator FactorItr;
    typedef typename std::list<Factor<P> >::const_iterator ConstFactorItr;
    typedef typename std::list<Factor<P> >::reverse_iterator RevFactorItr;
    typedef typename std::list<Factor<P> >::const_reverse_iterator ConstRevFactorItr;

public:
    // Constructor which creates a trivial braid.
    Braid(sint16 n);

    // Copy constructor.
    Braid(const Braid& b);

    // Construct from a factor.
    Braid(const Factor<P>& f);

    // Destructor.
    ~Braid();

    // Get the index.
    sint16 Index() const;

    // Initialize as a trivial braid.
    Braid& Identity();

    // Assignment operator.
    Braid& Assign(const Braid& b);
    Braid& operator=(const Braid& b);

    // Comparison operator. Two braids are viewed as the same ones if
    // and only if they have the same internal representation. Hence
    // braids are usually converted to canonical forms before
    // comparison.
    bool Compare(const Braid& b) const;
    bool operator==(const Braid& b) const;
    bool operator!=(const Braid& b) const;

    // Compare with the trivial representation of the identity braid.
    // true is returned iff both LeftDelta and RightDelta are zero and
    // FactorList is empty.
    bool CompareWithIdentity() const;

    // Inverting operators. a.Inverse() returns the inverse of
    // a. !a is the operator form of Inverse().
    Braid Inverse() const;
    Braid operator!() const;

    // Mutiplication operators. By b.LeftMultiply(a) and
    // b.RightMultiply(a), b becomes a*b and b*a, respectively. a
    // can be either a braid or a factor. More functions are
    // provided for braids. c.Multiply(a,b), c becomes a*b. a*b
    // returns the multiplication. By a*=b, a becomes a*b.
    Braid& LeftMultiply(const Factor<P>& f);
    Braid& RightMultiply(const Factor<P>& f);
    Braid& LeftMultiply(const Braid& a);
    Braid& RightMultiply(const Braid& a);
    Braid& Multiply(const Braid& a, const Braid& b);
    Braid operator*(const Braid& a) const;
    Braid& operator*=(const Braid& a);

    // Get the permutation associated to the braid.
    Factor<P> GetPerm() const;

    // Convertion into canonical forms.
    Braid& MakeLCF();
    Braid& MakeRCF();

    // Reduce the maximal left/right lower/upper subbraid.  By
    // definition, a is the maximal left lower subbraid of a
    // positive braid b if a is maximal among positive left lower
    // braids such that a^(-1) b is positive. b.MaxLeftLower() set
    // x to b return a.  The other three are similar.
    Braid ReduceLeftLower();
    Braid ReduceLeftUpper();
    Braid ReduceRightLower();
    Braid ReduceRightUpper();

private:
    // Subroutines used by Reduce{Left, Right}{Upper,Lower}().
    Braid ReduceLeftSub(const Factor<P>& f);
    Braid ReduceRightSub(const Factor<P>& f);

public:
    // Generate a random braid. The result is a braid consisting
    // of cl randomly chosen canonical factors with RightDelta and
    // LeftDelta zero.
    Braid& Randomize(sint32 cl = 1);

    // Friend functions.

    // Print a braid through ostream.
    friend std::ostream& operator<< <>(std::ostream& os, const Braid& b);
};


// Short names for braid types.
typedef Braid<ArtinPresentation> ArtinBraid;
typedef Braid<BandPresentation> BandBraid;


// Conversion between ArtinBraid and BandBraid.
BandBraid ToBandBraid(const ArtinBraid& a);
ArtinBraid ToArtinBraid(const BandBraid& b);


#ifdef USE_CLN

// Catalan number function.
const cln::cl_I& GetCatalanNumber(sint16 n);

// Generate the k-th ballot sequence of length 2n and store it in
// s[1..2n] (note that s[0] is not used).  It is internally used by
// Randomize(), but is declared as public since it has its own worth.
void BallotSequence(CBraid::sint16 n, const cln::cl_I k,
                    CBraid::sint8* s);

#endif // USE_CLN
