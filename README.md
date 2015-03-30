# debtool

debtool is a wrapper around several other utilities that aims to simplify the workflow for downloading, unpacking, and repacking debian packages. It is especially handy if you just want to incorporate quick bug fixes, fix or remove unwanted package requirements, etc without the trouble of downloading sources. You can even rebuild packages that are no longer available in the apt repositories (so long as you have them installed).

Installation
------------

To install debtool on Linux systems:

    sudo install debtool /usr/local/bin
    sudo install -m 0644 debtool-completion /etc/bash_completion.d/debtool

Requirements
------------

Ensure that the following packages are installed on your system.

    apt
    dpkg
    dpkg-repack
    fakeroot

NOTE: `dpkg-repack` is only used to unpack installed packages. It is not necessary for any other actions.

Usage
-----

    Usage: debtool OPTION [ARCHIVE|DIRECTORY|PACKAGE] [TARGET]
    Manipulate debian archives.

      -b, --build           create a debian archive from DIR
      -c, --combo           download then unpack PKG(s)
      -d, --download        download PKGS(s) via apt-get
      -u, --unpack          unpack ARCHIVE or installed PKG into DIR

    NOTE: ARCHIVE refers to a '.deb' debian archive. PKG refers to program
          available to download or an installed program to unpack.

To download a debian package (from apt sources):

    debtool --download unar

You can even supply multiple package names at once if you'd like...

    debtool --download git mawk unar

To unpack a debian package:

    debtool --unpack unar_1.8.1-2_amd64.deb

To unpack to a particular directory:

    debtool --unpack unar_1.8.1-2_amd64.deb unar

You can even unpack an already installed package. If you've modified installed files, these changes will be incorporated in the directory structure:

    debtool --unpack mawk

There is also a combo command to download and unpack at the same time:

    debtool --combo git mawk unar

After you've made changes to the contents, you may rebuild the package. As part of the (re)build process, md5sums will be updated (if necessary) and any uncompressed manpages will be gzip'd. If you need to do much more than that, you should probably be using debhelper anyways.

    debtool --build PACKAGEDIR

You can specify a destination filename as follows if you'd like (otherwise the script will generate a suitable one):

    debtool --build PACKAGEDIR package.deb

License
-------

Copyright (c) 2015 Six (brbsix@gmail.com).

Licensed under the GPLv3 license.
