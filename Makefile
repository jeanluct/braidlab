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
