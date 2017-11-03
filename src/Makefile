OBJSOURCES = \
	Batch.cpp \
	braid.cpp \
	edgevert.cpp \
	embedding.cpp \
	General.cpp \
	Graphalg.cpp \
	graph.cpp \
	Graphset.cpp \
	Graputil.cpp \
	help.cpp \
	hshoe.cpp \
	Matrix.cpp \
	ttt.cpp

SRCDIR = .

CXX = g++
CXXFLAGS = -Wall -O3 -ffast-math

LIBS = -L../lib -ltrains

INCLUDES = -I..

OBJS = $(OBJSOURCES:.cpp=.o)

# Rule to make an object file from a source file.
.cpp.o:
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/$*.cpp $(INCLUDES)

# Rule to make an executable from an object file.
.o:
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(OBJ) $@.o -o $@ $(LIBS)

all: lib frontend train

lib libtrains libtrains.a: ../lib/libtrains.a

../lib/libtrains.a: $(OBJS)
	ar cr libtrains.a $(OBJS)
	ranlib libtrains.a
	mv -f libtrains.a ../lib

frontend: ../lib/libtrains.a frontend.o

train: ../lib/libtrains.a train.o

# Clean up directory.  Remove object files and dependencies file.
clean:
	rm -f $(OBJS) frontend.o train.o $(DEPFILE)

# Clean up everything, including executables and library.
distclean:
	rm -f frontend train frontend.o train.o ../lib/libtrains.a \
		$(OBJS) $(DEPFILE)
