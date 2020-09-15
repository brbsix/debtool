# debtool

[![GitHub release](https://img.shields.io/github/release/brbsix/debtool.svg)](https://github.com/brbsix/debtool/releases/latest)
[![Build Status](https://travis-ci.org/brbsix/debtool.svg?branch=master)](https://travis-ci.org/brbsix/debtool)

`debtool` is a wrapper around several other utilities that aims to simplify the workflow for downloading, unpacking, repacking, and reinstalling Debian packages. It is especially handy if you want to download *.deb* files, incorporate quick bug fixes, alter package requirements, et cetera without the trouble of building from sources. You can even rebuild packages that are no longer available from your apt repositories (so long as you have them installed).

As with all of my programs, feel free to let me know if you have any feedback or encounter any issues.

## Installation

To install `debtool` via Debian archive:

    curl -LOsS https://github.com/brbsix/debtool/releases/download/v0.2.5/debtool_0.2.5_all.deb
    sudo dpkg --install debtool_0.2.5_all.deb
    sudo apt-get install --fix-broken  # install fakeroot dependency

To install `debtool` from git repository:

    git clone https://github.com/brbsix/debtool
    cd debtool/
    sudo install debtool /usr/local/bin
    sudo install -m 0644 debtool-completion /etc/bash_completion.d/debtool

## Requirements

Ensure that the following package is installed on your system:

    fakeroot

It is recommended that you have the following installed on your system:

    bash-completion
    perl  # only necessary to unpack or repack installed packages

Other required packages that are most likely already installed on your system:

    apt
    awk
    coreutils
    dpkg
    findutils
    grep
    gzip

## Usage

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

### Showing Packages

To show the versions and architectures of packages available for download (e.g. `gawk 1:4.0.1+dfsg-2.1ubuntu2 amd64`):

    debtool --show PACKAGE

To show the versions and achitectures of packages available for download, formatted for manual installation (e.g. `apt-get download gawk:amd64=1:4.0.1+dfsg-2.1ubuntu2`):

    debtool --show --format PACKAGE

### Downloading Packages

To download a Debian package (from apt sources):

    debtool --download unar

To download a specific version of a Debian package:

    debtool --download gdebi=0.9.5.3ubuntu2

To download a specific architecture and version of a Debian package:

    debtool --download unar:amd64=1.8.1-2

You can even supply multiple package names at once if you'd like...

    debtool --download git mawk unar

To download a package interactively and select from multiple versions:

    debtool --interactive git

### Unpacking Packages

To unpack a Debian package:

    debtool --unpack unar_1.8.1-2_amd64.deb

To unpack to a particular directory:

    debtool --unpack unar_1.8.1-2_amd64.deb unar

You can even unpack an already installed package. If you've modified installed files, these changes will be incorporated into the directory structure:

    debtool --unpack mawk

### Rebuilding Packages

After you've made changes to the directory contents, you may rebuild the package. As part of the (re)build process, md5sums will be updated (if necessary) and any uncompressed manpages will be gzip'd. If you need to do much more than that, you should probably be using debhelper anyways.

    debtool --build DIRECTORY

You can specify a destination filename as follows if you'd like (otherwise the script will generate a suitable one):

    debtool --build DIRECTORY package.deb

During normal build operations, `debtool` simply updates md5sums, using the pre-existing file as a template. However, if new files are added to the package (or if the md5sums file is missing) you will want to use the `--md5sums` option during build to generate md5sums from scratch.

    debtool --build --md5sums DIRECTORY

After you've made changes, you can rapidly reinstall (purge then install) the indicated archive:

    debtool --reinst ARCHIVE

### Repack Installed Package

You can even repack an already installed package. This is convenient when an installed package is no longer available for download. If you've modified installed files, these changes will be incorporated into the Debian archive:

    debtool --repack mawk

### Combination Commands

Some commands may be combined. Valid combinations include '--download --unpack', `--interactive --unpack`, and '--build --reinst'.

    debtool -du git mawk unar
    debtool -iu PACKAGES
    debtool -br DIRECTORY

Use the combo command (equivalent to `--auto --download --unpack`) to download and unpack at the same time:

    debtool --combo PACKAGES

Use the fast command (equivalent to `--auto --build --reinst --quiet`) to build and reinstall at the same time:

    debtool --fast DIRECTORY

## Development

To run tests (note that [Travis CI](https://travis-ci.org/brbsix/debtool) runs tests upon push):

`make test`

To create a new release, ensure you have **devscripts** installed then run the following:

1. Bump version and increment changelog with `./bump-version.sh`
2. Commit the changes
3. Build the *.deb* with `make deb`
5. Tag the release (e.g. `git tag v0.0.1`)
6. Push the release (e.g. `git push origin master v0.0.1` or `git push origin master --tags`)
7. Attach the *.deb* package to the release via GitHub's web interface (this keeps builds out of the repo history)

## License

Copyright (c) 2015-2020 Six <brbsix@gmail.com>

Licensed under the GPLv3 license.

## Additional Notes

`debtool` uses a modified version of `dpkg-repack` to unpack and repack already installed packages.

Copyright (c) 1996-2006 Joey Hess <joeyh@debian.org>

Copyright (c) 2012, 2014-2015 Guillem Jover <guillem@debian.org>
