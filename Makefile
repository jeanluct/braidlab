all:
	cd +braidlab/private; make all
	cd +braidlab/@braid/private; make all
	cd +braidlab/@cfbraid/private; make all
	cd +braidlab/+lcs/private; make all

clean:
	cd extern/cbraid/lib; make clean
	cd extern/trains; make clean
	cd +braidlab/@braid/private; make clean
	cd +braidlab/@cfbraid/private; make clean
	cd +braidlab/+lcs/private; make clean

# distclean also removes the libraries (useful for recompiling on different OS).
distclean: clean
	rm -f extern/cbraid/lib/libcbraid-mex.a
	rm -f extern/trains/libtrains.a
