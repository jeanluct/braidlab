#include <new>
#include <string>
#include <cstdio>
#include <cmath>
#include <fstream>
#include "array.h"
#include "matrix.h"
#include "braid.h"
#include "graph.h"
#include "hshoe.h"
#include "help.h"
#include "batch.h"

using namespace trains;

static char* ThurstonType[] = {"Pseudo-Anosov", "Finite Order", "Reducible", "Reducible",
  "Pseudo-Anosov or Reducible", "Unknown"};

static char* Commands[] = {"load", "save", "print", "train", "exit", "relabel", "input",
	"braid", "quit", "q", "dir", "ls", "step", "growth", "printto", "horseshoe", "hs",
	"tol", "precision", "reduction", "check", "help", "tolerance", "prec", "gates", "run"};

const uint NumberOfCommands = 26;

char InputLine[200]; //Input line
char* Input[10]; //Parsed input line
char Filename[20];
char Comment[200];
decimal g; //Growth rate
std::ofstream File;
//decimal TOL = STARTTOL;
//bool GrowthCheck = true;
int Precision = std::cout.precision();

uint Parse(char* In) //Returns number of parameters passed
{
	if (!strlen(In)) return 0;
	uint i; for (i=0; i<=9; i++) strcpy(Input[i], "");
	LowerCase(In); //Convert to lower case
	bool HadSpace = true; //Have we just read a space
	i=0; // Current parameter
	for (uint j=0; j<strlen(In); j++)
	{
		char c = In[j];
		if (c != 32)
		{
			char Temp[2]; Temp[0] = c; Temp[1] = 0;
			if (strlen(Input[i])<20) strcat(Input[i], Temp);
			HadSpace = false;
		}
		else if (!HadSpace)
		{
			HadSpace = true;
			i++;
			if (i>9) THROW("Too many parameters",3);
		}
	}
	if (strlen(Input[i])) return i+1;
	return i;
}



