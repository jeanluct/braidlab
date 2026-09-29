# File names and directories
SOURCES       = test.cpp speedtest.cpp braiding_main.cpp
PROGRAMS      = $(SOURCES:.cpp=)
OBJS          = $(SOURCES:.cpp=.o)
CBRAID_LIBDIR = ../lib
CBRAID_INCDIR = ../include
CBRAID_LIB    = $(CBRAID_LIBDIR)/libcbraid.a
DEPFILE       = .depends

# Commands
CXX         ?= g++
MAKEDEPCMD   = $(CXX)

# Compile options.
# Use make USE_CLN=1 to compile with the CLN library.
ifeq ($(USE_CLN),1)
	CPPFLAGS_CLN = -DUSE_CLN
	LIBFLAGS_CLN = -lcln
endif
CPPFLAGS = -Wall -I$(CBRAID_INCDIR) -L$(CBRAID_LIBDIR) $(CPPFLAGS_CLN)
# Use make DEBUG=1 to compile with debug info.
ifeq ($(DEBUG),1)
	CPPFLAGS += -g
else
	# Only optimize when the DEBUG flat is unset.
	CPPFLAGS += -O
endif
LIBFLAGS = -lcbraid $(LIBFLAGS_CLN)
MAKEDEPFLAGS = -M

# Default arguments for test programs.
TEST_ARG =

# Default compile rules
# Rule to make an object file from a source file.
%.o: %.cpp
	$(CXX) -c $(CPPFLAGS) -I$(CBRAID_INCDIR) $<

# Rule to make an executable from an object file.
.o:
	$(CXX) $(CPPFLAGS) $(OBJ) $@.o -o $(subst _main,,$@) $(LIBFLAGS)

# Default target.
all: $(PROGRAMS)

braiding: braiding_main

$(PROGRAMS): $(DEPFILE) $(CBRAID_LIB)

# Build library
$(CBRAID_LIB):
	$(MAKE) -C $(CBRAID_LIBDIR) libcbraid.a

# Sample programs.
do-test: test
	./test $(TEST_ARG)

do-speedtest: speedtest
	./speedtest $(SPEEDTEST_ARG)

# Cleanup.
clean:
	rm -rf $(subst _main,,$(PROGRAMS)) $(OBJS) $(DEPFILE)
	$(MAKE) -C $(CBRAID_LIBDIR) clean

# Make dependencies.
depend:
	rm -f $(DEPFILE)
	$(MAKE) $(DEPFILE)

# Make dependencies file.
$(DEPFILE):
	$(MAKEDEPCMD) $(MAKEDEPFLAGS) $(SOURCES) \
		-I$(CBRAID_INCDIR) > $(DEPFILE)

# Read in dependencies file created by 'make depend'.
sinclude $(DEPFILE)
