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
    braiding_main.cpp,  v 1.0.   04/10/2004
    Juan Gonzalez-Meneses <meneses(at)us.es>
*/


#include "cbraid.h"
#include "braiding.h"
#include <iostream>
#include <iomanip>
#include <fstream>
#include <ctime>
#include <cstdlib>
#include <stdio.h>

using namespace CBraid;
using namespace Braiding;
using namespace std;

int main()
{
  char  c, *file;
  sint16 p=0, power=1, power2=1, i, j, n, repeat=0,
    size, type, rigidity, iteration;
  list <sint16> word, word2, graph, graphinv;
  list<sint16>::iterator itw, itg;

  ArtinBraid B=ArtinBraid(1), B1=ArtinBraid(1),
    B2=ArtinBraid(1), B3=ArtinBraid(1), C=ArtinBraid(1);
  list<ArtinBraid> sss, traj, Cent, vertices, barrows;
  list<ArtinBraid>::iterator it, itb, itb2;

  list<list<ArtinBraid> > uss, sc;
  list<list<ArtinBraid> >::iterator ituss, ituss2;

  list<ArtinFactor> Min, arrows;
  list<ArtinFactor>::iterator itf, itf2;

  bool conj;
  ofstream f;

  while(1)
    {
      cout << endl << endl << endl << endl
	   << "--------------------------------------------------------" << endl
	   << "----------------  This is Braiding 1.0  ----------------" << endl
	   << "--------------------------------------------------------" << endl
	   << "-----|  Copyright (C) 2004 Juan Gonzalez-Meneses  |-----" << endl
	   << "-----| Braiding comes with ABSOLUTELY NO WARRANTY |-----" << endl
	   << "-----|           This is free software            |-----" << endl
	   << "-----| See GNU General Public License in GPL.txt  |-----" << endl
	   << "--------------------------------------------------------" << endl
	   << endl
	   << "l: Left Normal Form          r: Right Normal Form       " << endl
	   << endl
	   << "p: Permutation               x: Crossing numbers        " << endl
	   << endl
	   << "v: Least Common Multiple     ^: Greatest Common Divisor " << endl
	   << endl
	   << "s: Super Summit Set          z: Centralizer             " << endl
	   << endl
	   << "e: Conjugacy Test            u: Ultra Summit Set        " << endl
	   << endl
       << "t: Set of Sliding Circuits   a: Ask for Powers (On/Off)   " << endl
       << endl
       << "q: Quit             " << endl;

      while(1)
	{
	  power=1;
	  power2=1;
	  cout << endl
	       << "--------------------------------------------------------"
	       << endl
	       << endl << "Choose an option: (type '?' for help) ";
	  cin >> ws >> c;

	  /////////////////////////////////////////////////////////////

	  if(c=='l' || c=='r')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      B=ArtinBraid(n);
	      B=WordToBraid(word,n);

	      if(p)
		{
		  power=ReadPower();
		  B=RaisePower(B,power);
		}

	      file=ReadFileName();

	      if(c=='l')
		{
		  cout << endl << "The Left Normal Form is: " << endl << endl;
		  PrintBraidWord(B.MakeLCF());
		  cout << endl;

		  f.open(file);
		  f << endl << "The Left Normal Form of the braid on "
		    << n << " strands" << endl << endl;
		  f.close();
		  PrintWord(word,n,power,file);
		  f.open(file,ios::app);

		  f << endl << endl;

		  f << "is: " << endl << endl;
		  f.close();
		  PrintBraidWord(B.MakeLCF(),file);
		}

	      if(c=='r')
		{
		  cout << endl << "The Right Normal Form is: "
		       << endl << endl;
		  PrintBraidWord(B.MakeRCF());
		  cout << endl;

		  f.open(file);
		  f << endl << "The Right Normal Form of the braid on "
		    << n << " strands" << endl << endl;
		  f.close();
		  PrintWord(word,n,power,file);
		  f.open(file,ios::app);

		  f << endl << endl;

		  f << "is: " << endl << endl;
		  f.close();
		  PrintBraidWord(B.MakeRCF(),file);
		}

	      word.clear();
	    }

	  ////////////////////////////////////////////////

	  if(c=='p')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();

	      B=ArtinBraid(n);
	      B=WordToBraid(word,n);

	      if(p && power!=1)
		B=RaisePower(B,power);

	      B.MakeLCF();

	      file=ReadFileName();
	      f.open(file);

	      ArtinFactor F=ArtinFactor(n, B.LeftDelta);

	      list<ArtinFactor>::iterator itf = B.FactorList.begin();
	      while (itf != B.FactorList.end())
		F *= *(itf++);

	      sint16 *table=new sint16[n+1];
	      for(i=1; i<=n; i++)
		table[i]=0;

	      cout << endl << "The permutation associated to this braid is:"
		   << endl << endl;

	      f << "The permutation associated to the braid on "
		<< n << " strands" << endl << endl;
	      f.close();
	      PrintWord(word,n,power,file);
	      f.open(file,ios::app);
	      f << endl << endl << " is:" << endl << endl;

	      if(F.CompareWithIdentity())
		{
		  cout << "Trivial." << endl << endl;
		  f <<  "Trivial.";
		}
	      else
		{
		  for(i=1; i<=n; i++)
		    {
		      if(F[i]!=i && table[i]==0)
			{
			  cout << "(" << i;
			  f << "(" << i;
			  j=i;
			  while(F[j]!=i)
			    {
			      j=F[j];
			      table[j]=1;
			      cout << "," << j;
			      f << "," << j;
			    }
			  cout << ")";
			  f << ")";
			}
		    }
		}
	      cout << endl << endl;
	      f.close();
	      word.clear();
	    }

	  ///////////////////////////////////////////////////

	  if(c=='x')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();

	      file=ReadFileName();

	      sint16 **cross= new sint16 *[n];
	      for(i=1; i<n; i++)
		cross[i]=new sint16[n+1];

	      Crossing(word,n,power,cross);

	      f.open(file);

	      cout << "The crossing numbers of this braid are:"
		   << endl << endl << "    ";
	      f << "The crossing numbers of the braid on " << n
		<< " strands" << endl << endl;
	      f.close();
	      PrintWord(word,n,power,file);
	      f.open(file,ios::app);
	      f << endl << endl << "are: " << endl << endl << "    ";

	      for(i=2; i<=n; i++)
		{
		  cout << setw(3) << i;
		  f << setw(3) << i;
		}
	      cout.fill('-');
	      cout << endl << "   +" << setw(3*(n-1)) << "-" <<  endl;
	      cout.fill(' ');
	      f.fill('-');
	      f << endl << "   +" << setw(3*(n-1)) << "-" <<  endl;
	      f.fill(' ');

	      for(i=1; i<n; i++)
		{

		  cout << setw(3) << i << "|" << setw(3*i) << cross[i][i+1];
		  f << setw(3) << i << "|" << setw(3*i) << cross[i][i+1];

		  for(j=i+2; j<=n; j++)
		    {

		      cout << setw(3) << cross[i][j];
		      f << setw(3) << cross[i][j];
		    }
		  if(i<n-1)
		    {
		      cout << endl << "   |" << endl;
		      f << endl << "   |" << endl;
		    }
		}
	      cout << endl << endl;
	      f.close();

	      for(i=1; i<n; i++)
		delete[] cross[i];
	      delete[] cross;
	      word.clear();
	    }

	  //////////////////////////////////////////////////////////

	  if(c=='^' || c=='v')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();

	      B1=ArtinBraid(n);
	      B1=WordToBraid(word,n);
	      if(p && power!=1)
		B1=RaisePower(B1,power);

	      B1.MakeLCF();

	      word2=ReadWord(n);
	      if(p)
		power2=ReadPower();

	      B2=ArtinBraid(n);
	      B2=WordToBraid(word2,n);
	      if(p && power2!=1)
		B2=RaisePower(B2,power2);

	      B2.MakeLCF();

	      file=ReadFileName();

	      B=ArtinBraid(n);

	      if(c=='v')
		B=LeftWedge(B1,B2);
	      else
		B=LeftMeet(B1,B2);

	      if(c=='v')
		cout << "The lcm of these braids is:" << endl << endl;
	      else
		cout << "The gcd of these braids is:" << endl << endl;
	      PrintBraidWord(B);
	      cout << endl << endl;

	      f.open(file);

	      if(c=='v')
		f << "The lcm of the braids on " << n << " strands"
		  << endl << endl;
	      else
		f << "The gcd of the braids on " << n << " strands"
		  << endl << endl;
	      f.close();
	      PrintWord(word,n,power,file);
	      f.open(file,ios::app);

	      f << endl << endl << "and" << endl << endl;

	      f.close();
	      PrintWord(word2,n,power2,file);
	      f.open(file,ios::app);

	      f << endl << endl << "is:" << endl << endl;

	      PrintBraidWord(B,file);

	      f.close();
	      word.clear();
	    }

	  //////////////////////////////////////////////////////////

	  if(c=='e')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();

	      B1=ArtinBraid(n);
	      B1=WordToBraid(word,n);
	      if(p && power!=1)
		B1=RaisePower(B1,power);

	      B1.MakeLCF();

	      word2=ReadWord(n);
	      if(p)
		power2=ReadPower();

	      B2=ArtinBraid(n);
	      B2=WordToBraid(word2,n);
	      if(p && power2!=1)
		B2=RaisePower(B2,power2);

	      B2.MakeLCF();

	      file=ReadFileName();

	      C=ArtinBraid(n);

	      conj=AreConjugate(B1,B2,C);

	      if(conj)
		{
		  cout << endl << "These braids are conjugate." << endl << endl
		       << "A conjugating braid is: ";
		  PrintBraidWord(C);
		  cout << endl;
		}
	      else
		{
		  cout << endl << "These braids are not conjugate." << endl;
		}

	      f.open(file);

	      f << "The braids on " << n << " strands" << endl << endl;
	      f.close();
	      PrintWord(word,n,power,file);
	      f.open(file,ios::app);

	      f << endl << endl << "and" << endl << endl;

	      f.close();
	      PrintWord(word2,n,power2,file);
	      f.open(file,ios::app);



	      f << endl << endl;

	      if(conj)
		{
		  f << "are conjugate." << endl << endl
		    << "A conjugating braid is" << endl << endl;
		  f.close();
		  PrintBraidWord(C,file);
		}
	      else
		{
		  f << "are not conjugate.";
		  f.close();
		}

	      word.clear();
	    }

	  /////////////////////////////////////////////////////////////

