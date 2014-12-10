/*
    Copyright (C) 2004 Juan Gonzalez-Meneses.

    This file is part of Braiding.

    Braiding is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    any later version.

    Braiding is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Braiding; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/
/*
    braiding.h,  v 1.0.   04/10/2004
    Juan Gonzalez-Meneses <meneses(at)us.es>
*/


#include "cbraid.h"
#include <iostream>
#include <iomanip>
#include <fstream>

using namespace CBraid;
using namespace std;

namespace Braiding {

///////////////////////////////////////////////////////
//
//  CL(B)  computes the Canonical length of a braid B,
//         given in Left Canonical Form
//
///////////////////////////////////////////////////////

sint16  CL(ArtinBraid B);


///////////////////////////////////////////////////////
//
//  Sup(B)  computes the supremun of a braid B,
//          given in Left Canonical Form
//
///////////////////////////////////////////////////////

sint16  Sup(ArtinBraid B);


///////////////////////////////////////////////////////
//
//  Cycling(B)  computes the cycling of a braid B,
//              given in Left Canonical Form
//
///////////////////////////////////////////////////////

ArtinBraid Cycling(ArtinBraid B);


///////////////////////////////////////////////////////
//
//  Decycling(B)  computes the decycling of a braid B,
//                given in Left Canonical Form
//
///////////////////////////////////////////////////////

ArtinBraid Decycling(ArtinBraid B);






/////////////////////////////////////////////////////////////
//
//  WordToBraid(w,n)  Transforms a word w (list of letters)
//                    into a braid on n strands in LCF.
//
/////////////////////////////////////////////////////////////

ArtinBraid WordToBraid(list<sint16> w, sint16 n);


/////////////////////////////////////////////////////////////
//
//  PrintBraidWord(B)  Shows on the screen the braid B (given in LCF)
//                     written as a word in Artin generaotrs.
//
/////////////////////////////////////////////////////////////

void PrintBraidWord(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  PrintBraidWord(B,f)  Prints on the file f the braid B (given in LCF)
//                       written as a word in Artin generaotrs.
//
/////////////////////////////////////////////////////////////

void PrintBraidWord(ArtinBraid B, char * file);


/////////////////////////////////////////////////////////////
//
//  PrintWord(word,n,power)  Shows on the screen the braid "word"
//                           on n strands raised to some "power".
//
/////////////////////////////////////////////////////////////

void PrintWord(list<sint16> & word, sint16 n, sint16 power);


/////////////////////////////////////////////////////////////
//
//  PrintWord(word,n,power,file)  Prints on "file" the braid "word"
//                                on n strands raised to some "power".
//
/////////////////////////////////////////////////////////////

void PrintWord(list<sint16> & word, sint16 n, sint16 power, char * file);


/////////////////////////////////////////////////////////////
//
//  Crossing(word,n,power,cross)  Computes the crossing numbers of
//                           the braid on n strands given by
//				     "word" raised to "power".
//
/////////////////////////////////////////////////////////////

sint16 ** Crossing(list<sint16> word, sint16 n, sint16 power, sint16 ** cross);


/////////////////////////////////////////////////////////////
//
//  SendToSSS(B)  Computes a braid conjugate to B that
//                belongs to its Super Summit Set.
//
/////////////////////////////////////////////////////////////

ArtinBraid SendToSSS(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  SendToSSS(B,C)  Computes a braid conjugate to B that
//                  belongs to its Super Summit Set, and a braid
//                  C that conjugates B to the result.
//
/////////////////////////////////////////////////////////////

ArtinBraid SendToSSS(ArtinBraid B, ArtinBraid & C);


/////////////////////////////////////////////////////////////
//
//  LeftWedge(F1,F2)  Given two simple factors F1 and F2, computes
//                    their left lcm. That is, the smallest simple factor
//                    F such that F1<F and F2<F.
//
/////////////////////////////////////////////////////////////

ArtinFactor LeftWedge(ArtinFactor F1, ArtinFactor F2);


/////////////////////////////////////////////////////////////
//
//  RightWedge(F1,F2)  Given two simple factors F1 and F2, computes
//                    their right lcm. That is, the smallest simple factor
//                    F such that F>F1 and F>F2.
//
/////////////////////////////////////////////////////////////

ArtinFactor RightWedge(ArtinFactor F1, ArtinFactor F2);


/////////////////////////////////////////////////////////////
//
//  Remainder(B,F)   Given a positive braid B in LCF and a simple
//                   factor F, computes the simple factor S such
//                   that BS=LeftWedge(B,F).
//
/////////////////////////////////////////////////////////////

ArtinFactor Remainder(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  LeftMeet(B1,B2)  Given two braids B1 and B2, computes
//                    their left gcd. That is, the smallest braid
//                    B such that B<B1 and B<B2.
//
/////////////////////////////////////////////////////////////

ArtinBraid LeftMeet(ArtinBraid B1, ArtinBraid B2);


/////////////////////////////////////////////////////////////
//
//  LeftWedge(B1,B2)  Given two braids B1 and B2, computes
//                    their left lcm. That is, the smallest braid
//                    B such that B1<B and B2<B.
//
/////////////////////////////////////////////////////////////

ArtinBraid LeftWedge(ArtinBraid B1, ArtinBraid B2);


/////////////////////////////////////////////////////////////
//
//  MinSS(B,F)   Given a braid B in its Summit Set (and in LCF),
//               computes the minimal simple factor R such that
//               F<R and B^R is in the Summit Set.
//
/////////////////////////////////////////////////////////////

ArtinFactor MinSS(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  MinSSS(B,F)  Given a braid B in its Super Summit Set (and in LCF),
//               computes the minimal simple factor R such that
//               F<R and B^R is in the Super Summit Set.
//
/////////////////////////////////////////////////////////////

ArtinFactor MinSSS(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  MinSSS(B)  Given a braid B in its Super Summit Set (and in LCF),
//             computes the set of minimal simple factors R that
//             B^R is in the Super Summit Set.
//
/////////////////////////////////////////////////////////////

list<ArtinFactor> MinSSS(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  SSS(B)  Given a braid B, computes its Super Summit Set.
//
/////////////////////////////////////////////////////////////

list<ArtinBraid> SSS(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  Trajectory(B)  Computes the trajectory of a braid B, that is,
//                 a list containing the iterated cyclings of B,
//                 until the first repetition.
//
/////////////////////////////////////////////////////////////

list<ArtinBraid > Trajectory(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  SendToUSS(B)  Computes a braid conjugate to B that
//                belongs to its Ultra Summit Set.
//
/////////////////////////////////////////////////////////////

ArtinBraid SendToUSS(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  SendToUSS(B,C)  Computes a braid conjugate to B that
//                  belongs to its Ultra Summit Set, and a braid
//                  C that conjugates B to the result.
//
/////////////////////////////////////////////////////////////

ArtinBraid SendToUSS(ArtinBraid B, ArtinBraid & C);


/////////////////////////////////////////////////////////////
//
//  Transport(B,F)   Given a braid B (in its USS and in LCF),
//                   and a simple factor F such that B^F is in its SSS,
//                   computes the transport of F.
//
/////////////////////////////////////////////////////////////

ArtinFactor Transport(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  Returns(B,F)   Given a braid B (in its USS and in LCF), and a simple factor
//                 F such that B^F is in its SSS, computes the iterated
//                 transports of F that send B to an element in the trajectory
//                 of B^F, until the first repetition.
//
/////////////////////////////////////////////////////////////

list<ArtinFactor> Returns(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  Pullback(B,F)   Given a braid B (in its USS and in LCF), and a
//                  simple factor F, computes the pullback of F.
//
/////////////////////////////////////////////////////////////

ArtinFactor Pullback(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  MainPullback(B,F)   Given a braid B (in its USS and in LCF), and a
//                      simple factor F, computes a suitable iterated pullback
//                      of F (the factor p_B(F) in Gebhardt's paper).
//
/////////////////////////////////////////////////////////////

ArtinFactor MainPullback(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  MinUSS(B,F)  Given a braid B in its Ultra Summit Set (and in LCF),
//               computes the minimal simple factor R such that
//               F<R and B^R is in the Ultra Summit Set.
//
/////////////////////////////////////////////////////////////

ArtinFactor MinUSS(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  MinUSS(B)  Given a braid B in its Ultra Summit Set (and in LCF),
//             computes the set of minimal simple factors R that
//             B^R is in the Ultra Summit Set.
//
/////////////////////////////////////////////////////////////

list<ArtinFactor> MinUSS(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  USS(B)  Given a braid B, computes its Ultra Summit Set.
//
/////////////////////////////////////////////////////////////

list<list<ArtinBraid> > USS(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  USS(B,mins,prev)  Given a braid B, computes its Ultra Summit Set,
//                    and stores in the lists 'mins' and 'prev'
//                    the following data:
//                    for each i, the first braid of the orbit i is obtained by
//                    conjugation of the first element of the orbit prev[i]
//                    by the simple element mins[i].
//
/////////////////////////////////////////////////////////////

list<list<ArtinBraid> > USS(ArtinBraid B,
			    list<ArtinFactor> & mins, list<sint16> & prev);


/////////////////////////////////////////////////////////////
//
//  TreePath(B,uss,mins,prev)  Computes a braid that conjugates
//                             the first element in the Ultra Summit Set uss
//                             to the braid B (which must be in the uss).
//
/////////////////////////////////////////////////////////////

ArtinBraid   TreePath(ArtinBraid B, list<list<ArtinBraid> > & uss,
		      list<ArtinFactor> & mins, list<sint16> & prev);


/////////////////////////////////////////////////////////////
//
//  AreConjugate(B1,B2,C)  Determines if the braids B1 and B2 are
//                         conjugate, and computes a conjugating
//                         element C.
//
/////////////////////////////////////////////////////////////

bool AreConjugate(ArtinBraid B1, ArtinBraid B2, ArtinBraid & C);


/////////////////////////////////////////////////////////////
//
//  Centralizer(uss,mins,prev)  Computes the centralizer of the first
//                              element in the Ultra Summit Set uss.
//
/////////////////////////////////////////////////////////////

list<ArtinBraid> Centralizer(list<list<ArtinBraid> > & uss,
			     list<ArtinFactor> & mins, list<sint16> & prev);


/////////////////////////////////////////////////////////////
//
//  Centralizer(B)  Computes the centralizer of the braid B.
//
/////////////////////////////////////////////////////////////

list<ArtinBraid> Centralizer(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  Tableau(F,tab)  Computes the tableau associated to a
//                  simple factor F, and stores it in tab.
//
/////////////////////////////////////////////////////////////

void Tableau(ArtinFactor F, sint16 **& tab);


/////////////////////////////////////////////////////////////
//
//  Circles(B)  Determines if a braid B in LCF
//              preserves a family of circles.
//
/////////////////////////////////////////////////////////////

bool Circles(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  ThurstonType(B)  Determines if a braid B is periodic (1),
//                   reducible (2) or pseudo-Anosov (3).
//
/////////////////////////////////////////////////////////////

int ThurstonType(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  ThurstonType(uss)  Determines if the braids in the Ultra
//                     Summit Set uss are periodic (1),
//                     reducible (2) or pseudo-Anosov (3).
//
/////////////////////////////////////////////////////////////

int ThurstonType(list<list<ArtinBraid> > & uss);


/////////////////////////////////////////////////////////////
//
//  Rigidity(B)  Computes the rigidity of a braid B.
//
/////////////////////////////////////////////////////////////

sint16 Rigidity(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  Rigidity(uss)  Computes the maximal rigidity of a braid
//                 in the Ultra Summit Set uss.
//
/////////////////////////////////////////////////////////////

sint16 Rigidity(list<list<ArtinBraid> > & uss);


/////////////////////////////////////////////////////////////
//
//  ReadIndex()   Asks to type the number of strands.
//
/////////////////////////////////////////////////////////////

sint16 ReadIndex();


/////////////////////////////////////////////////////////////
//
//  ReadWord(n)   Asks to type a braid word on n strands,
//               and returns the braid word.
//
/////////////////////////////////////////////////////////////

list<sint16> ReadWord(sint16 n);


/////////////////////////////////////////////////////////////
//
//  ReadPower()   Asks to type the power to which the braid
//                will be raised.
//
/////////////////////////////////////////////////////////////

sint16 ReadPower();


/////////////////////////////////////////////////////////////
//
//  RaisePower(B,k)   Raises the braid B to the power k.
//
/////////////////////////////////////////////////////////////

ArtinBraid RaisePower(ArtinBraid B, sint16 k);


/////////////////////////////////////////////////////////////
//
//  ReadFileName()   Asks to type the name of a file.
//
/////////////////////////////////////////////////////////////

char* ReadFileName();


/////////////////////////////////////////////////////////////
//
//  PrintUSS(word,n,p,power,file)   Prints the Ultra Summit Set
//                                  of the braid (word)^power to "file".
//
/////////////////////////////////////////////////////////////

void PrintUSS(list<list<ArtinBraid> > &  uss, list<sint16> word,
	      sint16 n, sint16 power, char * file, sint16 type,
	      sint16 rigidity);


/////////////////////////////////////////////////////////////
//
//   FileName(iteration,max_iteration,type,orbit,rigidity,cl)
//      Creates the file name corresponding to the given data.
//
/////////////////////////////////////////////////////////////

char * FileName(sint16 iteration, sint16 max_iteration, sint16 type,
		sint16 orbit, sint16 rigidity, sint16 cl);




///////////////////////////////////////////////////////
//
//  Reverse(B)  computes the revese of a braid B, 
//              that is, B written backwards.
//              B must be given in left canonical form.
//
///////////////////////////////////////////////////////

 ArtinBraid Reverse(ArtinBraid B);



/////////////////////////////////////////////////////////////
//
//  RightMeet(B1,B2)  Given two braids B1 and B2, computes  
//                    their right gcd. That is, the greatest braid
//                    B such that B1>B and B2>B. 
//
/////////////////////////////////////////////////////////////


ArtinBraid RightMeet(ArtinBraid B1, ArtinBraid B2);



/////////////////////////////////////////////////////////////
//
//  LeftJoin(B1,B2)  Given two braids B1 and B2, computes  
//                    their left lcm. That is, the smallest braid
//                    B such that B1<B and B2<B. 
//
/////////////////////////////////////////////////////////////


ArtinBraid LeftJoin(ArtinBraid B1, ArtinBraid B2);

/////////////////////////////////////////////////////////////
//
//  RightJoin(B1,B2)  Given two braids B1 and B2, computes  
//                    their right lcm. That is, the smallest braid
//                    B such that B>B1 and B>B2. 
//
/////////////////////////////////////////////////////////////

ArtinBraid RightJoin(ArtinBraid B1, ArtinBraid B2);


///////////////////////////////////////////////////////
//
//  InitialFactor(B)  computes the initial factor of a braid B, 
//                    given in Left Canonical Form
//
///////////////////////////////////////////////////////

ArtinFactor  InitialFactor(ArtinBraid B);

///////////////////////////////////////////////////////
//
//  PreferredPrefix(B)  computes the preferred prefix of a braid B, 
//                      given in Left Canonical Form
//
///////////////////////////////////////////////////////

ArtinFactor  PreferredPrefix(ArtinBraid B);


///////////////////////////////////////////////////////
//
//  Sliding(B)  computes the cyclic sliding of a braid B, 
//                given in Left Canonical Form
//
///////////////////////////////////////////////////////

 ArtinBraid Sliding(ArtinBraid B);

///////////////////////////////////////////////////////
//
//  PreferredSuffix(B)  computes the preferred suffix of a braid B, 
//                      given in Left Canonical Form
//
///////////////////////////////////////////////////////

ArtinFactor  PreferredSuffix(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  Trajectory_Sliding(B)  Computes the trajectory under cyclic sliding 
//                         of a braid B, that is, a list containing eta^k(B), 
//                         for k=0,1,... until the first repetition. 
//
/////////////////////////////////////////////////////////////

list<ArtinBraid > Trajectory_Sliding(ArtinBraid B);

/////////////////////////////////////////////////////////////
//
//  Trajectory_Sliding(B,C,d)  Computes the trajectory of a braid B for cyclic sliding,   
//                     a braid C that conjugates B to the
//                     first element of a closed orbit under sliding,
//                     and the number d of slidings needed to reach that element
//
/////////////////////////////////////////////////////////////

list<ArtinBraid > Trajectory_Sliding(ArtinBraid B, ArtinBraid & C, sint16 & d);

/////////////////////////////////////////////////////////////
//
//  SendToSC(B)  Computes a braid conjugate to B that 
//                belongs to its Sliding Circuits Set.
//
/////////////////////////////////////////////////////////////

ArtinBraid SendToSC(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  SendToSC(B,C)  Computes a braid conjugate to B that 
//                  belongs to its Sliding Circuits Set, and a braid 
//                  C that conjugates B to the result.
//
/////////////////////////////////////////////////////////////


ArtinBraid SendToSC(ArtinBraid B, ArtinBraid & C);


/////////////////////////////////////////////////////////////
//
//  Transport_Sliding(B,F)   Given a braid B (in its SC and in LCF), and a simple factor
//                   F such that B^F is in its SSS, computes the transport of F for sliding.
//
/////////////////////////////////////////////////////////////

ArtinFactor Transport_Sliding(ArtinBraid B, ArtinFactor F);


/////////////////////////////////////////////////////////////
//
//  Returns_Sliding(B,F)   Given a braid B (in its SC and in LCF), and a simple factor
//                 F such that B^F is in its SSS, computes the iterated transports 
//                 of F for sliding that send B to an element in the circuit of B^F.
//
/////////////////////////////////////////////////////////////


list<ArtinFactor> Returns_Sliding(ArtinBraid B, ArtinFactor F); 



/////////////////////////////////////////////////////////////
//
//  Pullback_Sliding(B,F)   Given a braid B (in its SC and in LCF), and a 
//                          simple factor F such that B^F is super summit, 
//                          computes the pullback of F at s(B) for sliding.
//
/////////////////////////////////////////////////////////////

ArtinFactor Pullback_Sliding(ArtinBraid B, ArtinFactor F);



/////////////////////////////////////////////////////////////
//
//  MainPullback_Sliding(B,F)   Given a braid B (in its SC and in LCF), and a 
//                      simple factor F, computes the first repeated iterated 
//                      pullback for cyclic sliding of F.
//
/////////////////////////////////////////////////////////////

ArtinFactor MainPullback_Sliding(ArtinBraid B, ArtinFactor F);

// María Cumplido Cabello


/////////////////////////////////////////////////////////////
//
//  MinSC(B,F)  Given a braid B in its Set of Sliding Circuits (and in LCF),
//               computes the minimal simple factor R such that
//               F<R and B^R is in the Set of Sliding Circuits.
//
/////////////////////////////////////////////////////////////



ArtinFactor MinSC(ArtinBraid B, ArtinFactor F);



/////////////////////////////////////////////////////////////
//
//  MinSC(B)  Given a braid B in its Set of Sliding Circuits (and in LCF),
//             computes the set of minimal simple factors R that
//             B^R is in the Set of Sliding Circuits.
//
/////////////////////////////////////////////////////////////

list<ArtinFactor> MinSC(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  SC(B)  Given a braid B, computes its Set of Cyclic Slidings.
//
/////////////////////////////////////////////////////////////


list<list<ArtinBraid> > SC(ArtinBraid B);


/////////////////////////////////////////////////////////////
//
//  SC(B,mins,prev)  Given a braid B, computes its Set of Sliding Circuits,
//                    and stores in the lists 'mins' and 'prev' the following data:
//                    for each i, the first braid of the orbit i is obtained by
//                    conjugation of the first element of the orbit prev[i]
//                    by the simple element mins[i].
//
/////////////////////////////////////////////////////////////




list<list<ArtinBraid> > SC(ArtinBraid B, list<ArtinFactor> & mins, list<sint16> & prev);


////////////////////////////////////////////////////////////////////////////////////////
//
//  PrintSC(sc,word,n,power,file,type)   Prints the Set of Sliding Circuits
//                                       of the braid (word)^power to "file".
//
////////////////////////////////////////////////////////////////////////////////////////

void PrintSC(list<list<ArtinBraid> > &  sc, list<sint16> word, sint16 n,
	      sint16 power, char * file, sint16 type);

////////////////////////////////////////////////////////////////////////////////////
//
//  AreConjugateSC(B1,B2,C)  Determines if the braids B1 and B2 are
//                           conjugate by testing their set of sliding circuits, 
//                           and computes a conjugating element C.
//
//////////////////////////////////////////////////////////////////////////////////

bool AreConjugateSC(ArtinBraid B1, ArtinBraid B2, ArtinBraid & C);



////////////////////////////////////////////////////////////////////////////////////
//
//  AreConjugateSC2(B1,B2,C)  Determines if the braids B1 and B2 are
//                           conjugate by the procedure of contruct SC(B1), 
//                           and computes a conjugating element C.
//
//////////////////////////////////////////////////////////////////////////////////


bool AreConjugateSC2(ArtinBraid B1, ArtinBraid B2, ArtinBraid & C);






} // namespace Braiding
