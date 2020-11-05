#!/bin/bash

USAGE="usage: $(basename ${0}) BUILD_ROOT NAME[S]"

HELP="${USAGE}

For each NAME, create a build directory at BUILD_ROOT/NAME to build the local
cosmo repository. All files and directories required for compilation are copied
except `src/`, which is symlinked.

"

# Check command line arguments
if [${#} -eq 0 ]; then
    echo "${HELP}" >&2
    exit 1
elif [ ${#} -lt 2 ]; then
    echo "error: wrong number of arguments: ${#} < 2" >&2
    echo "${USAGE}" >&2
    exit 1
fi

# Fetch command line arguments
build_root="${1}"
shift 1
names=(${@})

function create_build_dir()
{
    local path="${1}"
    echo "create build dir ${path}"
}

for name in ${names[@]}; do
    create_build_dir "${build_root}/${name}"
done
