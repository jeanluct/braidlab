# Makefile Improvements Plan

## Overview
Fix red flags and apply improvements across the braidlab Makefile build system.

## Changes by File

### 1. `Makefile` (root)

#### 1a. Fix GMP detection (lines 93-98)
Replace the `/tmp` file approach with `/dev/null`, and use `$(CC)` instead of bare `cc`:

**Before:**
```make
# Test by attempting to link a tiny program against gmpxx and gmp.
# Use a one-line shell command that pipes source to the compiler to avoid
# issues with multi-line heredocs inside make's $(shell ...).
GMP_CHECK := $(shell printf 'int main(void){return 0;}' \
	| cc -x c - -lgmpxx -lgmp -o /tmp/_braidlab_gmp_test 2>/dev/null \
	&& echo yes || echo no; rm -f /tmp/_braidlab_gmp_test 2>/dev/null)
```

**After:**
```make
# Test by attempting to link a tiny program against gmpxx and gmp.
# Link to /dev/null to avoid temp file races on multi-user systems.
# Use $(CC) so detection matches the compiler used for the actual build.
GMP_CHECK := $(shell printf 'int main(void){return 0;}' \
	| $(CC) -x c - -lgmpxx -lgmp -o /dev/null 2>/dev/null \
	&& echo yes || echo no)
```

#### 1b. Add comment for aarch64 MEXSUFFIX (line 31-32)
Add a clarifying comment:

**Before:**
```make
	else ifeq ($(ARCH), aarch64)
		MEXSUFFIX = mexa64
```

**After:**
```make
	else ifeq ($(ARCH), aarch64)
		# MATLAB uses mexa64 for ARM64 Linux (same suffix as x86_64).
		MEXSUFFIX = mexa64
```

#### 1c. Add comment about cross-platform Homebrew (line 108-110)
Add a comment explaining why `brew --prefix` is not guarded by Darwin:

**Before:**
```make
ifneq ($(BRAIDLAB_USE_GMP), 0)
	# If Homebrew installed gmp, prefer its lib/include paths
	# (Apple Silicon: /opt/homebrew)
	BREW_GMP_PREFIX := $(shell brew --prefix gmp 2>/dev/null || echo)
```

**After:**
```make
ifneq ($(BRAIDLAB_USE_GMP), 0)
	# If Homebrew installed gmp, prefer its lib/include paths.
	# Not guarded by Darwin: also supports Homebrew on Linux.
	BREW_GMP_PREFIX := $(shell brew --prefix gmp 2>/dev/null || echo)
```

#### 1d. Remove dead filter-out (lines 83-86)
Remove the no-op `filter-out` block entirely since `MEXFLAGS` never contains the filtered string:

**Remove:**
```make
# Modify MEXFLAGS to exclude unsupported flags on macOS
ifeq ($(SYS), Darwin)
	MEXFLAGS := $(filter-out LDFLAGS='-z noexecstack', $(MEXFLAGS))
endif
```

#### 1e. Replace bare `make` with `$(MAKE)` and use `-C` (lines 123-161)
Update `MAKEMEX`, `all`, `clean`, `distclean`, and `doc` targets:

**Before:**
```make
MAKEMEX = make MEX=$(MEX) MEXSUFFIX=$(MEXSUFFIX) MEXFLAGS="$(MEXFLAGS)" \
	CXX="$(CXX)" CC="$(CC)" CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
	GMP_LD="$(GMP_LD)"

.PHONY: all check-env doc clean distclean

all: check-env
	cd +braidlab/private; $(MAKEMEX) all
	cd +braidlab/+util; $(MAKEMEX) all
	cd +braidlab/@braid/private; $(MAKEMEX) all
	cd +braidlab/@loop/private; $(MAKEMEX) all
	cd +braidlab/@cfbraid/private; $(MAKEMEX) all

check-env:
ifndef MEXSUFFIX
	$(error Unknown system/architecture $(SYS)/$(ARCH))
endif

doc:
	cd doc; make

# remove MEX files and object files.
clean:
	cd extern/cbraid/lib; make clean
	cd extern/trains; make clean
	cd +braidlab/@braid/private; make clean
	cd +braidlab/@loop/private; make clean
	cd +braidlab/@cfbraid/private; make clean
	cd +braidlab/private; make clean
	cd +braidlab/+util; make clean
	cd doc; make clean

# distclean also removes the libraries (useful for recompiling on
# different OS) and the LaTeX-generated files.
distclean: clean
	rm -f extern/cbraid/lib/libcbraid-mex.a
	cd extern/trains; make distclean
	cd doc; make distclean
```

