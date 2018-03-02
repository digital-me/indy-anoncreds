#!/bin/bash -e

# Define some default value, in case the environment is not set
: ${DIST:='unknown'}

case "${DIST}" in
	centos*)
		PYTHON='/bin/python3.5'
		PYTHON_PREFIX="$(rpm -q --whatprovides ${PYTHON} --queryformat '%{name}' | cut -d'-' -f1)"
		PIP='/bin/pip3.5'
		PKG_EXT='rpm'
		PKG_MNG='/usr/bin/yum'
	;;
	ubuntu*)
		PYTHON='/usr/bin/python3.5'
		PYTHON_PREFIX="$(dpkg-query --search ${PYTHON} | cut -d'-' -f1)"
		PIP='/usr/bin/pip3'
		PKG_EXT='deb'
		PKG_MNG='/usr/bin/apt-get'
	;;
	*) # Fall-back, only if called without DIST set
		[ -x '/usr/bin/which' ] || { echo "Can not found 'which'!"; exit 1; }
		PYTHON="$(which python)" 
		PYTHON_PREFIX='python'
		PIP="$(which pip)"
		which rpm &> /dev/null && PKG_EXT='rpm' || PKG_EXT='deb'
		which yum &> /dev/null && PKG_MNG="$(which yum)" || PKG_MNG="$(which apt-get)"
	;;
esac

PYTHON_VER_STR="$(${PYTHON} --version)"
PYTHON_VER="${PYTHON_VER_STR##* }"
