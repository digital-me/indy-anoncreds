#!/bin/bash -e

# Get the relative dir to this script and source common bloc
SDIR="$(dirname $0)"
source "${SDIR}/common.sh" || source "${SDIR}/../common.sh"

# Call the main script to checkout and setup PBC from parent directory
source "${SDIR}/../build-pbc.sh" setup $@

# Prepare folder to store packages
: ${OUTPUT_PATH:="${PWD}/${BUILD_DIR}/${DIST}"}
[ -d "${OUTPUT_PATH}" ] || mkdir -p "${OUTPUT_PATH}"

# Define packaging steps per type of package
build_package () {
		TYPE="${1}"

		case "${TYPE}" in
			rpm)
				mkdir -p rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,TMP}
				git archive --format=zip --prefix="pbc-${GIT_REF}/" -o "rpmbuild/SOURCES/${GIT_REF}.zip" "${GIT_REF}"
				cp redhat/libpbc.spec rpmbuild/SPECS
				pushd rpmbuild
				/usr/bin/rpmbuild --quiet --define "_topdir ${PWD}" --define "_git_ref ${GIT_REF}" -bb SPECS/libpbc.spec
				mv RPMS/*/*.rpm "${OUTPUT_PATH}"
				popd
			;;
			deb)
				echo "Packaging in ${PWD}:"
				/usr/bin/dpkg-buildpackage -b -uc -us > /dev/null
				rm -f ../libpbc_*.changes	# Avoid polluting working dir
				mv ../*.deb "${OUTPUT_PATH}"
			;;
			*)
				echo "Unknown package type (${TYPE})" && exit 1
			;;
		esac
}

# Re-enter build dir
pushd "${BDIR}"

case "${DIST}" in
	centos*|redhat*|fedora*)
		build_package rpm
	;;
	ubuntu*|debian*)
		build_package deb
	;;
esac

# Exit build dir
popd

