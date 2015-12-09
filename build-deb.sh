#!/bin/bash
#
# Build debtool Debian package


error(){
    echo "$PROGRAM:ERROR: $*" >&2
    exit 1
}


warning(){
    echo "$PROGRAM:WARNING: $*" >&2
}


PROGRAM=${0##*/}

APPLICATION=debtool
SCRIPT_DIRECTORY=$(realpath "$(dirname "$0")")
TEMP_DIRECTORY=$SCRIPT_DIRECTORY/temp_dir
BUILD_DIRECTORY=$TEMP_DIRECTORY/build_dir
BUILD_PATHS=(debian "$APPLICATION" "${APPLICATION}-completion" README.md)
VERSION=$(awk -F= '/^VERSION=/ {gsub("[\042\047]", ""); print $2}' "$APPLICATION")

DEVELOPMENT=0

if (( $# == 1 )) && [[ $1 =~ ^(-d|--dev(elopment)?)$ ]]; then
    DEVELOPMENT=1
elif (( $# != 0 )); then
    cat <<-EOF
	Usage: $PROGRAM [-d|--development]
	Build a Debian package.

	  -d, --development      DO NOT remove build files after build

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
    error "Failed to cd into $SCRIPT_DIRECTORY"
}

# ensure temp directory does not already exist
if [[ -d $TEMP_DIRECTORY ]]; then
    error "Temporary directory '$TEMP_DIRECTORY' already exists... Remove it before continuing."
fi

# update changelog
dch --controlmaint --distribution unstable --newversion "$VERSION" --urgency low

# exit upon debchange error
if (( $? != 0 )); then
    error "debchange experienced an unknown error"
fi

# create temp directory and build directory
mkdir -p "$BUILD_DIRECTORY" || {
    error "Failed to create $BUILD_DIRECTORY"
}

# copy paths into build directory
cp -at "$BUILD_DIRECTORY" "${BUILD_PATHS[@]}" || {
    error "Failed to copy paths into build directory"
}

# rename README.md to README
mv "$BUILD_DIRECTORY/README.md" "$BUILD_DIRECTORY/README"

# enter the build directory
cd "$BUILD_DIRECTORY" || {
    error "Failed to cd into $BUILD_DIRECTORY"
}

# perform build
debuild -b -uc -us

# warn upon debuild failure
if (( $? != 0 )); then
    warning "debuild returned a nonzero exit code"
fi

# enter the temp directory containing .deb and logs
cd "$TEMP_DIRECTORY" || {
    error "Failed to cd into $TEMP_DIRECTORY"
}

# move .deb into the root directory
mv ./*.deb "$SCRIPT_DIRECTORY" || {
    error "Failed to move .deb into $SCRIPT_DIRECTORY"
}

# exit before removing build files if dev mode is enabled
(( DEVELOPMENT == 1 )) && exit 0

# return to the script directory
cd "$SCRIPT_DIRECTORY" || {
    error "Failed to cd back into $SCRIPT_DIRECTORY"
}

# remove the temp directory
rm -rf "$TEMP_DIRECTORY"
