// Standard header file for modules using floating point arithmetic
#ifndef __DECIMAL_H
#define __DECIMAL_H

#include <cmath>
#ifdef __WINDOWSVERSION
#ifndef VS2005
#define STARTTOL 0.000001
#else
#define STARTTOL 0.00000000001
#endif
#else
#define STARTTOL 0.000000001
#endif
#define SQRT sqrt
#define FABS fabs

namespace trains {

typedef long double decimal;
extern decimal TOL; //Tolerance

} // namespace trains

#endif
