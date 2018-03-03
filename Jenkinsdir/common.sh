#!/bin/bash -e

# Define some default value, in case the environment is not set
: ${DIST:='unknown'}

case "${DIST}" in
	centos*)
		PYTHON='/bin/python3.5'
	;;
	ubuntu*)
		PYTHON='/usr/bin/python3.5'
	;;
	*)
		PYTHON='python' # Fall-back only : should be an absolute path
	;;
esac

PYTHON_VER_STR="$(${PYTHON} --version)"
PYTHON_VER="${PYTHON_VER_STR##* }"
