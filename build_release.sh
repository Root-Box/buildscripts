#!/bin/bash

DATE=`date +"%Y%m%d"`
rdir=`pwd`
DEVICE="$1"
RELEASE="$2"
OFFICIAL="$3"

if [ "$RELEASE" == "official" ]
then
    echo "Building Official Release";
    export RB_BUILD="$OFFICIAL"
else
    echo "Building Nightly"
fi

echo "Removing previous build.prop"
rm out/target/product/"$DEVICE"/system/build.prop;

# setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

echo -e ""
echo -e "${bldblu}Starting RootBox build for $DEVICE ${txtrst}"

# start compilation
brunch "$DEVICE";
echo -e ""

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGE=$OUT/$VERSION.zip

# Export some stuff for the basket script
export DEVICE="$DEVICE"
export PACKAGE="$PACKAGE"
export VERSION="$VERSION"

# Move the changelog into zip  & upload zip to Goo.im & Basketbuild.com
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-"$DEVICE"-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGE" Bajee@upload.goo.im:~/public_html/Nightlies/"$DEVICE"
. basket_upload.sh "$RELEASE"
else
    find "$OUT" -name *RootBox-JB-"$DEVICE"-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGE" Bajee@upload.goo.im:~/public_html/RootBox_"$DEVICE"_jb
. basket_upload.sh "$RELEASE"
fi

if [ "$DEVICE" == "mako" ]
then
    echo "Not removing Mako"
else
    rm -rf out/target/product/"$DEVICE";
fi



