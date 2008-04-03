#ifndef __GENERAL_H
#define __GENERAL_H

#include <cstdlib>
#include <string>
#include <iostream>

#define VERSION "2.1  September 2004"

#define __BORLAND //Comment out this line if your compiler has problems with some header files

typedef unsigned int uint;
//typedef int  bool;

#define false 0
#define true 1

extern bool GrowthCheck; //Should we check growth is decreasing in fold?

#define ARRAYSIZ 50
#define ARRAYDELTA 20

#define MAXITER 1000


	#define TRY try
	#define THROW(x,n) throw(Error(x,n))
	#define CATCH(x) catch x

	class Error {
		char Message[100];
		int Type; //0 = IO error, 1 = Algorithm error, 2 = Special error(decrease tol), 3 = other 4 = terminal
	public:
		Error(char* Erm, int T);
		void Report();
		int GetType() {return Type;}
	};



void Memory();

void LowerCase(char *s);

void ftos(long double val, char* res, int Prec);


Error::Error(char* Erm, int T)
{
	Type = T;
	strcpy(Message, Erm);
}


void Error::Report()
{
	std::cout << Message << '\n';
}


void Memory()
{
	THROW("Unable to allocate memory requested",4);
}

void LowerCase(char *s)
{
	for (uint i=0; i<strlen(s); i++) if (s[i]>='A' && s[i]<='Z') s[i]+=32;
}

void ftos(long double val, char* s, int Prec)
{
   char t[100];
   int d1,d2;
   strcpy(t,fcvt(val,Prec,&d1,&d2));
   if (d2) strcpy(s,"-");
   else strcpy(s,"");
   if (d1>0)
   {
      for (d2=strlen(t)+1; d2>=d1; d2--) t[d2+1]=t[d2];
      t[d1]='.';
      strcat(s,t);
   }
   else
   {
      strcat(s,"0.");
      for (d2=0; d2<-d1; d2++) strcat(s,"0");
      strcat(s,t);
   }
}


#endif
