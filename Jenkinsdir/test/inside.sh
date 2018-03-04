#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

# Inject common script
source "${SDIR}/../common.sh"

# Define global variables
TESTONLYSLICE='1/1'

echo "Running Python (v${PYTHON_VER}) testing scripts for ${DIST}:"

TESTDIR='anoncreds'
RESFILE="test-result-${TESTDIR#*_}.txt"
PYTHONASYNCIODEBUG='0' ${PYTHON} runner.py --pytest "${PYTHON} -m pytest" --dir ${TESTDIR} --output "${RESFILE}" --test-only-slice "${TESTONLYSLICE}"
