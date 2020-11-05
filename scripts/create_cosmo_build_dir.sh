#!/bin/bash

USAGE="Usage: $(basename ${0}) BUILD_ROOT NAME[S]"

HELP="${USAGE}

For each NAME, create the build directory BUILD_ROOT/NAME to build the local
cosmo repository. All files and directories required for compilation are copied
except 'src/', which is symlinked.

Example:
    $(basename ${0}) \${SCRATCH}/cosmo_builds {cpu,gpu}_{dp,sp}
"

# Check command line arguments
if [ ${#} -eq 0 ]; then
    echo "${HELP}" >&2
    exit 1
elif [ ${#} -lt 2 ]; then
    echo "Error: Wrong number of arguments: ${#} < 2" >&2
    echo "${USAGE}" >&2
    exit 1
fi

# Fetch command line arguments
build_root="${1}"
shift 1
names=(${@})

# Resolve a path without an error if it does not exist yet
function realpath_noerr()
{
    local path="${1}"
    if [ "${path}" = "" ]; then
        echo "Error: missing path" >&2
        return 1
    fi
    local base="$(echo "${path}/" | \cut -d/ -f1)"
    local rest="$(echo "${path}/" | \cut -d/ -f2-)"
    echo "$(\readlink -f "${base}")/${rest}"
}

# Create a build directory
function create_build_dir()
{
    local path="$(realpath_noerr "${1}")"
    echo "${path}"

    if [ "${path}" = "" ]; then
        echo "Error: invalid path: '${path}'" >&2
        return 1
    fi

    # Check we're in the root of a cosmo repo
    local test_path="./cosmo/ACC/src"
    if [ ! -d "${test_path}" ]; then
        echo "Error: Not in root of cosmo repo: no path ${test_path}" >&2
        return 1
    fi

    # Abort of build dir already exists
    if [ -d "${path}" ]; then
        echo "Error: Build dir already exists: ${path}" >&2
        return 1
    fi

    # Copy cosmo directory (except shared)
    \mkdir -p "${path}"
    \rsync -au cosmo --exclude=cosmo/{src,test}/ --exclude=cosmo/ACC/{obj,pp}/* ${path}/

    # Symlink shared files/dirs to local repo
    local root="${PWD}"
    cd ${path}/cosmo
    ln -s "${root}/cosmo/src" .
    cd ACC
    cd "${root}"
}

# Create a build directory for each name
for name in ${names[@]}; do
    create_build_dir "${build_root}/${name}" || exit 1
done
