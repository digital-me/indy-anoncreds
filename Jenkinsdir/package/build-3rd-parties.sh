#!/bin/bash -e

# Get the script and work dir
SDIR="$(dirname $0)"
WDIR="${PWD}"

# Inject common script
source "${SDIR}/../common.sh"

# Prepare folder to store packages
OUTPUT_PATH="${1:-"${PWD}/dist"}"
[ -d "${OUTPUT_PATH}" ] || mkdir -p "${OUTPUT_PATH}" 

# Prepare temp folder to build packages 
TDIR="$(mktemp -p /var/tmp -d fpm.XXXXXXXXXX)"
trap "rm -rf ${TDIR}" EXIT

# Define function to build Python packages from PyPi
function build_from_pypi {
	PACKAGE_NAME="$1"

	if [ "${PACKAGE_NAME}" == 'Charm-Crypto' ];
	then
		EXTRA_DEPENDENCE='-d libpbc0'
	else
		EXTRA_DEPENDENCE=''
	fi

	if [ -z "$2" ]; then
		PACKAGE_VERSION=''
	else
		PACKAGE_VERSION="==$2"
	fi
	
	POSTINST_TMP="postinst-${PACKAGE_NAME}"
	PREREM_TMP="prerm-${PACKAGE_NAME}"

	# Copy post and pre scripts in temp folder
	cp "${SDIR}/postinst" "${TDIR}/${POSTINST_TMP}"
	cp "${SDIR}/prerm" "${TDIR}/${PREREM_TMP}"

	# Enter temp folder
	pushd "${TDIR}"

	sed -i 's/{package_name}/python3-'${PACKAGE_NAME}'/' "${POSTINST_TMP}"
	sed -i 's/{package_name}/python3-'${PACKAGE_NAME}'/' "${PREREM_TMP}"

	fpm --input-type 'python' \
		--output-type "${PKG_EXT}" \
		--log warn \
		--python-package-name-prefix "${PYTHON_PREFIX}" \
		--python-bin "${PYTHON}" \
		--python-pip "${PIP}" \
		--exclude '*.pyc' \
		--exclude '*.pyo' \
		${EXTRA_DEPENDENCE} \
		--maintainer "Hyperledger <hyperledger-indy@lists.hyperledger.org>" \
		--after-install "${POSTINST_TMP}" \
		--before-remove "${PREREM_TMP}" \
		--package "${OUTPUT_PATH}" \
		"${PACKAGE_NAME}${PACKAGE_VERSION}"

	rm "${POSTINST_TMP}"
	rm "${PREREM_TMP}"

	# Exit temp folder
	popd
}

# Build and package PBC required by Charm-Crypto
pushd "${OUTPUT_PATH}"
${WDIR}/${SDIR}/../build-pbc.sh "${PKG_EXT}" '0.5.14' 'https://github.com/digital-me/pbc.git'
popd

build_from_pypi base58
build_from_pypi Charm-Crypto
