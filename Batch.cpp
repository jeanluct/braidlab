#if defined VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler
//
#endif

#include <fstream>
#include <sstream>
#include <cstring>
#include <iomanip>
#include <string>
#include <vector>
#include <algorithm>
#include <cctype>
#include "Batch.h"
#include "braid.h"
#include "graph.h"

namespace trains {

using namespace std;

static char* TType[] = {"Pseudo-Anosov", "Finite Order", "Reducible", "Reducible",
"Pseudo-Anosov or Reducible", "Unknown"};

static string Comms[] = {"to", "str", "out", "br", "save", "hs", "print", "ifpa", "ifred", "iffo", "ifreset", "shortsing", "longsing", "randomhs", "randombr", "prec", "factor", "nofactor", "boundaryperipheral", "boundarynonperipheral","bp", "bnp", "ss", "ls", "beep", "raw", "latex", "maple"};
const uint NumberOfComms = 28;

vector<string> In; //Parsed input line
decimal gr;
graph G;
braid B;
horseshoe H;
vector<int> OutputFormat;
bool ConOutput;
bool HS;
bool ifpa, ifred, iffo;
bool shortsing;
bool factor;
bool boundaryPeripheral;
matrixformat format;
string HSstring;
ofstream oFile;

#ifdef __WINDOWSVERSION
#ifndef VS2005
#define THRO(T,N) {{Memo(T);   \
	if (!ConOutput) oFile.close();                                        \
	return false;   }}
#else
#define THRO(T,N) {{RemoteGraph.Messages.push_back(T);   \
	if (!ConOutput) oFile.close();                                        \
	return false;   }}                            
#endif
#else
#define THRO(T,N) {{    \
	if (!ConOutput) oFile.close();   cout << T << '\n';                                     \
	return false;   }}
#endif

int stringtoint(const string& s)
{
	istringstream is(s);
	int i;
	is >> i;
	return i;
}


uint Par(string Inp) //Returns number of parameters passed
{
	//Remove comments and strip initial spaces
	string::size_type i = Inp.find_first_of("%");
	if (i != string::npos) Inp.erase(i);
	i = Inp.find_first_not_of(" ");
	if (i == string::npos) return 0;
    Inp.erase(0, i);
	In.clear();
	transform(Inp.begin(), Inp.end(), Inp.begin(), (int(*)(int)) tolower); //Convert to lower case
	istringstream is(Inp);
	string word;
	while (is >> word) In.push_back(word);
	return In.size();
}

void Display(ostream& out, int Prec, bool addNewLines = false)
{
	out << setiosflags(ios::fixed) << setprecision(Prec);
	for (vector<int>::iterator I = OutputFormat.begin(); I != OutputFormat.end(); ++I)
	{
		switch (*I)
		{
		case 0:
			out << TType[G.GetType()];
			break;
		case 1:
			if (HS) out << "Orbit: " << HSstring;
			else out << "Braid: " << B;
			break;
		case 2:
			if (G.GetType() < 4 && G.GetType() != 2) out << "Growth: " << gr;
			break;
		case 3:
			out << '\n';
			break;
		case 4:
			out << ' ';
			break;
		case 5:
			G.Print(out);
			break;
#ifdef __CHARPOLY
		case 6:
			out << "CharPoly: " << G.CharacteristicPolynomial(factor);
			break;
#endif
		case 7:
			if (G.GetType() == pA) G.PrintSingularities(out, shortsing);
			break;
		case 8:
			vector<string> M = G.TransitionMatrix(format);
			copy(M.begin(), M.end(), ostream_iterator<string>(out, "\n"));
			break;
		}
	}
	if (addNewLines)  out << endl;
}

bool BatchProcess(char* Filename, int Prec
#ifdef VS2005
				  ,graph& RemoteGraph
#endif
				  )
{
	ifstream iFile;
	iFile.open(Filename);
	if (!iFile) THRO("Cannot find batch file", 5);
	bool result = BatchProcess(iFile, Prec  
#ifdef VS2005
		, RemoteGraph
#endif
		);
	iFile.close();
	return result;
}


