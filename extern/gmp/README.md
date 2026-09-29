# GMP

The binary packages of braidlab link the [GNU Multiple Precision
Arithmetic Library](https://gmplib.org/) (GMP) statically into the MEX
files that use it (`cross2gen_helper`, `loopsigma_helper`,
`entropy_helper`), so no separate GMP installation is needed.

GMP is dual-licensed under the GNU Lesser General Public License v3 or the
GNU General Public License v2, each with the option of later versions.
braidlab uses it under the GNU General Public License v3, the same license
as braidlab itself (see `COPYING` at the top of the package).  GMP's own
license texts are in this folder.

The GMP version used is recorded in `BUILD-MANIFEST.txt`.  Its source code
is available from <https://gmplib.org/> and the GNU mirrors
(<https://ftp.gnu.org/gnu/gmp/>).  braidlab's own source code, including
the scripts that build GMP for these packages, is at
<https://github.com/jeanluct/braidlab>.
