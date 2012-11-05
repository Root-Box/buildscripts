Vanilla RootBox
===============

Getting started
---------------
First you must initialize a repository with RootBox sources:

    repo init -u git://github.com/Root-Box/platform_manifest.git -b jb

then

    repo sync

*This might take a few hours depending on your internet connection.


Building Vanilla RootBox
------------------------

To build RootBox you must cd to the working directory.

Now you can run the build script:

    ./build-rootbox.sh -device- -sync- -thread-


* device: Choose between the following supported devices: i9100, i9100p, i9100g, i9300 and d2att.
* sync: Will sync latest RootBox sources before building
* threads: Allows to choose a number of threads for syncing and building operation.


ex: ./build-rootbox.sh i9100 sync 12 (This will sync latest sources, build RootBox for GT-I9100 with -j12 threads)



You might want to consider using CCACHE to speed up build time after the first build.

This will make a signed flashable zip file located in out/target/product/-device-/RootBox-JB-(Device)-Nightly-(Date).zip


