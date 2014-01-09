#include <new>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <fstream>
#include <string>
#include "newarray.h"
#include "Matrix.h"
#include "braid.h"
#include "graph.h"
#include "hshoe.h"
#include "help.h"
#include "Batch.h"
#include "ttt.h"

using namespace std;

namespace trains {

decimal TOL = 0.0000000001;//STARTTOL;
bool GrowthCheck = true;

static const char* ThurstonType[] = {"Pseudo-Anosov",
				     "Finite Order",
				     "Reducible",
				     "Reducible",
				     "Pseudo-Anosov or Reducible",
				     "Unknown"};
}

using namespace trains;

int main(int argc, char* argv[])
{
  graph G;
  braid B;

  if (argc < 3)
    {
      printf("No enough input arguments.\n");
      exit(-1);
    }

  int n = atoi(argv[1]);
  int k = argc-2;

  intarray w;

  for (int i = 0; i < k; ++i)
    {
      w.SureAdd((long int)atoi(argv[2+i]));
    }

  B.Set(n,w);
  G.Set(B);

  decimal g = G.FindTrainTrack();

  /*
  if (G.GetType() == pA_or_red || G.GetType() == fo)
    cout << "Dilatation=" << g << '\n';
  */

  if (G.GetType() == pA_or_red) G.FindTrack();

  cout << "Thurston type = " << ThurstonType[G.GetType()] << '\n';

  return 0;
}
