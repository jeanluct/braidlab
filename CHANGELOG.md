# Change Log

## [3.2.5] - 2021-11-17

* Add complex constructor braid(Z), where Z is K x N and contains
  complex trajectory data.

* Many small edits and fixes to the braidlab guide to bring it up to
  date with current syntax.  (Thanks to Giuseppe Di Labbio.)

* Bugfix: missing brackets around `varargout` in `annbraid` caused no
  return argument form to fail.  (Thanks to Giuseppe Di Labbio.)

* Bugfix: missing `lower` in `knot2braid`.  So `'Trefoil'` couldn't be
  capitalized as in examples.  (Thanks to Giuseppe Di Labbio.)

* Add `pure` option to `closure`.


## [3.2.4] - 2019-11-15

* `ttmap` displays in an easy-to-read format the train track map
  contained in the struct returned by `braid.train`.

* `braid.train` replaces `braid.tntype`.  It returns a struct
  containing the Thurston-Nielsen type, the entropy, and now the train
  track map and the transition matrix, all using Toby Hall's C++ train
  track code.

* The `braid.entropy` option name `trains` is now `train`, for
  consistency (though `trains` is still supported).

* Suppress a few warnings exposed by recent compilers.


## [3.2.3] - 2018-04-04

* Bugfix: case issue in `braid.entropy` flags.

