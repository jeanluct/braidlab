#ifndef __BATCH_H
#define __BATCH_H

#include <fstream>
#include <string>
#include <cstdio>
#include "general.h"
#include "batch.h"
#include "braid.h"
#include "graph.h"

namespace trains {

bool BatchProcess(char* Filename, int Prec);  

static char* TType[] = {"Pseudo-Anosov", "Finite Order", "Reducible", "Reducible",
  "Pseudo-Anosov or Reducible", "Unknown"};

static char* Comms[] = {"to", "str", "out", "br", "save"};
const uint NumberOfComms = 5;
char InLine[500]; //Input line
char* In[100]; //Parsed input line
decimal gr;
graph G;
braid B;
int OutputFormat[100];
bool ConOutput;
std::ofstream oFile;

#define THRO(T,N) {{  for (uint l=0; l<=99; l++) delete [] In[l];  \
	if (!ConOutput) oFile.close();   std::cout << T << '\n';                                     \
	return false;   }}


uint Par(char* Inp) //Returns number of parameters passed
{
	if (!strlen(Inp)) return 0;
	for (uint i=0; i<=99; i++) strcpy(In[i], "");
	LowerCase(Inp); //Convert to lower case
	bool HadSpace = true; //Have we just read a space
	uint i=0; // Current parameter
	for (uint j=0; j<strlen(Inp); j++)
	{
		char c = Inp[j];
		if (c != 32)
		{
			char Temp[2]; Temp[0] = c; Temp[1] = 0;
			if (strlen(In[i])<20) strcat(In[i], Temp);
			HadSpace = false;
		}
		else if (!HadSpace)
		{
			HadSpace = true;
			i++;
			if (i>99) THRO("Too many parameters in batch file",5);
		}
	}
	if (strlen(In[i])) return i+1;
	return i;
}

void Display(std::ostream& out, int Prec)
{
	uint i=0;
    out.precision(Prec);
	while (OutputFormat[i] != -1)
	{
		switch (OutputFormat[i])
		{
			case 0:
			  out << TType[G.GetType()];
			  break;
			case 1:
			  out << "Braid: " << B;
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
		}
      i++;
	}
}


bool BatchProcess(char* Filename, int Prec)
{
	int str=3; //Number of strings
	bool autostring = true;
        ConOutput = true;
	OutputFormat[0] = 1; OutputFormat[1]=3; OutputFormat[2]=0;
	OutputFormat[3] = 4; OutputFormat[4]=2; OutputFormat[5]=3;
	OutputFormat[6] = -1;
	std::ifstream iFile;
	iFile.open(Filename);
	for (uint i=0; i<=99; i++) In[i] = new char[20];
    if (!iFile) THRO("Cannot find batch file", 5);
	while (!iFile.eof())
	{
		iFile.getline(InLine,500);
		uint i=Par(InLine);
		if (!i) break;
        uint CNo;
		for (CNo=0; CNo<NumberOfComms; CNo++)
			 if (!strcmp(In[0],Comms[CNo])) break;
		switch (CNo)
		{
			case 0:  //to
				if (i==1) THRO("No Output filename specified in batch file", 5);
				if (!strcmp(In[1],"con"))
				{
					if (!ConOutput) oFile.close();
					ConOutput = true;
				}
				else
				{
					if (!ConOutput) oFile.close();
					ConOutput = false;
					oFile.open(In[1]);
					if (!oFile) THRO("Cannot open file for output", 5);
				}
				break;
			case 1: //str
				if (i==1) THRO("Invalid str statement in batch file", 5);
				if (!strcmp(In[1],"auto")) autostring = true;
				else
				{
					autostring = false;
					str = atoi(In[1]);
					if (!str) THRO("Invalid str statement in batch file", 5);
					if (str<3) THRO("Too few strings in batch file", 5);
				}
				break;
			case 2: //out
			 {
				uint posn=0;
				for (uint j=1; j<i; j++)
				{
					for (uint k=0; k<strlen(In[j]); k++)
					{
						switch (In[j][k])
						{
							case 't':
							  OutputFormat[posn++]=0;
							  break;
							case 'b':
							  OutputFormat[posn++]=1;
							  break;
							case 'g':
							  OutputFormat[posn++]=2;
							  break;
							case '/':
							  OutputFormat[posn++]=3;
							  break;
							case '.':
							  OutputFormat[posn++]=4;
							  break;
							case 'd':
							  OutputFormat[posn++]=5;
							  break;
							default:
							  THRO("Invalid format specifier in batch file", 5);
						}
					}
				}
				OutputFormat[posn]=-1;
				break;
			 }
			case 3: //br
				{
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
						  gen = atoi(In[pos++]);
						  if (!gen) Finished = true;
						  else
						  {
							  W.SureAdd(gen);
							  if (abs(gen)>size) size = abs(gen);
						  }
					  }
					  else
					  {
                    do
						  {
							 iFile.getline(InLine,500);
							 i=Par(InLine);
						  } while (!i);
						  pos = 0;
					  }
				  }
				  size++;
				  if (!autostring && size>(uint)str) THRO("Illegal braid generator in batch file",5);
				  if (autostring) B.Set(size,W);
				  else B.Set(str,W);
				  G.Set(B);
				  gr = G.FindTrainTrack();
				  if (G.GetType() == pA_or_red) G.FindTrack();
				  if (ConOutput)
                  {
                     oFile.open("Batchzx.tmp");
                     Display(oFile,Prec);
                     oFile.close();
                     std::ifstream TempFile;
                     TempFile.open("Batchzx.tmp");
                     while (!TempFile.eof())
                     {
                        char Message[250];
                        TempFile.getline(Message,250);
                        std::cerr << Message << '\n';
                     }
                     TempFile.close();
                     remove("Batchzx.tmp");
                  }
				  else Display(oFile,Prec);
				  break;
				}
            case 4: //save
			{
				if (i==1) THRO("No Save filename specified in batch file",5);
 				G.Save(In[1]);
                break;
			}
			default:
				THRO("Unknown command in batch file", 5);
		}
	 }
	for (uint i=0; i<=99; i++) delete [] In[i];
	if (!ConOutput) oFile.close();
	return true;
}


} // namespace trains


#endif
