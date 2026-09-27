.PHONY: all lib libtrains libtrains.a clean distclean cmake-configure \
	test strict asan

BUILD_DIR ?= build
STRICT_DIR ?= build-strict
ASAN_DIR ?= build-asan
STRICT_LOG ?= strict-warnings-latest.log

all: cmake-configure
	+cmake --build $(BUILD_DIR)

# The main build always uses the legacy layout: lib/libtrains.a, src/frontend
# and src/train.
cmake-configure:
	cmake -S . -B $(BUILD_DIR) -DTRAINS_IN_TREE_OUTPUTS=ON

lib libtrains libtrains.a: cmake-configure
	+cmake --build $(BUILD_DIR) --target trains

test: all
	ctest --test-dir $(BUILD_DIR) --output-on-failure

# Clean rebuild with the strict warning set; warnings are logged to
# $(STRICT_LOG). Outputs stay inside $(STRICT_DIR).
strict:
	cmake -S . -B $(STRICT_DIR) -DTRAINS_STRICT_WARNINGS=ON
	+cmake --build $(STRICT_DIR) --target clean
	+cmake --build $(STRICT_DIR) 2>&1 | tee $(STRICT_LOG)
	@echo "Warnings: `grep -c 'warning:' $(STRICT_LOG)` (see $(STRICT_LOG))"

# Build and test with AddressSanitizer and UBSan. Outputs stay inside
# $(ASAN_DIR).
asan:
	cmake -S . -B $(ASAN_DIR) -DTRAINS_SANITIZE=ON -DTRAINS_FAST_MATH=OFF
	+cmake --build $(ASAN_DIR)
	ctest --test-dir $(ASAN_DIR) --output-on-failure

# Clean up build artifacts but keep the CMake build tree.
clean:
	+cmake --build $(BUILD_DIR) --target clean

# Clean up everything, including build directories and generated outputs.
distclean:
	rm -rf $(BUILD_DIR) $(STRICT_DIR) $(ASAN_DIR) CMakeFiles CMakeCache.txt cmake_install.cmake
	rm -f src/frontend src/train lib/libtrains.a src/*.o
