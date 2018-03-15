#!/bin/bash -e

# Get the script dir
SDIR="$(dirname $0)"

# Inject common script
source "${SDIR}/../common.sh"

echo "Running Python (v${PYTHON_VER}) testing scripts for ${DIST}:"

# Prepare test(s)
: ${RUNNER:=0}								# Apparently not use very often
: ${TESTONLYSLICE='1/1'}					# Extra parameter for runner 
: ${RESDIR:='test-results'}					# Directory to collect reports
[ -d "${RESDIR}" ] || mkdir -p "${RESDIR}"	# Create it if not existing
RESFILE="${RESDIR}/${TESTDIR#*_}"			# Report path w/o extension

# Run test(s)
while read TESTDIR; do
	if [ "${RUNNER}" -eq 1 ]; then
		PYTHONASYNCIODEBUG='0' \
			${PYTHON} runner.py \
			--pytest "${PYTHON} -m pytest" \
			--dir "${TESTDIR}" \
			--output "${RESFILE}.txt" \
			--test-only-slice "${TESTONLYSLICE}"
	else
			"${PYTHON}" -m pytest \
			--color=yes \
			--junit-xml="${RESFILE}.xml" \
			${TESTDIR}
	fi
done < <(find . -maxdepth 3 -path '*/test/*' -name 'conftest.py' -print | cut -d'/' -f2)
