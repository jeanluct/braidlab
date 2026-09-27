#!/usr/bin/env bash
# Build and stage braidlab inside a manylinux_2_28 container (AlmaLinux 8,
# glibc 2.28), so the Linux MEX files load on every distribution MATLAB
# R2024b supports.  Run from the repository root inside the container; the
# workflow bind-mounts the workspace and the host's MATLAB installation.
#
# Environment (all required):
#   MATLAB_ROOT            MATLAB installation (mounted read-only).
#   BRAIDLAB_GMP_LINKAGE   static or off.
#   CMAKE_VERSION          CMake version to use (pinned, from PyPI).
#   GCC_TOOLSET            gcc-toolset major version (within the GCC range
#                          MathWorks supports for the build release).
#   GMP_PREFIX             Where the static GMP is, or is built (cached).
#   GMP_VERSION, GMP_SHA256  Passed to build-gmp-static.sh.
#   HOST_UID, HOST_GID     Owner to give the outputs back to, since the
#                          container runs as root.
#   BUILD_PARALLEL         Build parallelism.
set -euo pipefail

: "${MATLAB_ROOT:?}" "${BRAIDLAB_GMP_LINKAGE:?}" "${CMAKE_VERSION:?}"
: "${GCC_TOOLSET:?}" "${GMP_PREFIX:?}" "${HOST_UID:?}" "${HOST_GID:?}"
parallel="${BUILD_PARALLEL:-4}"

# Pinned compiler.  gcc-toolset links newer C++ runtime pieces statically
# (libstdc++_nonshared), so the MEX files need only the system libstdc++
# of AlmaLinux 8, which every MATLAB bundles a newer version of.
dnf install -y -q "gcc-toolset-${GCC_TOOLSET}-gcc-c++" m4 xz
# shellcheck disable=SC1090
source "/opt/rh/gcc-toolset-${GCC_TOOLSET}/enable"
gcc --version | head -1
ldd --version | head -1

# Pinned CMake, independent of the image's.
/opt/python/cp312-cp312/bin/python3 -m venv /tmp/cmake-venv
/tmp/cmake-venv/bin/pip install -q "cmake==${CMAKE_VERSION}"
export PATH="/tmp/cmake-venv/bin:${PATH}"
cmake --version | head -1

cmake_args=(-S . -B build
  "-DMatlab_ROOT_DIR=${MATLAB_ROOT}"
  "-DBRAIDLAB_GMP_LINKAGE=${BRAIDLAB_GMP_LINKAGE}")
if [ "${BRAIDLAB_GMP_LINKAGE}" = "static" ]; then
  if [ ! -f "${GMP_PREFIX}/lib/libgmp.a" ]; then
    .github/scripts/build-gmp-static.sh "${GMP_PREFIX}"
  fi
  cmake_args+=("-DCMAKE_PREFIX_PATH=${GMP_PREFIX}")
fi

status=0
{
  cmake "${cmake_args[@]}" &&
  cmake --build build -j "${parallel}" &&
  cmake --install build --prefix stage
} || status=$?

# Hand the outputs back to the runner user, even after a failure, so the
# host steps (and the GMP cache) can use them.
chown -R "${HOST_UID}:${HOST_GID}" build stage "${GMP_PREFIX}" 2>/dev/null || true
exit "${status}"
