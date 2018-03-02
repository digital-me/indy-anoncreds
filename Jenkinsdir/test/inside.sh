#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

PYTHON="$(which 'python3.5')"
PYTHON_VER_STR="$(${PYTHON} --version)"
PYTHON_VER="${PYTHON_VER_STR##* }"
TESTONLYSLICE='1/1'

echo "Running Python (v${PYTHON_VER}) testing scripts for ${DIST}:"

while read TESTDIR; do
	RESFILE="test-result-${TESTDIR#*_}.txt"
	PYTHONASYNCIODEBUG='0' ${PYTHON} runner.py --pytest "${PYTHON} -m pytest" --dir ${TESTDIR} --output "${RESFILE}" --test-only-slice "${TESTONLYSLICE}"
done < <(ls -1d indy_*)
