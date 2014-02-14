# <LICENSE
#   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
#
#   This file is part of Braidlab.
#
#   Braidlab is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Braidlab is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
# LICENSE>

all:
	cd +braidlab/private; make all
	cd +braidlab/@braid/private; make all
	cd +braidlab/@cfbraid/private; make all
	cd +braidlab/+lcs/private; make all
	cd extern/assignmentoptimal; \
		make all; \
		mv -f assignmentoptimal.mex* ../../+braidlab/private

# remove MEX files and object files.
clean:
	cd extern/assignmentoptimal; make clean
	cd extern/cbraid/lib; make clean
	cd extern/trains; make clean
	cd +braidlab/@braid/private; make clean
	cd +braidlab/@cfbraid/private; make clean
	cd +braidlab/+lcs/private; make clean
	cd +braidlab/private; make clean

# distclean also removes the libraries (useful for recompiling on
# different OS) and the LaTeX-generated files.
distclean: clean
	rm -f extern/cbraid/lib/libcbraid-mex.a
	rm -f extern/trains/libtrains.a
	cd doc; \
		rm -f *.aux *.bbl *.blg *.idx *.ilg *.ind *.log *.out *.toc
