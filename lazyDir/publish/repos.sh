#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

# Inject common script
source "${SDIR}/../common.sh"

echo "Publishing packages for ${DIST} on ${REPO_BASEURL}:"


pushd "${PWD}/dist/${DIST}"

case "${DIST}" in
	centos*)
		/usr/bin/createrepo --pretty --compress-type=gz .
	;;
	ubuntu*)
		/usr/bin/dpkg-scanpackages . /dev/null | $GZIP -9c > Packages.gz
	;;
	*) # Fall-back, only if called without DIST set
	;;
esac

popd
