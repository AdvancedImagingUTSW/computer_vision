#!/bin/bash
unset MACOSX_DEPLOYMENT_TARGET
${PYTHON} setup.py install;
cp lib/libMicrovolution.so ${SP_DIR}/../..;
