#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

# Inject common script
source "${SDIR}/../common.sh"

INPUT_PATH="${1:-${PWD}}"
VERSION=${2:-'0.0.0'}

# Prepare folder to store packages
OUTPUT_PATH="${3:-"${PWD}/dist/${DIST}"}"
[ -d "${OUTPUT_PATH}" ] || mkdir -p "${OUTPUT_PATH}" 

PACKAGE_NAME='indy-anoncreds'
POSTINST_TMP="postinst-${PACKAGE_NAME}"
PREREM_TMP="prerm-${PACKAGE_NAME}"

pushd "${SDIR}"

./prepare-package.sh ${INPUT_PATH} ${VERSION}

# build the package

sed -i 's/{package_name}/'${PACKAGE_NAME}'/' 'postinst'
sed -i 's/{package_name}/'${PACKAGE_NAME}'/' 'prerm'

fpm --input-type 'python' \
	--output-type "${PKG_EXT}" \
	--log warn \
	--python-package-name-prefix "${PYTHON_PREFIX}" \
	--python-bin "${PYTHON}" \
	--exclude '*.pyc' \
	--exclude '*.pyo' \
	--maintainer 'Hyperledger <hyperledger-indy@lists.hyperledger.org>' \
	--after-install 'postinst' \
	--before-remove 'prerm' \
	--name "${PACKAGE_NAME}" \
	--package "${OUTPUT_PATH}" \
	"${INPUT_PATH}"

popd