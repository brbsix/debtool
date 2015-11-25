#!/bin/bash
#
# debtool unit tests


#/====================/#
#/  HELPER FUNCTIONS  /#
#/====================/#

# Skip remaining tests and exit
abort(){
    error "Aborting test"
    echo >&2
    exitmsg
}

# Print error message to stderr
error(){
    echo "ERROR: $*" >&2
}

existential_test(){
    local ec option

    for option in "$@"; do
        "$DEBTOOL" "$option" &>/dev/null
        ec=$?
        if (( ec == 0 )); then
            pass_test
        else
            fail_test "'$option' option exited with error code $ec"
        fi
    done
}

# Summary message to display at exit
exitmsg(){
    echo "Ran $((FAIL_COUNT + PASS_COUNT)) tests in $(printf '%.3f' "$(bc <<<"$(date +%s.%N) - $START_TIME")")s"
    echo

    if (( FAIL_COUNT > 0 )); then
        echo "FAILED (failures=$FAIL_COUNT)"
        exit 1
    else
        echo "OK"
        exit 0
    fi
}

# Report a test failure
# Usage: fail_test MESSAGE
fail_test(){
    local funcname

    funcname=${FUNCNAME[1]}
    [[ $funcname = existential_test ]] && funcname=${FUNCNAME[2]}

    ((++FAIL_COUNT))

    cat <<-EOF
	======================================================================
	FAIL: $funcname
	----------------------------------------------------------------------
	Message:
	$*

	EOF
}

# Report a test pass
# Usage: pass_test
pass_test(){
    ((++PASS_COUNT))
}

# Set up the shell environment
setup(){
    TESTDIR=$(dirname "$(readlink -e "$0" 2>/dev/null)" 2>/dev/null)
    DEBTOOL=$(readlink -e "$TESTDIR/../debtool" 2>/dev/null)
    VERSION=$(grep -oP $'(?<=^VERSION=[\'"]).+(?=[\'"]$)' "$DEBTOOL" 2>/dev/null)

    FAIL_COUNT=0
    PASS_COUNT=0

    START_TIME=$(date +%s.%N)
}


#/==============/#
#/  UNIT TESTS  /#
#/==============/#

_test_debtool_exists(){
    if [[ -x $DEBTOOL ]]; then
        pass_test
    else
        fail_test 'Unable to find debtool. Does the file exist?'
        abort
    fi
}

_test_debtool_help_option_exists(){
    existential_test -h --help
}

_test_debtool_help_option_output(){
    local option usage

    usage=$(cat <<-EOF
	Usage: debtool [OPTIONS] COMMAND ARCHIVE|DIRECTORY|PACKAGE [TARGET]
	Manipulate Debian archives.

	Commands:
	  -b, --build           create a Debian archive from DIR
	  -d, --download        download PKGS(s) via apt-get
	  -i, --interactive     download PKG interactively (select specific version)
	  -r, --reinst          reinstall ARCHIVE(s)
	      --repack          create a Debian archive from installed PKG
	  -s, --show            show PKG(s) available for download
	  -u, --unpack          unpack ARCHIVE or installed PKG into DIR

	Combination Commands:
	  -c, --combo           download and unpack PKG(s) [-adu]
	  -z, --fast            build and reinstall DIR(s) [-abrq]

	Miscellaneous Options:
	  -a, --auto            skip prompts for user input
	  -f, --format          format output of --show for manual download
	  -m, --md5sums         generate new md5sums (default is to rebuild original)
	  -q, --quiet           suppress normal output

	Some commands may be combined. Valid combinations include (but are not limited to) '--auto --download --unpack' (equivalent to --combo), '--auto --build --reinst --quiet' (equivalent to --fast), and '--build --reinst'.

	NOTE: ARCHIVE refers to a '.deb' Debian archive. PKG refers to program available to download or an installed program to unpack.
	EOF
    )

    for option in -h --help; do
        if [[ $("$DEBTOOL" "$option" 2>/dev/null) = "$usage" ]]; then
            pass_test
        else
            fail_test "'$option' option failed to match expected output"
        fi
    done
}

_test_debtool_version_exists(){
    if [[ -n $VERSION ]]; then
        pass_test
    else
        fail_test 'Failed to identify version.'
    fi
}

_test_debtool_version_option_exists(){
    existential_test -v --version
}

_test_debtool_version_option_output(){
    local option

    for option in -v --version; do
        if "$DEBTOOL" "$option" 2>/dev/null | grep -Pqz "^debtool $(sed 's/\./\\./g' <<<"$VERSION")\n\nCopyright \(c\) $(date +%Y) Six \(brbsix@gmail\.com\)$"; then
            pass_test
        else
            fail_test "'$option' option failed to match expected output"
        fi
    done
}


#/===============/#
#/  TEST RUNNER  /#
#/===============/#

runner(){
    _test_debtool_exists
    _test_debtool_version_exists

    _test_debtool_version_option_exists
    _test_debtool_version_option_output

    _test_debtool_help_option_exists
    _test_debtool_help_option_output
}


setup
runner
exitmsg
