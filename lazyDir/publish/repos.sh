#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

# Inject common script
source "${SDIR}/../common.sh"

pushd "${PWD}/dist/${DIST}"

echo "Retrieving old packages for ${DIST} from ${REPO_DEST}:"
$RSYNC ${DRY_ARG} ${RSYNC_OPTIONS} --ignore-existing "${REPO_DEST}/${DIST}" "dist/${DIST}"

case "${DIST}" in
	centos*)
		/usr/bin/createrepo --pretty --compress-type=gz .
	;;
	ubuntu*)
		/usr/bin/dpkg-scanpackages --multiversion . /dev/null | $GZIP -9c > Packages.gz
	;;
	*) # Fall-back, only if called without DIST set
	;;
esac

echo "Publishing packages for ${DIST} on ${REPO_DEST}:"
$RSYNC ${DRY_ARG} ${RSYNC_OPTIONS} --update dist/${DIST} "${REPO_DEST}"

popd
