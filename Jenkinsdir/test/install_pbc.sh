#!/bin/bash -xe

# Prepare temporary build folder (with auto removal upon exit)
BDIR="$(mktemp -p /var/tmp -d pbc.XXXXXXXXXX)"
trap "rm -rf ${BDIR}" EXIT

# Define default variables
: ${GIT_URL:='https://github.com/blynn/pbc.git'}
: ${GIT_REF:="${1:-'7f66331fa157d4dc587ae29cf3dac67829f4d9e3'}"} # = v0.5.14

pushd ${BDIR}
git clone "${GIT_URL}" .
git checkout ${GIT_REF}
./setup
./configure
make
make install
popd
