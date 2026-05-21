#!/bin/bash
set -euo pipefail
BUILD_DIR=${SRC_DIR}/build

# Install the C++ runtime libraries AND the Python wrapping payload into a
# single self-contained `itk` package. ITK's wrapping install rules don't
# partition cleanly by COMPONENT, so sweep every component that may carry
# runtime or Python content.
for component in Runtime RuntimeLibraries Libraries PythonWrappingRuntimeLibraries Unspecified libraries; do
    cmake -DCOMPONENT="${component}" -P "${BUILD_DIR}/cmake_install.cmake" || true
done

# The canonical site-packages path for this Python.
PYSITE="${PREFIX}/lib/python${PY_VER}/site-packages"

# Some ITK / conda-build interactions land the wrapping payload at a truncated
# path (e.g. lib/python3.1 instead of lib/python3.12 for PY_VER=3.12) despite
# the PY_SITE_PACKAGES_PATH override. Relocate to the canonical PYSITE.
# Skip symlinked python<X> dirs (conda ships e.g. python3.1 -> python3.12).
for candidate in "${PREFIX}"/lib/python*/site-packages; do
    [ -d "${candidate}" ] || continue
    parent="$(dirname "${candidate}")"
    if [ -L "${parent}" ]; then
        echo "Skipping ${candidate} (parent is symlink: $(readlink "${parent}"))"
        continue
    fi
    if [ "${candidate}" != "${PYSITE}" ]; then
        echo "Relocating wrapping payload from ${candidate} to ${PYSITE}"
        mkdir -p "$(dirname "${PYSITE}")"
        if [ -d "${PYSITE}" ]; then
            cp -R "${candidate}/." "${PYSITE}/"
            rm -rf "${candidate}"
        else
            mv "${candidate}" "${PYSITE}"
        fi
        rmdir "${parent}" 2>/dev/null || true
    fi
done

if [ ! -d "${PYSITE}/itk" ]; then
    echo "ERROR: no itk/ Python module at ${PYSITE}" >&2
    exit 1
fi

# Headers and CMake config are not shipped in the runtime `itk` package.
# Drop anything the component sweep may have leaked into the prefix.
rm -rf "${PREFIX}/include"
rm -rf "${PREFIX}/lib/cmake"
