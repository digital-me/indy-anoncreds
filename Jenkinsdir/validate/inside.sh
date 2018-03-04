#!/bin/bash -ex

# Get the script dir
SDIR="$(dirname $0)"

echo "Dist = ${DIST}"

# Inject common script
source "${SDIR}/../common.sh"

echo "Running Python (v${PYTHON_VER}) validation scripts for ${DIST}..."

${PYTHON} -m flake8

echo "Done (exit code = $?)"