**After:**
```make
MAKEMEX_ARGS = MEX=$(MEX) MEXSUFFIX=$(MEXSUFFIX) MEXFLAGS="$(MEXFLAGS)" \
	CXX="$(CXX)" CC="$(CC)" CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
	GMP_LD="$(GMP_LD)"

# Sub-directory targets for parallel-safe builds with make -j.
# Dependencies: @braid/private and @cfbraid/private both rebuild
# libcbraid-mex.a, so they must not run concurrently.  The other three
# sub-directories are independent and can build in parallel.
SUBDIRS_INDEPENDENT = +braidlab/private +braidlab/+util +braidlab/@loop/private
SUBDIRS_CBRAID     = +braidlab/@cfbraid/private +braidlab/@braid/private

.PHONY: all check-env doc clean distclean \
	$(SUBDIRS_INDEPENDENT) $(SUBDIRS_CBRAID)

all: check-env $(SUBDIRS_INDEPENDENT) $(SUBDIRS_CBRAID)

# Independent sub-directories (safe to build in parallel).
$(SUBDIRS_INDEPENDENT):
	$(MAKE) -C $@ $(MAKEMEX_ARGS) all

# cbraid-dependent sub-directories must be serialized to avoid
# concurrent libcbraid-mex.a rebuilds.
# Force ordering: @cfbraid builds before @braid (arbitrary choice).
+braidlab/@braid/private: +braidlab/@cfbraid/private
$(SUBDIRS_CBRAID):
	$(MAKE) -C $@ $(MAKEMEX_ARGS) all

check-env:
ifndef MEXSUFFIX
	$(error Unknown system/architecture $(SYS)/$(ARCH))
endif

doc:
	$(MAKE) -C doc

# remove MEX files and object files.
clean:
	$(MAKE) -C extern/cbraid/lib clean
	$(MAKE) -C extern/trains clean
	$(MAKE) -C +braidlab/@braid/private clean
	$(MAKE) -C +braidlab/@loop/private clean
	$(MAKE) -C +braidlab/@cfbraid/private clean
	$(MAKE) -C +braidlab/private clean
	$(MAKE) -C +braidlab/+util clean
	$(MAKE) -C doc clean

# distclean also removes the libraries (useful for recompiling on
# different OS) and the LaTeX-generated files.
distclean: clean
	rm -f extern/cbraid/lib/libcbraid-mex.a
	$(MAKE) -C extern/trains distclean
	$(MAKE) -C doc distclean
```

#### 1f. Improve error for unrecognized ARCH (line 137-139)
After the architecture detection block, add a warning for known OS but unknown arch:

**Before:**
```make
check-env:
ifndef MEXSUFFIX
	$(error Unknown system/architecture $(SYS)/$(ARCH))
endif
```

**After:**
```make
check-env:
ifndef MEXSUFFIX
	$(error Unsupported system/architecture: $(SYS)/$(ARCH). \
		Supported: Linux (x86_64, aarch64, i686), \
		Darwin (x86_64, arm64), Windows/MINGW/MSYS/Cygwin (x86_64, x86))
endif
```

### 2. `+braidlab/@braid/private/Makefile`

#### 2a. Extract libcbraid-mex.a rebuild into a separate target (lines 53-58, 60-64)

**Before:**
```make
%.$(MEXSUFFIX): %.cpp
# Rebuild libcbraid-mex.a with the MEX-compatible compiler.
	cd $(CBRAID_LIBDIR); \
		make -f ../../../Makefile.cbraid-mex CXX=$(CXX) CC=$(CC)
	$(MEX) $(MEXFLAGS) $^ \
		-I$(CBRAID_INCLUDEDIR) -L$(CBRAID_LIBDIR) $(CBRAID_LD)

train_helper.$(MEXSUFFIX): train_helper.cpp
	cd $(TRAINS_DIR); \
		make CXX="$(CXX) -fPIC" CC=$(CC)
	$(MEX) $(MEXFLAGS) $^ \
		-I$(TRAINS_INCLUDEDIR) -L$(TRAINS_LIBDIR) $(TRAINS_LD)
```

