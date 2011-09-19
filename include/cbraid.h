/*
    Copyright (C) 2000-2001 Jae Choon Cha.

    This file is part of CBraid.

    CBraid is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    any later version.

    CBraid is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with CBraid; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/


/*
    $Id: cbraid.h,v 1.17 2001/12/07 10:12:13 jccha Exp $
    Jae Choon Cha <jccha@knot.kaist.ac.kr>

    Main header file of cbraid library.
*/


#ifndef _cbraid_h_
#define _cbraid_h_


#include <algorithm>
#include <functional>
#include <list>

#include <iostream>
#include <cstdlib>

#ifdef USE_CLN
#include <cln/cln.h>
#endif


namespace CBraid {

// Interfaces of cbraid library. All the declarations are here.
#include "cbraid_interface.h"

// Implementations of inline functions. Fairly many functions are
// defined as inline, because of the speed and efficiency. (Usually
// compilers can optimize inline functions better.)
#include "cbraid_implementation.h"

}

#endif // _cbraid_h_