* Bugfix: to allow computation of the entropy for huge braids that
  cause intermediate overflow in the update rules, break up large
  braids into smaller chunks, each of which will not overflow, and
  store the logarithmic growth (issue #138).

* Bugfix: for large braids `maxit` could overflow an `int32` (partial
  fix for issue #138).

* Move "utility" debug messages to debug level 2.  Now debug level 1
  should be reserved for mathematical diagnostic information (e.g.,
  internal iterations, convergence).  This provides a cleaner output
  when debugging the actual functionality of the code.


## [3.2.2] - 2017-06-02

* Bugfix: error message maxrhs ID changed name in Matlab R2016b caused
  `databraidTest` to fail (issue #137).


## [3.2.1] - 2016-10-23

* `braid` constructor issues a warning when creating a braid from data
  consisting of unclosed orbits.  Use `braid(closure(XY))` to suppress
  the warning (issue #130).

* Bugfix: `loopsigma_helper` without GMP still tried to compile
  functions with `mpz_class` (issue #131).

* Bugfix: added mutex protection around temporary loop storage (issue #132).


## [3.2] - 2015-08-27

* `braid.mtimes` acting on loops is now multithreaded.

* `braid.braid` can generate normally-distributed random braids

* `braid.subbraid` now has a C++ implementation.

* `loop.plot` takes the option `BasePointColor`.

* Added troubleshooting appendix to braidlab guide, which describes
  global flags and issue reporting.

* Bugfix: prevent creation of empty loop with `loop([])`, or
  equivalently a loop with two punctures with `loop(2)`, or a loop
  with one puncture and a basepoint with `loop(1,'BasePoint')`.

* Bugfix: disallow passing of nonincreasing time vector to `databraid`.

* Bugfix: disallow `inf` and `NaN` when creating braid from generator list.

* Various other small bugfixes.


## [3.1] - 2015-01-11

* The function `braidlab.prop` can be used to set global properties,
  such as the way braids are plotted and the direction of rotation for
  generators.

* `braidlab.prop` can set the absolute tolerance for determining
  coincidence of coordinates when constructing a braid from data
  (property `BraidAbsTo`l).  This replaces the previous relative
  comparison which had been used since 2.0.  (See issue #117.)

* `braid.plot` takes color and linestyle attributes.

* `braid.lk` returns the Lawrence-Krammer representation of a braid.

* The class `annbraid` is used to represent braids on annular domains.

* `databraids` are displayed differently from braids, with crossing
  times shown.

* The braidlab guide has been expanded with a short introduction to
  braids.

* Setting up alternative compilers is described in the troubleshooting
  section of the guide.

* The taffy example in the guide no longer worked, due to some bugs in
  braid creation code when coincident coordinates are involved.  (See
  issues #116 and #117.)  Note that it is possible that the parallel
  code returns different generator sequences when called multiple
  times on the same dataset.  However, the resulting braids are still
  equal (issue #118).

* Some bugfixes.


## [3.0.1] - 2014-12-16

* Improve installation instructions in guide.

* Fix some outdated output in guide.

* Fix a bug when calling C++ version of `intersec`.

* Fix a bug in `braid.mtimes` that disallowed valid action on loop
  with basepoint.

* Remove broken `braid.reducing`.

* Makefile detects Linux 32-bit architecture.


## [3.0] - 2014-12-09

* Move from BitBucket/Mercurial to GitHub/Git, to stay with the times.

* Discourage arrays of loop objects.  Instead, multiple loops live
  inside of a single loop object, but subscripting has been overloaded
  for loops.  Externally, a user should see very little difference to
  the interface (and the guide required no changes), but the speedup
  for a braid acting on a large array of loops is of order 50.

* Loop constructor can now return an array of canonical loops.  This
  is useful for pre-allocating memory, among other things.  To make
  this work, the loop constructor form `loop(a,b)` has been removed
  (use `loop([a b])` instead).  This shouldn't affect things much as
  that form was hardly used and was not documented in the guide.

* Loop constructor can take an option `BasePoint` when creating loops,
  to add an extra puncture.  The basepoint is not allowed to move
  under braid operations.

* Loop constructor: `loop(n)` now returns a loop with `n` punctures,
  rather than `n+1`.  Use `loop(n,'BasePoint')` to add the extra
  puncture.

* `loop.n` now returns the number of non-basepoint punctures.  Use
  `loop.totaln` to get the total number of punctures, including the
  basepoint.

* Loop constructor has an option `Enum` to enumerate a list of loops
  with coordinate values between specified bounds.

* Loop constructor takes `FullTwist` option.

* `loop.minlength` is now a C++ MEX file.

* Update `braid.plot` for Matlab 2014b.

* `braid.tensor` and `databraid.tensor` can handle more than one braid
  at a time.  There was also a bug in `databraid.tensor`: the braids
  have to be interweaved.

* `braid.entropy` supports different length functions.  The arguments
  to entropy have change significantly.  In particular, the
  train-track algorithm is now specified using
  `entropy(b,'Method','trains')`.

* `databraid.entropy` and `databraid.complexity` are no longer
  implemented.  Instead, use `databraid.ftbe` (Finite Time Braiding
  Exponent).  This is to distinguish the entropy of data, which
  doesn't necessarily close, to that of a "true" braid.

* `databraid` now allows generators with simultaneous times, as long
  as all the generators for a given time commute with each other.
  This affects in particular testing for equality of two `databraids`.
  For example, `databraid([1 3],[1 1])` and `databraid([3 1],[1 1])`
  are now equal.

* More unit tests in the testsuite, especially for `cfbraid`
  (undocumented class for canonical form braids, but used behind the
  scenes) and `databraid`.

* And of course, many bugfixes and small tweaks...


## [2.1] - 2014-10-02

* Simplify the linear action code: instead of `braid.linact` use an
  optional return argument for `braid.mtimes`.  `braid.cycle` now does
  what `braid.cyclemat` did.  The nitty-gritty `pos`/`neg` operators
  are invisible to the user (see issue #65).  None of this should
  affect users, since these were not documented in the guide (but now
  they are).

* Fix detection of some limit cycles (issue #52).  Also allow
  specification of an initial loop when looking for cycles.

* Move some utility functions to namespace `+util`, to make them less
  visible to user.

* Moved installation instructions to an appendix in the guide.  Added
  a troubleshooting section.

* Renamed the guide and posted on arXiv.


## [2.0] - 2014-09-24

* Complete rewrite of the Makefiles to simplify them and make them
  compatible with Matlab 2014a (which broke a lot of things).  The
  Makefiles no longer attempt to detect which compiler MEX uses, so
  you'll have to set it manually if you use a nonstandard one (e.g.,
  `make CXX=g++-4.7.1 CC=gcc-4.7.1`).  This has been tested on 64-bit
  Linux and Mac OS.

* When constructing a braid object from data, the braid constructor
  now uses a C++ MEX file (written by Marko Budisic) giving a big
  speedup for large datasets.  Support for parallelization on multiple
  cores is included.  The global variable `BRAIDLAB_threads`
  determines the number of threads used.

* The braid constructor can make knot representatives, e.g.,
  `b=braid('8_3')` returns a braid representative for the third
  8-crossing knot.

* The private method `braid.loopsigma`'s C++ helper functions (used by
  `braid*loop`) can now handle `int32`, `int64`, and `single`, in
  addition to `double`.  This makes checking braid equality and
  triviality much faster, unless overflow occurs and VPI has to be
  used.

* The private method `braid.loopsigma`'s C++ helper functions can also
  handle VPI (Variable Precision Integers) by using GMP, the GNU
  MultiPrecision library.  If you don't have GMP installed, compile
  with option `BRAIDLAB_USE_GMP=0`.  However, this will lead to a
  massive slowdown when working with VPI types (Variable Precision
  Integers).

* New methods in the loop class: `loop.components`, `loop.plot`
  `Components` option, `loop.getgraph`.  These are not yet documented
  in the guide, as they are an advanced feature, though they are
  described in the help text to the functions.

* `braid.burau` and `braid.alexpoly` can use the symbolic toolbox.
  `alexpoly` no longer centers the polynomial by default, since
  centering cannot always be used with a `laurpoly` object, and can
  never be used for integral types.  Use option `centered`.

* `braid.mtimes` acting on loops has an optional output argument that
  records the signs of the `pos`/`neg` operators in the update rules
  (`loopsigma`).  This allows reconstruction of the matrix for the
  effective linear action, as well as checking for limit cycles for
  the action.

* New methods in the braid class: `braid.linact` converts the optional
  output from `braid.mtimes` (see above) to a matrix.  `braid.cycle`
  looks for a limit cycle in the braid action on loops.
  `braid.cyclemat` uses `braid.cycle` to return a matrix corresponding
  to this limit cycle.  The largest eigenvalue of this matrix,
  normalized by the period, gives the Perron root of the largest
  pseudo-Anosov component(s).  This is not documented in the guide
  yet, because it's still a bit experimental.  In particular it
  sometimes fails to find the limit cycle (issue #52).

* Many other small bugfixes and improvements.

Several improvements to the method braid.entropy:

* `braid.entropy` has a C MEX helper function and is much faster.  It
  no longer checks if the braid is trivial, which avoids overflow and
  speeds up the function.

* `braid.entropy`'s convergence has been greatly improved (see next
  item for more details).  With enough iterations, machine precision
  can usually be achieved.

* `braid.entropy`'s optional second return argument has changed from a
  list of iterates to the final generalized eigenvector.  The reason
  is that the internal algorithm has changed: the Dynnikov coordinates
  get renormalized at every step, much like the power iteration method
  for finding the largest eigenvalue of a matrix.  A consequence of
  this is that it is no longer natural to store the iterates.  This
  shouldn't affect things very much, since this optional argument was
  not used widely.


## [1.0.5] - 2014-01-31

* Constructors for Rupert Venzke's psi-family of low-entropy braids.

* Fix bug involving single-trajectory dataset.

* Plot empty braids (why not...).

* `braid.compact` no longer checks for trivial braid, since this can
  take a lot of time (more than the compact itself).

* Unit test for entropy added to testsuite.

* Lighter distribution (just compiled files).

* A few more small bugfixes.


## [1.0.4] - 2014-01-03

* The `databraid` class records crossing times of a dataset.

* Added an example section on taffy pullers to braidlab guide.

* bugfix in testsuite.


## [1.0.3] - 2013-12-20

* The braidlab guide has been updated and expanded, and now has a
  table of contents and a detailed index.

* New methods in `braid` class: `alexpoly` returns the Alexander
  polynomial.  `burau` can now construct a matrix of Laurent
  polynomials (wavelet toolbox required).  `tensor` is the tensor
  product of braids.

* Big speedup in creating braids from data, due to improved safety
  checks on the particle trajectories.


## [1.0.2] - 2013-12-13

* `loopTest.m` in testsuite.

* Clean up files.  Eliminate subrepos.

* First public release.


## [1.0.1] - 2013-12-12

* Check for overflow of loop coordinates.

* Several bugfixes.

* Improved support for VPI (Variable Precision Integers).


## 1.0 - 2013-10-02

First release of braidlab.


[3.2.5]: https://github.com/jeanluct/braidlab/compare/release-3.2.4...release-3.2.5
[3.2.4]: https://github.com/jeanluct/braidlab/compare/release-3.2.3...release-3.2.4
[3.2.3]: https://github.com/jeanluct/braidlab/compare/release-3.2.2...release-3.2.3
[3.2.2]: https://github.com/jeanluct/braidlab/compare/release-3.2.1...release-3.2.2
[3.2.1]: https://github.com/jeanluct/braidlab/compare/release-3.2...release-3.2.1
[3.2]: https://github.com/jeanluct/braidlab/compare/release-3.1...release-3.2
[3.1]: https://github.com/jeanluct/braidlab/compare/release-3.0.1...release-3.1
[3.0.1]: https://github.com/jeanluct/braidlab/compare/release-3.0...release-3.0.1
[3.0]: https://github.com/jeanluct/braidlab/compare/release-2.1...release-3.0
[2.1]: https://github.com/jeanluct/braidlab/compare/release-2.0...release-2.1
[2.0]: https://github.com/jeanluct/braidlab/compare/release-1.0.5...release-2.0
[1.0.5]: https://github.com/jeanluct/braidlab/compare/release-1.0.4...release-1.0.5
[1.0.4]: https://github.com/jeanluct/braidlab/compare/release-1.0.3...release-1.0.4
[1.0.3]: https://github.com/jeanluct/braidlab/compare/release-1.0.2...release-1.0.3
[1.0.2]: https://github.com/jeanluct/braidlab/compare/release-1.0.1...release-1.0.2
[1.0.1]: https://github.com/jeanluct/braidlab/compare/release-1.0...release-1.0.1