**After:**
```make
# Build external libraries once as explicit prerequisites, not inside
# every pattern rule invocation.
$(CBRAID_LIBDIR)/libcbraid-mex.a:
	$(MAKE) -C $(CBRAID_LIBDIR) -f ../../../Makefile.cbraid-mex CXX=$(CXX) CC=$(CC)

$(TRAINS_LIBDIR)/libtrains.a:
	$(MAKE) -C $(TRAINS_DIR) CXX="$(CXX) -fPIC" CC=$(CC)

%.$(MEXSUFFIX): %.cpp $(CBRAID_LIBDIR)/libcbraid-mex.a
	$(MEX) $(MEXFLAGS) $< \
		-I$(CBRAID_INCLUDEDIR) -L$(CBRAID_LIBDIR) $(CBRAID_LD)

train_helper.$(MEXSUFFIX): train_helper.cpp $(TRAINS_LIBDIR)/libtrains.a
	$(MEX) $(MEXFLAGS) $< \
		-I$(TRAINS_INCLUDEDIR) -L$(TRAINS_LIBDIR) $(TRAINS_LD)
```

Note: changed `$^` to `$<` in the pattern rule since `$^` would now include the `.a` prerequisite which shouldn't be passed to `mex` as a source file.

### 3. `+braidlab/@cfbraid/private/Makefile`

#### 3a. Same libcbraid-mex.a fix (lines 50-55)

**Before:**
```make
%.$(MEXSUFFIX): %.cpp
	# Rebuild libcbraid-mex.a with the MEX-compatible compiler.
	cd $(CBRAID_LIBDIR); \
		make -f ../../../Makefile.cbraid-mex CXX=$(CXX) CC=$(CC)
	$(MEX) $(MEXFLAGS) $^ \
		-I$(CBRAID_INCLUDEDIR) -L$(CBRAID_LIBDIR) $(CBRAID_LD)
```

**After:**
```make
$(CBRAID_LIBDIR)/libcbraid-mex.a:
	$(MAKE) -C $(CBRAID_LIBDIR) -f ../../../Makefile.cbraid-mex CXX=$(CXX) CC=$(CC)

%.$(MEXSUFFIX): %.cpp $(CBRAID_LIBDIR)/libcbraid-mex.a
	$(MEX) $(MEXFLAGS) $< \
		-I$(CBRAID_INCLUDEDIR) -L$(CBRAID_LIBDIR) $(CBRAID_LD)
```

### 4. `extern/cbraid/programs/Makefile`

#### 4a. Fix hardcoded compiler (line 11)

**Before:**
```make
CPP          = g++
MAKEDEPCMD   = $(CPP)
```

**After:**
```make
CXX         ?= g++
MAKEDEPCMD   = $(CXX)
```

Also update all references to `$(CPP)` -> `$(CXX)` on lines 20, 30, 34.

### 5. `extern/trains/src/Makefile`

#### 5a. Allow CXXFLAGS override (line 19)

**Before:**
```make
CXXFLAGS = -Wall -O3 -ffast-math -fPIC
```

**After:**
```make
CXXFLAGS ?= -Wall -O3 -ffast-math -fPIC
```

### 6. `extern/trains/Makefile`

#### 6a. Replace bare `make` with `$(MAKE)` (lines 4, 7, 11, 15)

**Before:**
```make
all:
	cd src; make all
lib libtrains libtrains.a:
	cd src; make lib
clean:
	cd src; make clean
distclean:
	cd src; make distclean
```

**After:**
```make
all:
	$(MAKE) -C src all
lib libtrains libtrains.a:
	$(MAKE) -C src lib
clean:
	$(MAKE) -C src clean
distclean:
	$(MAKE) -C src distclean
```

### 7. `extern/cbraid/lib/Makefile` and `Makefile.cbraid-mex`

#### 7a. Replace bare `make` in depend targets

In both files, the `depend` target uses:
```make
depend:
	rm -f $(DEPFILE)
	make $(DEPFILE)
```

Change to:
```make
depend:
	rm -f $(DEPFILE)
	$(MAKE) $(DEPFILE)
```

### 8. `extern/cbraid/programs/Makefile`

#### 8a. Replace bare `make` calls (lines 45, 57, 62)

Change `make` to `$(MAKE)` in:
- Line 45: `cd $(CBRAID_LIBDIR); make libcbraid.a`
- Line 57: `cd $(CBRAID_LIBDIR); make clean`
- Line 62: `make $(DEPFILE)`

## Testing

After applying changes, test on Linux with:
1. `make` -- full build should succeed
2. `make -j4` -- parallel build should succeed without races
3. `make clean` -- should clean all subdirectories
4. `make distclean` -- should clean everything including libraries
5. `make BRAIDLAB_USE_GMP=0` -- GMP-disabled build
6. `make -n` -- dry run should propagate correctly to sub-makes (verifies $(MAKE) fix)
