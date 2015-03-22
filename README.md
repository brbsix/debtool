# debtool

debtool is a wrapper around several other utilities that aims to simplify the workflow for downloading, unpacking, and repacking debian packages.


Installation
------------

Copy debtool to /usr/local/bin and mark as executable.
   
    ```sudo chmod a+x /usr/local/bin/debtool```

Requirements
------------

The following applications are required:

    apt
    dpkg
    fakeroot

Usage
-----

Run `debtool --help` to see all options.

    Usage: debtool OPTION [ARCHIVE|DIRECTORY|PACKAGE] [TARGET]
    Manipulate debian archives.

      -b, --build           create a debian archive from DIRECTORY
      -c, --combo           download then unpack PACKAGE (supports multiple)
      -d, --download        download PACKAGE via apt-get (supports multiple)
      -u, --unpack          unpack ARCHIVE or PACKAGE into DIRECTORY

To download a debian package (from sources):

    ```debtool --download unar```

You can even supply multiple package names at once if you'd like...

    ```debtool --download git mawk unar

To unpack the debian package:

    ```debtool --unpack unar_1.8.1-2_amd64.deb```

Or unpack the deb package to a particular directory:

    ```debtool --unpack unar_1.8.1-2_amd64.deb unar```

You can even unpack an already installed package. If you've modified installed files, these changes will be incorporated:

    ```debtool --unpack mawk```

There is also a combo command to download (from sources) and unpack at once:

    ```debtool --combo git mawk unar```

After you've made changes to the files (updating md5sums if necessary), you may rebuild the package:

    ```debtool --build PACKAGEDIR```

You can specify a destination filename as follows if you'd like (otherwise the script will generate a suitable one):

    ```debtool --build PACKAGEDIR package.deb

License
-------

Copyright (c) 2015 Six (brbsix@gmail.com).

Licensed under the GPLv3 license.
