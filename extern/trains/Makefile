.PHONY: all lib libtrains clean distclean

all:
	$(MAKE) -C src all

lib libtrains libtrains.a:
	$(MAKE) -C src lib

# Clean up directory.  Remove object files and dependencies file.
clean:
	$(MAKE) -C src clean

# Clean up everything, including executables and library.
distclean:
	$(MAKE) -C src distclean
