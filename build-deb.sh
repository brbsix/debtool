#!/bin/bash
#
# Build debtool Debian package


fatal(){
    echo "$PROGRAM:FATAL: $*" >&2
    exit 1
}


warning(){
    echo "$PROGRAM:WARNING: $*" >&2
}


set -eo pipefail

PROGRAM=${0##*/}
APPLICATION=debtool
SCRIPT_DIRECTORY=$(readlink -m "$(dirname "$0")")
TEMP_DIRECTORY=$SCRIPT_DIRECTORY/temp_dir
BUILD_DIRECTORY=$TEMP_DIRECTORY/build_dir
BUILD_PATHS=(debian "$APPLICATION" "${APPLICATION}-completion" README.md)
VERSION=$(awk -F= '/^VERSION=/ {gsub("[\042\047]", ""); print $2}' "$APPLICATION")
KEEP_FILES=0

if (( $# == 1 )) && [[ $1 =~ ^(-k|--keep(-files)?)$ ]]; then
    KEEP_FILES=1
elif (( $# != 0 )); then
    cat <<-EOF
	Usage: $PROGRAM [-k|--keep-files]
	Build a Debian package.

	  -k, --keep-files       DO NOT remove build files after build

	Build details:

	  APPLICATION=$APPLICATION
	  VERSION=$VERSION

	  SCRIPT_DIRECTORY=$SCRIPT_DIRECTORY
	  TEMP_DIRECTORY=$TEMP_DIRECTORY
	  BUILD_DIRECTORY=$BUILD_DIRECTORY
	  BUILD_PATHS=${BUILD_PATHS[*]}

	EOF
    exit 0
fi

# enter the script directory
cd "$SCRIPT_DIRECTORY" || {
    fatal "Failed to cd into '$SCRIPT_DIRECTORY'"
}

# ensure temp directory does not already exist
if [[ -d $TEMP_DIRECTORY ]]; then
    fatal "Temporary directory '$TEMP_DIRECTORY' already exists. Remove it before continuing."
fi

# create temp directory and build directory
mkdir -p "$BUILD_DIRECTORY" || {
    fatal "Failed to create '$BUILD_DIRECTORY'"
}

# copy paths into build directory
cp -at "$BUILD_DIRECTORY" "${BUILD_PATHS[@]}" || {
    fatal 'Failed to copy paths into build directory'
}

# rename README.md to README
mv "$BUILD_DIRECTORY/README.md" "$BUILD_DIRECTORY/README"

# enter the build directory
cd "$BUILD_DIRECTORY" || {
    fatal "Failed to cd into '$BUILD_DIRECTORY'"
}

# perform build and warn upon failure
debuild -b -uc -us || {
    warning "debuild returned a nonzero exit code [$EC]"
}

# enter the temp directory containing .deb and logs
cd "$TEMP_DIRECTORY" || {
    fatal "Failed to cd into '$TEMP_DIRECTORY'"
}

# move .deb into the root directory
mv ./*.deb "$SCRIPT_DIRECTORY" || {
    fatal "Failed to move .deb into '$SCRIPT_DIRECTORY'"
}

# optionally exit before removing build files
(( KEEP_FILES == 1 )) && exit 0

# return to the script directory
cd "$SCRIPT_DIRECTORY" || {
    fatal "Failed to cd back into '$SCRIPT_DIRECTORY'"
}

# remove the temp directory
rm -rf "$TEMP_DIRECTORY"