if(c=='d')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();

	      B1=ArtinBraid(n);
	      B1=WordToBraid(word,n);
	      if(p && power!=1)
		B1=RaisePower(B1,power);

	      B1.MakeLCF();

	      word2=ReadWord(n);
	      if(p)
		power2=ReadPower();

	      B2=ArtinBraid(n);
	      B2=WordToBraid(word2,n);
	      if(p && power2!=1)
		B2=RaisePower(B2,power2);

	      B2.MakeLCF();

	      file=ReadFileName();

	      C=ArtinBraid(n);

	      conj=AreConjugateSC(B1,B2,C);

	      if(conj)
		{
		  cout << endl << "These braids are conjugate." << endl << endl
		       << "A conjugating braid is: ";
		  PrintBraidWord(C);
		  cout << endl;
		}
	      else
		{
		  cout << endl << "These braids are not conjugate." << endl;
		}

	      f.open(file);

	      f << "The braids on " << n << " strands" << endl << endl;
	      f.close();
	      PrintWord(word,n,power,file);
	      f.open(file,ios::app);

	      f << endl << endl << "and" << endl << endl;

	      f.close();
	      PrintWord(word2,n,power2,file);
	      f.open(file,ios::app);



	      f << endl << endl;

	      if(conj)
		{
		  f << "are conjugate." << endl << endl
		    << "A conjugating braid is" << endl << endl;
		  f.close();
		  PrintBraidWord(C,file);
		}
	      else
		{
		  f << "are not conjugate.";
		  f.close();
		}

	      word.clear();
	    }

	  /////////////////////////////////////////////////////////////
