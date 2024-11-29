#!/bin/bash

set -x

cd ${SRC_DIR}

${PYTHON} setup.py install --build-type Release -G Ninja -- \
  -DITKPythonPackage_ITK_BINARY_REUSE:BOOL=OFF \
  -DITKPythonPackage_WHEEL_NAME:STRING="itk" \
  -DBUILD_TESTING:BOOL=OFF \
  -DITK_WRAP_unsigned_short:BOOL=ON \
  -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON} \
  -DITK_WRAP_DOC:BOOL=ON
