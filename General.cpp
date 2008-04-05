#ifdef VS2005
#define _CRT_SECURE_NO_DEPRECATE //For MS compiler

#endif

#include "General.h"
#include "decimal.h"
#include <cstdlib>
#ifndef VS2005
#include <cstring>
#endif
#include <iostream>

namespace trains {

using namespace std;

#ifdef VS2005
extern decimal TOL = STARTTOL;
extern bool GrowthCheck = true;
#endif



Error::Error(const char* Erm, int T)
{
	Type = T;
	strcpy(Message, Erm);
}


void Error::Report()
{
	cout << Message << '\n';
}


void Memory()
{
	THROW("Unable to allocate memory requested",4);
}

void LowerCase(char *s)
{
	for (uint i=0; i<strlen(s); i++) if (s[i]>='A' && s[i]<='Z') s[i]|=32;
}

#ifndef VS2005
void Report(const char *Message)
{
#ifdef __WINDOWSVERSION
	Memo(Message);
#else
	cout << Message << endl;
#endif
}
#endif

#ifdef __WINDOWSVERSION
#ifndef VS2005
void ftos(long double val, char* s, int Prec)
{
	char t[100];
	int d1,d2;
#ifdef VS2005
	strcpy(t,_fcvt(val,Prec,&d1,&d2));
#else
	strcpy(t,fcvt(val,Prec,&d1,&d2));
#endif
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
#endif

} // namespace trains
