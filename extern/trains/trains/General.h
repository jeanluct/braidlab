//Common include file

#ifndef __GENERAL_H
#define __GENERAL_H

#ifndef VS2005
#define VERSION "4.0 March 2008"
#define VERSION_NUMBER 3.3
#else
#define VERSION "4.3 June 2007"
#define VERSION_NUMBER 4.3
#endif


#ifdef __BORLAND_CPP
#define __WINDOWSVERSION
#else
#ifdef VS2005
#define __WINDOWSVERSION
#else
#define __UNIXVERSION
#endif
#endif




// Turn on/off the charpoly command (no need to link NTL if off).
#undef __CHARPOLY



namespace trains {

typedef unsigned int uint;

extern bool GrowthCheck; //Should we check growth is decreasing in fold?

#define ARRAYSIZ 50
#define ARRAYDELTA 200

#define MAXITER 1000

#define MAXARRAYLENGTH 300000


#define TRY try
#define THROW(x,n) throw(Error(x,n))
#define CATCH(x) catch x

class Error {
public:
	char Message[100];
	int Type; //0 = IO error, 1 = Algorithm error, 2 = Special error(decrease tol), 3 = other 4 = terminal
	Error(const char* Erm, int T);
	void Report();
	int GetType() {return Type;}
};


void Memory();

void LowerCase(char *s);

#ifndef VS2005
void Report(const char *Message); //in windows, reports using Memo. In unix, reports using cout
#endif

#ifdef __WINDOWSVERSION

void ftos(long double val, char* res, int Prec);
#ifndef VS2005
void Memo(const char *s);

void WinErr(char *s, int Type=0);
#endif


#endif

} // namespace trains

#endif
