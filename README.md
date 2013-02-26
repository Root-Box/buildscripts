Vanilla RootBox
===============

Getting started
---------------
First you must initialize a repository with RootBox sources:

    repo init -u git://github.com/Root-Box/platform_manifest.git -b jb-mr1

then

    repo sync

*This might take a few hours depending on your internet connection.
*If you want to build for Android 4.1.2: Sync with -b jb-4.1.2

Building Vanilla RootBox
------------------------

To build RootBox you must cd to the working directory.

Now you can run the build script:

    $ . build_rootbox.sh -device- -sync- -thread- -clean-


* device: Choose between the following supported devices: i9100, i9100g, i9300, d2att, d2tmo, mako and grouper.
* sync: Will sync latest RootBox sources before building
* threads: Allows to choose a number of threads for syncing and building operation.
* clean: Will remove the entire out folder and start a clean build. (Use this at your discretion)


ex: $ . build_rootbox.sh i9100 sync 12 clean (This will sync latest sources, clean out folder, build RootBox for GT-I9100 with -j12 threads)



You might want to consider using CCACHE to speed up build time after the first build.

This will make a signed flashable zip file located in out/target/product/-device-/RootBox-JB-(Device)-Nightly-(Date).zip


