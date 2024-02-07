#!/bin/bash

# install using pip from the whl files on PyPI

POST=""
PYPI_VER="${PY_VER:0:1}${PY_VER:2:3}"

for DEP_PACKAGE in core io filtering numerics registration segmentation; do
  if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "3.8" -o "$PY_VER" == "3.9" -o "$PY_VER" == "3.10" -o "$PY_VER" == "3.11" -o "$PY_VER" == "3.12" ]; then
      WHL_FILE=https://pypi.org/packages/cp${PYPI_VER}/i/itk-${DEP_PACKAGE}/itk_${DEP_PACKAGE}-${PKG_VERSION}${POST}-cp${PYPI_VER}-cp${PYPI_VER}-macosx_10_9_x86_64.whl
    else
      WHL_FILE=https://pypi.org/packages/cp${PYPI_VER}/i/itk-${DEP_PACKAGE}/itk_${DEP_PACKAGE}-${PKG_VERSION}${POST}-cp${PYPI_VER}-cp${PYPI_VER}m-macosx_10_9_x86_64.whl
    fi
  fi

  if [ `uname` == Linux ]; then
      if [ "$PY_VER" == "3.8" -o "$PY_VER" == "3.9" -o "$PY_VER" == "3.10" -o "$PY_VER" == "3.11" -o "$PY_VER" == "3.12" ]; then
          WHL_FILE=https://pypi.org/packages/cp${PYPI_VER}/i/itk-${DEP_PACKAGE}/itk_${DEP_PACKAGE}-${PKG_VERSION}${POST}-cp${PYPI_VER}-cp${PYPI_VER}-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
      else
          WHL_FILE=https://pypi.org/packages/cp${PYPI_VER}/i/itk-${DEP_PACKAGE}/itk_${DEP_PACKAGE}-${PKG_VERSION}${POST}-cp${PYPI_VER}-cp${PYPI_VER}m-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
      fi
  fi
  pip install --no-deps $WHL_FILE
done
