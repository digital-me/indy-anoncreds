#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

# Inject common script from stage dir or parent dir
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

echo "Running Python (v${PYTHON_VER}) validation scripts for ${DIST}..."

${PYTHON} -m flake8

echo "Done (exit code = $?)"
