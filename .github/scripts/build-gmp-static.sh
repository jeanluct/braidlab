#!/usr/bin/env bash
# Build a static, position-independent GMP (with the C++ interface) for
# linking into braidlab's MEX files (BRAIDLAB_GMP_LINKAGE=static).
#
# Usage: build-gmp-static.sh <install-prefix>
#
# Environment:
#   GMP_VERSION, GMP_SHA256   Pinned release and checksum of its .tar.xz.
#   MACOSX_DEPLOYMENT_TARGET  On macOS, the minimum macOS to target
#                             (honored by the compiler; set by the caller).
#   GMP_RUN_CHECK             If 1 (default), run GMP's own test suite.  GMP
#                             is sensitive to compiler bugs; the result is
#                             cached, so this runs rarely.
set -euo pipefail

prefix="$1"
: "${GMP_VERSION:?GMP_VERSION must be set}"
: "${GMP_SHA256:?GMP_SHA256 must be set}"
run_check="${GMP_RUN_CHECK:-1}"

tarball="gmp-${GMP_VERSION}.tar.xz"
workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT
cd "${workdir}"

# gmplib.org is known to throttle CI downloads, so try the GNU mirror
# network first.  The checksum makes the source irrelevant.
for url in "https://ftpmirror.gnu.org/gmp/${tarball}" \
           "https://ftp.gnu.org/gnu/gmp/${tarball}" \
           "https://gmplib.org/download/gmp/${tarball}"; do
  if curl -fsSL --retry 3 -o "${tarball}" "${url}"; then
    echo "Downloaded ${url}"
    break
  fi
done
test -f "${tarball}" || { echo "Could not download ${tarball}"; exit 1; }

if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "${tarball}" | cut -d' ' -f1)"
else
  actual="$(shasum -a 256 "${tarball}" | cut -d' ' -f1)"
fi
if [ "${actual}" != "${GMP_SHA256}" ]; then
  echo "Checksum mismatch for ${tarball}: got ${actual}, expected ${GMP_SHA256}"
  exit 1
fi

tar -xJf "${tarball}"
cd "gmp-${GMP_VERSION}"

configure_args=(
  "--prefix=${prefix}"
  --enable-cxx
  --enable-static
  --disable-shared
  --with-pic
)
# On x86-64, GMP's configure would otherwise tune its assembly to the
# build machine's CPU, and the result could crash on users' older CPUs.
# --enable-fat builds code for all x86-64 CPUs and picks at run time.
case "$(uname -m)" in
  x86_64|amd64) configure_args+=(--enable-fat) ;;
esac

./configure "${configure_args[@]}"
jobs="$( (command -v nproc >/dev/null && nproc) || sysctl -n hw.ncpu || echo 4)"
make -j "${jobs}"
if [ "${run_check}" = "1" ]; then
  make -j "${jobs}" check
fi
make install

# Keep the license texts with the installed library; CMake installs them
# into the package next to a README (GMP is used under GPLv3 there).
mkdir -p "${prefix}/share/licenses/gmp"
cp COPYING COPYINGv2 COPYINGv3 COPYING.LESSERv3 README "${prefix}/share/licenses/gmp/"

echo "Installed static GMP ${GMP_VERSION} into ${prefix}:"
ls -l "${prefix}/lib"
