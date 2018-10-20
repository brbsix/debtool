#!/bin/bash
#
# Bump package version


error(){
    echo "$PROGRAM:ERROR: $*" >&2
    exit 1
}


info(){
    echo "$PROGRAM:INFO: $*"
}


PROGRAM=${0##*/}

APPLICATION=debtool
SCRIPT_DIRECTORY=$(readlink -m "$(dirname "$0")")

# ensure debchange is installed
hash dch &>/dev/null || {
    error "debchange is not installed... please install devscripts"
}

# enter the script directory
cd "$SCRIPT_DIRECTORY" || {
    error "Failed to cd into $SCRIPT_DIRECTORY"
}

# determine the package's current version
CURRENT_VERSION=$(awk -F= '/^VERSION=/ {gsub("[\042\047]", ""); print $2}' "$APPLICATION")

info "Package's current version number: $CURRENT_VERSION"

# prompt user for new version
read -ei "$CURRENT_VERSION" -p 'Please enter new version number: ' -r NEW_VERSION

# ensure user has entered new version
[[ -n $NEW_VERSION ]] || {
    error "Failed to set new version"
}

# update changelog
dch --controlmaint --distribution unstable --newversion "$NEW_VERSION" --urgency low || {
    error "debchange experienced an unknown error"
}

# update version strings in README.md
sed -i "s/${CURRENT_VERSION//./\\.}/$NEW_VERSION/g" README.md || {
    error "Failed to update version string in 'README.md'"
}

# update version string in application
sedstring=$(cat <<EOF
s/^\\(VERSION=['"]\\).*\\(['"]\\)$/\\1$NEW_VERSION\\2/
EOF
)

sed -i "$sedstring" "$APPLICATION" || {
    error "Failed to update version string in '$APPLICATION'"
}
