## CBraid and Braiding

_CBraid_ is a C++ library originally written by **[Jae Choon Cha](http://gt.postech.ac.kr/~jccha/)**.  It allows various computations on braid groups, such as normal forms.  The code in this project is based on his final version of 2001/12/07 and distributed under the GPL.

The library has been updated to run on modern compilers, and has been merged with _Braiding_ version v1.0 (2004/10/04) originally written by **[Juan Gonzalez-Meneses](http://personal.us.es/meneses/)** and distributed under the GPL.  Maria Cumplido contributed some code for computing sets of sliding circuits.

The code is maintained by **[Jean-Luc Thiffeault](http://www.math.wisc.edu/~jeanluc)**.


## Installation

To compile the example programs, from the base folder run
```
cd programs; make clean; make
```
This will create the executables `braiding`, `speedtest`, and `test` in the `programs` folder, as well as the `libcbraid.a` library in the `libs` folder.

To compile just the library `libcbraid.a`, from the base folder run
```
cd lib; make clean; make
```


[![Analytics](https://ga-beacon.appspot.com/UA-58116885-1/braidlab/readme)](https://github.com/igrigorik/ga-beacon)
