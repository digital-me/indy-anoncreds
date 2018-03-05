#!/bin/bash -ex

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

function make_pbc {
	git clone "${GIT_URL}" .
	git checkout ${GIT_REF}
	./setup
	./configure
	make
}

# Prepare temporary build folder
# with auto removal upon exit
# and only if no environment variable defined
if [ -z "${BDIR}" -o ! -d "${BDIR}" ]; then
	BDIR="$(mktemp -p /var/tmp -d pbc.XXXXXXXXXX)"
	trap "rm -rf ${BDIR}" EXIT
fi

# Prepare directory to collect packages
WDIR="${PWD}"
[ -d "${WDIR}" ] || mkdir "${WDIR}"

pushd ${BDIR}

case "${TARGET}" in
	test)
		make_pbc
	;;
	install)
		make_pbc
		make install
	;;
	rpm)
		mkdir -p rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,TMP}
		pushd rpmbuild
		pushd SOURCES
		wget "https://github.com/digital-me/pbc/archive/${GIT_REF}.zip"
		popd
		unzip "SOURCES/${GIT_REF}.zip" -d TMP "pbc-${GIT_REF}/redhat/pbc.spec"
		mv "TMP/pbc-${GIT_REF}/redhat/pbc.spec" SPECS
		/usr/bin/rpmbuild --define "_topdir ${PWD}" --define "git_ref ${GIT_REF}" -bb SPECS/pbc.spec  
		mv RPMS/*/*.rpm "${WDIR}"
		popd
	;;
	deb)
		make_pbc
		/usr/bin/dpkg-buildpackage -uc -us
	;;
	*)
		echo "Unknown TARGET (${TARGET})" && exit 1
	;;
esac

# Exit sub-folder
popd
