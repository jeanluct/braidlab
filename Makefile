all:
	cd +braidlab/@braid/private; make all
	cd +braidlab/@cfbraid/private; make all

clean:
	cd cbraid/lib; make clean
	cd +braidlab/@braid/private; make clean
	cd +braidlab/@cfbraid/private; make clean
