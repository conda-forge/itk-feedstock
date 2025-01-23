#!/bin/bash

# ITK 5.4.0 pypi wheels are cp311 only with ABI3 compatibility
PYPI_VER="311"
# ITK_VERSION is taken from the conda package version environment variable
ITK_VERSION=${PKG_VERSION}

# List of ITK modules to install (since ITK itself is a meta package)
ITK_MODULES=(
  "core"
  "io"
  "filtering"
  "numerics"
  "registration"
  "segmentation"
)

# Determine platform/architecture wheel tags
OS_NAME="$(uname)"
ARCH_NAME="$(arch)"

# Decide on the wheel pattern to match
# (Note: for macOS/arm64 wheels, pypi seems to use "macosx_11_0_arm64"
#        for macOS/x86_64 wheels, it seems to be "macosx_10_9_x86_64"
#        for Linux, "manylinux_2_28_x86_64" or "manylinux_2_28_aarch64".)
if [ "$OS_NAME" = "Darwin" ]; then
  # macOS
  if [ "$ARCH_NAME" = "arm64" ]; then
    PLATFORM_GREP="macosx.*arm64.whl"
  else
    PLATFORM_GREP="macosx.*x86_64.whl"
  fi
else
  # Assume Linux if not Darwin
  # pypi wheels seem to use 'aarch64' for arm64 on Linux
  if [ "$ARCH_NAME" = "arm64" ] || [ "$ARCH_NAME" = "aarch64" ]; then
    PLATFORM_GREP="manylinux_2_28_aarch64.whl"
  else
    PLATFORM_GREP="manylinux_2_28_x86_64.whl"
  fi
fi

# Loop over each ITK module, find the wheel URL, and install it
for DEP_PACKAGE in "${ITK_MODULES[@]}"; do
  echo "Processing itk-${DEP_PACKAGE}..."

  # Retrieve a list of URLs for the specified release version
  URLS=$(curl -s "https://pypi.org/pypi/itk-${DEP_PACKAGE}/json" | \
         jq -r ".releases[\"${ITK_VERSION}\"][] | .url")

  echo "Found Candidate URLs:"
  echo "$URLS"
  # Find the URL that matches both "cp${PYPI_VER}" and the target platform (OS/arch)
  MATCHED_URL=$(echo "$URLS" \
                | grep "cp${PYPI_VER}" \
                | grep -E "$PLATFORM_GREP" \
                | head -n 1)

  if [ -z "$MATCHED_URL" ]; then
    echo "No matching wheel found for itk-${DEP_PACKAGE}, Python cp${PYPI_VER}, and platform $PLATFORM_GREP"
    exit 1
  fi

  echo "Matched URL for itk-${DEP_PACKAGE}: $MATCHED_URL"

  # Install the matched wheel file without dependencies
  pip install --no-deps "$MATCHED_URL"
done

echo "All specified ITK modules have been installed successfully."