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
    $Id: timecounter.h,v 1.1 2001/12/07 10:12:15 jccha Exp $
    Jae Choon CHA <jccha@knot.kaist.ac.kr>

    TimeCounter is a simple time counter (stop watch) class.
*/


#ifndef _TIMECOUNTER_H_
#define _TIMECOUNTER_H_


#include <ctime>


class TimeCounter {

private:
	std::clock_t start, stop;

public:
    static const std::clock_t ClocksPerSec = CLOCKS_PER_SEC;

    std::clock_t Start() { return (start = clock()); }
    std::clock_t Stop() { return (stop = clock()); }

    std::clock_t IntervalClock() { return stop-start; }
    double IntervalSec() { return double(IntervalClock())/CLOCKS_PER_SEC; }
};


#endif // _TIMECOUNTER_H_
