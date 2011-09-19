#include <iostream>
#include <list>
#include "braidword.hpp"
#include "braiding.h"

using namespace std;

int main()
{
  const int n = 10;
  braid::braidword bw(n);

  for (int i = 1; i < 10000; ++i)
    {
      int gen = (rand() % (2*n-1)) - (n-1);
      if (gen) bw.right_mult(gen);
    }
  cout << "original braidword = " << bw << endl;

  CBraid::ArtinBraid B(Braiding::WordToBraid(bw,n));

  cout << endl << "The Left Normal Form is: " << endl << endl;
  Braiding::PrintBraidWord(B.MakeLCF());
  cout << endl;

  cout << "Length in Artin generators: " << bw.size() << endl;
  cout << "Factors in normal form:      " << B.FactorList.size() << endl;
}
