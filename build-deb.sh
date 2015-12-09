#!/bin/bash
#
# Build debtool Debian package


error(){
    echo "${0##*/}:ERROR: $*" >&2
}


APPLICATION=debtool
BUILD_DIRECTORY=./tempdir/
BUILD_PATHS=(debian "$APPLICATION" "${APPLICATION}-completion" README.md)
SCRIPT_DIRECTORY=$(dirname "$0")
VERSION=$(awk -F= '/^VERSION=/ {gsub("[\042\047]", ""); print $2}' "$APPLICATION")


# enter the script directory
cd "$SCRIPT_DIRECTORY" || {
    error "Failed to cd into $SCRIPT_DIRECTORY"
    exit 1
}

# update changelog
dch --controlmaint --distribution unstable --newversion "$VERSION" --urgency low

# exit if debchange experienced an error
if (( $? != 0 )); then
    error "debchange experienced an unknown error"
    exit 1
fi

# create temporary build directory
mkdir -p "$BUILD_DIRECTORY"

# copy files into temporary build directory
cp -at "$BUILD_DIRECTORY" "${BUILD_PATHS[@]}"

# rename README.md to README
mv "$BUILD_DIRECTORY/README.md" "$BUILD_DIRECTORY/README"

# enter temporary build directory
cd "$BUILD_DIRECTORY" || {
    error "Failed to cd into $BUILD_DIRECTORY"
    exit 1
}

# perform build
debuild -b -uc -us

# remove temporary build directory
rm -rf "../$BUILD_DIRECTORY"