int main(int argc, char* argv[])
{
	using std::cout;
	using std::cin;
	std::set_new_handler(Memory);
        uint CommandNumber;
	uint i; for (i=0; i<=9; i++) Input[i] = new char[20];
	bool Finished = false;
	bool Assigned = false; //Has graph been assigned yet?
	bool FirstTime = true;
	graph G;
	braid B;
	horseshoe H;
	uint Counter1, Counter2;
	cout << "Trains: Version " << VERSION << '\n';
	cout << "An implementation of the Bestvina-Handel algorithm\n";
	cout << "For train tracks of surface automorphisms\n\n";
	cout << "Type 'help' for a list of commands\n";
	while (!Finished) { TRY
	{
		if (FirstTime)
		{
			FirstTime = false;
			if (argc>1)
			{
				G.Load(argv[1]);
				Assigned = true;
				cout << argv[1] << " loaded\n";
			}
		}
		cout << "> ";
		do
		{
			cin.getline(InputLine, 200);
			i = Parse(InputLine);
		} while (!i);
		for (CommandNumber=0; CommandNumber<NumberOfCommands; CommandNumber++)
			if (!strcmp(Input[0], Commands[CommandNumber])) break;
		switch (CommandNumber)
		{
			case 0:    //Load
				if (i>1) strcpy(Filename, Input[1]);
				else
				{
					cout << "Enter filename: ";
					cin >> Filename;
				}
				G.Load(Filename);
				cout << Filename << " loaded\n";
				Assigned = true;
				break;

			case 1:    //Save
				if (!Assigned)
				{
					cout << "Graph not assigned yet\n";
					break;
				}
				if (i>1) strcpy(Filename, Input[1]);
				else
				{
					cout << "Enter filename: ";
					cin >> Filename;
				}
				if (i>2)
				{
					strcpy(Comment, "");
					char Temp[2]; Temp[0] = ' '; Temp[1] = 0;
					for (uint j=2; j<i; j++)
					{
						if (j>2) strcat(Comment, Temp);
						strcat(Comment, Input[j]);
					}
				}
				else strcpy(Comment, "Saved graph");
				G.Save(Filename, Comment);
				cout << "Saved as " << Filename << '\n';
				break;

			case 2:    //Print
				if (!Assigned)	cout << "Graph not assigned yet\n";
				else G.Print();
				break;

			case 3:   //Train
				if (!Assigned)
				{
					cout << "Graph not assigned yet\n";
					break;
				}
				G.Save("xxxxx.tmp");
				g = G.FindTrainTrack();
				if (G.GetType() == pA_or_red || G.GetType() == fo)
					cout << "Now have an efficient fibred surface: Growth " << g << ", Entropy " << log(g) << '\n';
				if (G.GetType() == pA_or_red) G.FindTrack();
				cout << "Isotopy class is " << ThurstonType[G.GetType()] << '\n';
				break;

			case 4: case 8: case 9:   //Exit
				Finished = true;
				break;

			case 5: //Relabel
				if (!Assigned) cout << "Graph not assigned yet\n";
				else G.ReLabel();
				break;

			case 6: //Input
				G.UserInput();
				Assigned = true;
				break;

			case 7: //braid
				cin >> B;
				G.Set(B);
				Assigned = true;
				break;

			case 10: case 11: //dir
				cout << "This function is only defined for DOS implementation. See help topic.";
				cout << '\n';
				break;

			case 12: //step
				if (i==1 || !(Counter1 = atoi(Input[1])) ) Counter1 = 1;
				if (Assigned) G.Save("xxxxx.tmp");
				for (Counter2 = 1; Counter2 <= Counter1; Counter2++)
				{
					if (!Assigned)
					{
						cout << "Graph not assigned yet\n";
						break;
					}
					if (G.PullTight())
					{
						cout << "Pulling tight\n";
						continue;
					}
					if (G.CollapseInvariantForest())
					{
						cout << "Collapsing invariant forest\n";
						continue;
					}
					if (G.AbsorbIntoP())
					{
						cout << "Absorbing into P\n";
						continue;
					}
					if (!G.HasIrreducibleMatrix())
					{
						cout << "Reducible isotopy class\n";
						G.SetType(Reducible1);
						G.FindReduction();
						break;
					}
					if (G.PerformValenceTwoIsotopies())
					{
						cout << "Performing valence two isotopies\n";
						continue;
					}
					if (G.MakeIrreducible())
					{
						cout << "Making irreducible\n";
						continue;
					}
					if (G.FoldToDecreaseLambda())
					{
						cout << "Folding to decrease lambda";
						if (G.HasIrreducibleMatrix()) cout << ": New growth rate is " << G.Growth() << '\n';
						else cout << ": Reducible transition matrix\n";
						continue;
					}
					g = G.Growth();
					if (g-1.0<TOL)
					{
						g = 1.0;
						G.SetType(fo);
					}
					cout << "Now have an efficient fibred surface: Growth " << g << ", Entropy " << log(g) << '\n';
					G.ReLabel();
					if (G.GetType() != fo) G.FindTrack();
					cout << "Isotopy class is " << ThurstonType[G.GetType()] << '\n';
					break;
				}
				break;

			case 13: //growth
				if (!Assigned)
				{
					cout << "Graph not assigned yet\n";
					break;
				}
				G.Save("xxxxx.tmp");
				if (!G.HasIrreducibleMatrix()) cout << "Transition matrix is reducible\n";
				else
				{
					g = G.Growth();
					if (g-1.0 < TOL) g = 1.0;
					cout << "Growth: " << g << "    Entropy: " << log(g) << '\n';
				}
				break;

			case 14:    //printto
				if (!Assigned)
				{
					cout << "Graph not assigned yet\n";
					break;
				}
				if (i>1) strcpy(Filename, Input[1]);
				else
				{
					cout << "Enter filename: ";
					cin >> Filename;
				}
				File.open(Filename);
				G.Print(File);
				cout << "Printed to " << Filename << '\n';
				File.close();
				break;

			case 15: case 16:  //horseshoe
				cin >> H;
				B.Set(H);
				G.Set(B);
				Assigned = true;
				break;

			case 17: case 22://tol
				cout << "Old tolerance is: " << TOL << '\n';
				cout << "New tolerance: ";
				cin >> TOL;
				break;

			case 18: case 23://precision
				cout << "Old precision is: " << Precision << '\n';
				if (i==1 || (!(Precision = atoi(Input[1]))))
				{
					cout << "New precision: ";
					cin >> Precision;
				}
				else cout << "New precision is: " << Precision << '\n';
				cout.precision(Precision);
				break;

			case 19: //reduction
				if (!Assigned)
				{
					cout << "Graph not assigned yet\n";
					break;
				}
				if (G.GetType() != Reducible1 && G.GetType() != Reducible2)
				{
					if (G.GetType() == Unknown) cout << "Isotopy class not known to be reducible\n";
					else cout << "Not a reducible isotopy class\n";
					break;
				}
				if (G.GetType() == Reducible1)
				{
					cout << "The following main edges and their images constitute an invariant subgraph:\n";
					G.PrintReduction();
				}
				else G.PrintGates();
				break;

			case 20: //check
				GrowthCheck = !GrowthCheck;
				if (GrowthCheck) cout << "Checking enabled\n";
				else cout << "Checking disabled\n";
				break;

			case 21: //help
				if (i>1) Help(Input[1]);
				else Help();
				break;

			case 24: //gates
				if (!Assigned)
				{
					cout << "Graph not assigned yet\n";
					break;
				}
				if (G.GetType() != pA && G.GetType() != Reducible2)
				{
					if (G.GetType() == Unknown) cout << "Type of isotopy class not determined\n";
					else cout << "Isotopy class not pseudo-Anosov or reducible with efficient fibred surface\n";
					break;
				}
				G.PrintGates();
				break;
                        case 25:    //run
				if (i>1) strcpy(Filename, Input[1]);
				else
				{
					cout << "Enter filename: ";
					cin >> Filename;
				}
				if (BatchProcess(Filename, Precision)) cout << "\nRun was successful\n";
				Assigned = false;
				break;

			default:
				cout << "Syntax error\n";
		}
	}
	CATCH( (Error& E)
	{
		E.Report();
		if (E.GetType()==0) Assigned = false;
		if (E.GetType()==1 || E.GetType()==2) G.Load("xxxxx.tmp");
		if (E.GetType()==2) cout << "Try decreasing the floating point tolerance\n";
		if (E.GetType()==4) Finished = true;
		if (E.GetType()==1)
		{
			cout << "This is an algorithm error. Please check that the graph map you\n";
			cout << "entered can be realised by an orientation-preserving surface\n";
			cout << "homeomorphism. If you are sure that the input is valid, please\n";
			cout << "notify the author by email (T.Hall@liv.ac.uk) with details of\n";
			cout << "the input, and the error message received. Thank you.\n";
		}
	}      )
	}
	for (i=0; i<=9; i++) delete[] Input[i];
	remove("xxxxx.tmp");
	return 0;
}