if(c=='c')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();

	      B1=ArtinBraid(n);
	      B1=WordToBraid(word,n);
	      if(p && power!=1)
		B1=RaisePower(B1,power);

	      B1.MakeLCF();

	      word2=ReadWord(n);
	      if(p)
		power2=ReadPower();

	      B2=ArtinBraid(n);
	      B2=WordToBraid(word2,n);
	      if(p && power2!=1)
		B2=RaisePower(B2,power2);

	      B2.MakeLCF();

	      file=ReadFileName();

	      C=ArtinBraid(n);

	      conj=AreConjugateSC2(B1,B2,C);

	      if(conj)
		{
		  cout << endl << "These braids are conjugate." << endl << endl
		       << "A conjugating braid is: ";
		  PrintBraidWord(C);
		  cout << endl;
		}
	      else
		{
		  cout << endl << "These braids are not conjugate." << endl;
		}

	      f.open(file);

	      f << "The braids on " << n << " strands" << endl << endl;
	      f.close();
	      PrintWord(word,n,power,file);
	      f.open(file,ios::app);

	      f << endl << endl << "and" << endl << endl;

	      f.close();
	      PrintWord(word2,n,power2,file);
	      f.open(file,ios::app);



	      f << endl << endl;

	      if(conj)
		{
		  f << "are conjugate." << endl << endl
		    << "A conjugating braid is" << endl << endl;
		  f.close();
		  PrintBraidWord(C,file);
		}
	      else
		{
		  f << "are not conjugate.";
		  f.close();
		}

	      word.clear();
	    }

	  /////////////////////////////////////////////////////////////



	  if(c=='z')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();

	      B=ArtinBraid(n);
	      B=WordToBraid(word,n);

	      if(p && power!=1)
		B=RaisePower(B,power);

	      B.MakeLCF();

	      file=ReadFileName();

	      Cent=Centralizer(B);

	      cout << endl << "The centralizer of this braid is generated by: "
		   << endl;

	      iteration=0;

	      for(it=Cent.begin(); it!=Cent.end(); it++)
		{
		  cout << endl << setw(3) << ++iteration << ":  ";
		  PrintBraidWord(*it);
		  cout << endl;
		}

	      f.open(file);

	      f << "The contralizer of the braid on " << n << " strands"
		<< endl << endl;
	      if(p && power!=1)
		f << "( ";

	      for(itw=word.begin(); itw!=word.end(); itw++)
		{
		  if(*itw==n)
		    f << "D ";
		  else if (*itw==-n)
		    f << "-D ";
		  else
		    f << *itw << " ";
		}

	      if(p && power!=1)
		f << ")^" << power;

	      f << endl << endl << "is generated by the following braids:";
	      f.close();

	      iteration=0;
	      for(it=Cent.begin(); it!=Cent.end(); it++)
		{
		  f.open(file,ios::app);
		  f << endl << endl << setw(3) << ++iteration << ":  ";
		  f.close();
		  PrintBraidWord(*it,file);
		}

	      word.clear();
	      Cent.clear();
	    }

	  ////////////////////////////////////////////////////////

	  if(c=='s')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      B=ArtinBraid(n);
	      B=WordToBraid(word,n);

	      if(p)
		{
		  power=ReadPower();
		  B=RaisePower(B,power);
		}

	      file=ReadFileName();

	      f.open(file);

	      sss=SSS(B);

	      size=0;

	      for(it=sss.begin(); it!=sss.end(); it++)
		size++;

	      f << "This file contains the Super Summit Set of the braid: "
		<< endl << endl;
	      f.close();
	      PrintWord(word,n,power,file);
	      f.open(file,ios::app);


	      f << endl << endl << "It has " << size << " elements."
		<< endl << endl;

	      size=1;

	      for(it=sss.begin(); it!=sss.end(); it++)
		{
		  f << endl << setw(5) << size++;
		  f << ":   ";
		  f.close();
		  PrintBraidWord(*it,file);
		  f.open(file,ios::app);
		}
	      f.close();
	      word.clear();
	      sss.clear();
	      delete[] file;
	    }

	  //////////////////////////////////////////////////////////////

	  if(c=='u')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();
	      file=ReadFileName();

	      B=ArtinBraid(n);
	      B=WordToBraid(word,n);

	      if(p && power!=1)
		B=RaisePower(B,power);

	      B.MakeLCF();

	      uss=USS(B);

	      type=ThurstonType(uss);

	      rigidity=Rigidity(uss);

	      PrintUSS(uss,word,n,power,file,type,rigidity);

	      word.clear();
	      uss.clear();
	      delete[] file;
	    }

	  ////////////////////////////////////////////////////////////////

	  if(c=='t')
	    {
	      n=ReadIndex();
	      word=ReadWord(n);
	      if(p)
		power=ReadPower();
	      file=ReadFileName();

	      B=ArtinBraid(n);
	      B=WordToBraid(word,n);

	      if(p && power!=1)
		B=RaisePower(B,power);

	      B.MakeLCF();

	      sc=SC(B);

	      type=ThurstonType(sc);

	      PrintSC(sc,word,n,power,file,type);

	      word.clear();
	      sc.clear();
	      delete[] file;
	    }

	  ////////////////////////////////////////////////////////////////

	  if(c=='a')
	    {
	      if(p)
		{
		  p=0;
		  power=1;
		  cout << endl << "The option of taking powers is disabled."
		       << endl << endl;
		}
	      else
		{
		  p=1;
		  cout << endl << "The option of taking powers is enabled."
		       << endl << endl;
		}
	    }

	  ////////////////////////////////////////////////////////////

	  if(c=='q')
	    break;

	  ////////////////////////////////////////////////////////////

	  if(c=='?')
	    {
	      repeat=1;
	      break;
	    }

	}

      if(repeat==0)
	break;
      else
	repeat=0;

    }
  return 0;
}