bool BatchProcess(istream& iFile, int Prec
#ifdef VS2005
				  ,graph& RemoteGraph
#endif
				  )
{
	int str=3; //Number of strings
	bool autostring = true;
	ConOutput = true;
	ifpa = ifred = iffo = false;
	factor = true;
	shortsing = false;
	boundaryPeripheral = false;
	format = raw;
	OutputFormat.clear();
	OutputFormat.push_back(1);
	OutputFormat.push_back(3);
	OutputFormat.push_back(0);
	OutputFormat.push_back(4);
	OutputFormat.push_back(2);
	OutputFormat.push_back(3);
	string InLine; //Input line
	while (!iFile.eof())
	{
		getline(iFile, InLine);
		uint i=Par(InLine);
		if (!i) continue;
		uint CNo;
		for (CNo=0; CNo<NumberOfComms; CNo++)
			if (In[0] == Comms[CNo]) break;
		switch (CNo)
		{
		case 0:  //to
			if (i==1) THRO("No Output filename specified in batch file", 5);
			if (In[1] == "con")
			{
				if (!ConOutput) oFile.close();
				ConOutput = true;
			}
			else
			{
				if (!ConOutput) oFile.close();
				ConOutput = false;
				oFile.open(In[1].c_str());
				if (!oFile) THRO("Cannot open file for output", 5);
			}
			break;
		case 1: //str
			if (i==1) THRO("Invalid str statement in batch file", 5);
			if (In[1] == "auto") autostring = true;
			else
			{
				autostring = false;
				str = stringtoint(In[1]);
				if (!str) THRO("Invalid str statement in batch file", 5);
				if (str<3) THRO("Too few strings in batch file", 5);
			}
			break;
		case 2: //out
			{
				OutputFormat.clear();
				for (vector<string>::iterator I = ++In.begin(); I != In.end(); ++I)
				{
					for (string::iterator J = I->begin(); J!= I->end(); ++J)
					{
						switch (*J)
						{
						case 't':
							OutputFormat.push_back(0);
							break;
						case 'b':
							OutputFormat.push_back(1);
							break;
						case 'g':
							OutputFormat.push_back(2);
							break;
						case '/':
							OutputFormat.push_back(3);
							break;
						case '.':
							OutputFormat.push_back(4);
							break;
						case 'd':
							OutputFormat.push_back(5);
							break;
#ifdef __CHARPOLY
						case 'p':
							OutputFormat.push_back(6);
							break;
#endif
						case 's':
							OutputFormat.push_back(7);
							break;
						case 'm':
							OutputFormat.push_back(8);
							break;
						default:
							THRO("Invalid format specifier in batch file", 5);
						}
					}
				}
				break;
			}
		case 3: //br
			{
				HS = false;
				bool Finished = false;
				intarray W;
				uint pos = 1;
				uint size = 2;
				int gen;
				W.Flush();
				while (!Finished)
				{
					if (pos < i)
					{
						gen = stringtoint(In[pos++]);
						if (!gen) Finished = true;
						else
						{
							W.SureAdd(gen);
							if (abs(gen)>static_cast<int>(size)) size = abs(gen);
						}
					}
					else
					{
						do
						{
							getline(iFile, InLine);
							i=Par(InLine);
						} while (!i);
						pos = 0;
					}
				}
				size++;
				if (!autostring && static_cast<int>(size)>str) THRO("Illegal braid generator in batch file",5);
				if (autostring) B.Set(size,W);
				else B.Set(str,W);
				if (boundaryPeripheral) G.BoundaryPeripheralSet(B);
				else G.Set(B);
				gr = G.FindTrainTrack();
				if (G.GetType() == pA_or_red) G.FindTrack();
				if (!((!ifpa && !ifred && !iffo) || (ifpa && G.GetType()==pA) || (ifred && (G.GetType()==Reducible1 || G.GetType()==Reducible2)) || (iffo && (G.GetType()==fo)))) break;
				if (ConOutput)
				{
					ostringstream os;
					Display(os, Prec);
					istringstream is(os.str());
					while (!is.eof())
					{
						string Message;
						getline(is, Message);
#ifdef __WINDOWSVERSION
#ifndef VS2005
						Memo(Message);
#else
						RemoteGraph.Messages.push_back(Message);
#endif
#else
						cerr << Message << '\n';
#endif
					}

				}
				else Display(oFile,Prec,true);
				break;
			}
		case 4: //save
			{
				if (i==1) THRO("No Save filename specified in batch file",5);
				G.Save(In[1]);
				break;
			}
		case 5: //hs
			{
				HS = true;
				H.n = 1;
				H.L[1].s.Flush();
				for (uint i=0; i<In[1].length(); ++i)
				{
					if (In[1][i]!='0' && In[1][i]!='1') THRO("Illegal horseshoe code symbol",5);
					if (In[1][i]=='0') H.L[1].s[i+1]=0;
					else H.L[1].s[i+1]=1;
				}
				if (!H.FindPermutation()) THRO("Illegal horseshoe orbit code",5);
				HSstring = In[1];
				B.Set(H); 
				if (boundaryPeripheral) 
					G.BoundaryPeripheralSet(B);
				else G.Set(B);
				gr = G.FindTrainTrack();
				if (G.GetType() == pA_or_red) G.FindTrack();
				if (!((!ifpa && !ifred && !iffo) || (ifpa && G.GetType()==pA) || (ifred && (G.GetType()==Reducible1 || G.GetType()==Reducible2)) || (iffo && (G.GetType()==fo)))) break;
				if (ConOutput)
				{
					ostringstream os;
					Display(os, Prec);
					istringstream is(os.str());
					while (!is.eof())
					{
						string Message;
						getline(is, Message);
#ifdef __WINDOWSVERSION
#ifndef VS2005
						Memo(Message);
#else
						RemoteGraph.Messages.push_back(Message);
#endif
#else
						cerr << Message << '\n';
#endif
					}
				}
				else Display(oFile,Prec,true);
				break;
			}
		case 6: //print
			{
				string ToPrint;
				for (uint j=1; j<i; ++j)
				{
					if (j>1) ToPrint += " ";
					ToPrint += In[j];
				}
				if (ConOutput)
				{
#ifdef __WINDOWSVERSION
#ifndef VS2005
					Memo(ToPrint);
#else
					RemoteGraph.Messages.push_back(ToPrint);
#endif
#else
					cerr << ToPrint << '\n';
#endif
				}
				else oFile << ToPrint << '\n';
				break;
			}
		case 7: //ifpa
			{
				ifpa = true;
				break;
			}
		case 8: //ifred
			{
				ifred = true;
				break;
			}
		case 9: //iffo
			{
				iffo = true;
				break;
			}
		case 10: //ifreset
			{
				ifpa = ifred = iffo = false;
				break;
			}
		case 11: case 22://shortsing
			{
				shortsing = true;
				break;
			}
		case 12: case 23: //longsing
			{
				shortsing = false;
				break;
			}
		case 13: //randomhs
			{
				if (i<=2) THRO("Illegal randomhs command in batch file", 5);
				int numberOfOrbits = stringtoint(In[1]);
				uint period = stringtoint(In[2]);
				if (numberOfOrbits < 1 || numberOfOrbits > 100000 || period < 3) THRO("Illegal randomhs command in batch file", 5);
				HS = true;
				H.n = 1;
				for (int j=0; j<numberOfOrbits; ++j)
				{
					H.L[1].s.Flush();
					do
					{
						HSstring.clear();
						for (uint k=1; k<=period; ++k) 
						{
							H.L[1].s[k] = (rand()%2==0) ? 0 : 1;
							HSstring += (H.L[1].s[k]==0) ? "0" : "1";
						}
					} while (!H.FindPermutation());
					B.Set(H); 
					if (boundaryPeripheral) G.BoundaryPeripheralSet(B);
					else G.Set(B);
					gr = G.FindTrainTrack();
					if (G.GetType() == pA_or_red) G.FindTrack();
					if (!((!ifpa && !ifred && !iffo) || (ifpa && G.GetType()==pA) || (ifred && (G.GetType()==Reducible1 || G.GetType()==Reducible2)) || (iffo && (G.GetType()==fo)))) continue;
					if (ConOutput)
					{
						ostringstream os;
						Display(os, Prec);
						istringstream is(os.str());
						while (!is.eof())
						{
							string Message;
							getline(is, Message);
#ifdef __WINDOWSVERSION
#ifndef VS2005
							Memo(Message);
#else
							RemoteGraph.Messages.push_back(Message);
#endif
#else
							cerr << Message << '\n';
#endif
						}
					}
					else Display(oFile,Prec,true);
				}
					break;
			}
		case 14: //randombr
			{
				if (i<=3) THRO("Illegal randombr command in batch file", 5);
				uint numberOfBraids = stringtoint(In[1]);
				int numberOfStrings = stringtoint(In[2]);
				uint numberOfGenerators = stringtoint(In[3]);
				if (numberOfBraids < 1 || numberOfBraids > 100000 || numberOfStrings<3 || numberOfGenerators<1 || numberOfGenerators > 1000) THRO("Illegal randombr command in batch file", 5);
				HS = false;
				for (uint j=0; j<numberOfBraids; ++j)
				{
					intarray W;
					W.Flush();
					int previousGenerator = 0;
					int gen;
					for (uint k=0; k<numberOfGenerators; ++k)
					{
						do
						{
							gen = rand() % (2*numberOfStrings - 2);
							if (gen <= numberOfStrings-2) gen -= (numberOfStrings-1);
							else gen -= (numberOfStrings-2);
						} while (gen == -previousGenerator);
						W.SureAdd(gen);
						previousGenerator = gen;
					}
					B.Set(numberOfStrings,W);
					if (boundaryPeripheral) G.BoundaryPeripheralSet(B);
					else G.Set(B);
					gr = G.FindTrainTrack();
					if (G.GetType() == pA_or_red) G.FindTrack();
					if (!((!ifpa && !ifred && !iffo) || (ifpa && G.GetType()==pA) || (ifred && (G.GetType()==Reducible1 || G.GetType()==Reducible2)) || (iffo && (G.GetType()==fo)))) continue;
					if (ConOutput)
					{
						ostringstream os;
						Display(os, Prec);
						istringstream is(os.str());
						while (!is.eof())
						{
							string Message;
							getline(is, Message);
#ifdef __WINDOWSVERSION
#ifndef VS2005
							Memo(Message);
#else
							RemoteGraph.Messages.push_back(Message);
#endif
#else
							cerr << Message << '\n';
#endif
						}
					}
					else Display(oFile,Prec,true);
				}
			}
			break;
		case 15: //prec
			{
				if (i==1) THRO("Invalid prec statement in batch file", 5);
				int newprec = stringtoint(In[1]);
				if (newprec < 0) newprec = 0;
				if (newprec > 14) newprec = 14;
				Prec = newprec;
			}
			break;
		case 16: //factor
			factor = true;
			break;
		case 17: //nofactor
			factor = false;
			break;
		case 18: case 20: //boundaryperipheral
			boundaryPeripheral = true;
			break;
		case 19: case 21: //boundarynonperipheral
			boundaryPeripheral = false;
			break;
		case 24: //beep
#ifdef VS2005
			System::Console::Beep();
#endif
			break;
		case 25: //raw
			format = raw;
			break;
		case 26: //latex
			format = latex;
			break;
		case 27:
			format = maple;
			break;
		default:
			THRO("Unknown command in batch file", 5);
		}
	}
	if (!ConOutput) oFile.close();
	return true;
}

} // namespace trains
