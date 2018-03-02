#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

PYTHON="$(which 'python3.5')"
PYTHON_VER_STR="$(${PYTHON} --version)"
PYTHON_VER="${PYTHON_VER_STR##* }"

echo "Running Python (v${PYTHON_VER}) validation scripts for ${DIST}:"

${PYTHON} -m flake8
