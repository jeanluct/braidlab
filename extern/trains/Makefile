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

LIBS = -ltrains

OBJS = $(OBJSOURCES:.cpp=.o)

# Rule to make an object file from a source file.
.cpp.o:
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/$*.cpp $(INCLUDES)

# Rule to make an executable from an object file.
.o:
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(OBJ) $@.o -o $@ -L. $(LIBS)

lib libtrains: libtrains.a

libtrains.a: $(OBJS)
	ar cr libtrains.a $(OBJS)
	ranlib libtrains.a

frontend: libtrains.a frontend.cpp

train: libtrains.a train.cpp

# Clean up directory.  Remove object files and dependencies file.
clean:
	rm -f $(OBJS) $(DEPFILE)

# Clean up everything, including executables and library.
distclean: clean
	rm -f xxxxx.tmp frontend libtrains.a
