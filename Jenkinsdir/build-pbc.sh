#!/bin/bash -e

# Define variables and parameters
: ${TARGET:="${1:-test}"}
: ${GIT_URL:="${3:-https://github.com/blynn/pbc.git}"}

# Map version to GIT ref if required
case "$2" in
	'')
	# Use a specific commit to package on Ubuntu
		GIT_REF='656ae0c90e120eacd3dc0d76dbc9504f8aca4ba8'
	;;
	*)
		GIT_REF="$2"
	;;
esac

# Prepare temporary build folder
# with auto removal upon exit
# and only if no environment variable defined
if [ -z "${BDIR}" -o ! -d "${BDIR}" ]; then
	BDIR="$(mktemp -p /var/tmp -d pbc.XXXXXXXXXX)"
	trap "rm -rf ${BDIR}" EXIT
fi

# Save working directory to collect packages later
WDIR="${PWD}"

# Download source code
git clone "${GIT_URL}" "${BDIR}"
# Enter build dir
pushd "${BDIR}"
# Prepare working dir
git checkout "${GIT_REF}"
./setup > /dev/null

case "${TARGET}" in
	test)
		./configure
		make
	;;
	install)
		./configure --silent
		make --silent > /dev/null
		make --silent install > /dev/null
		/sbin/ldconfig
	;;
	rpm)
		mkdir -p rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,TMP}
		git archive --format=zip --prefix="pbc-${GIT_REF}/" -o "rpmbuild/SOURCES/${GIT_REF}.zip" "${GIT_REF}"
		cp redhat/pbc.spec rpmbuild/SPECS
		pushd rpmbuild
		/usr/bin/rpmbuild --quiet --define "_topdir ${PWD}" --define "git_ref ${GIT_REF}" -bb SPECS/pbc.spec
		mv RPMS/*/*.rpm "${WDIR}"
		popd
	;;
	deb)
		echo "Packaging in ${PWD}:"
		/usr/bin/dpkg-buildpackage -b -uc -us > /dev/null
		rm -f ../libpbc_*.changes	# Avoid polluting working dir
		mv ../*.deb "${WDIR}"
	;;
	*)
		echo "Unknown TARGET (${TARGET})" && exit 1
	;;
esac

# Exit build dir
popd
