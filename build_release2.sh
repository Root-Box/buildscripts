#!/bin/bash

DATE=`date +"%Y%m%d"`
rdir=`pwd`
DEVICE="$1"
RELEASE="$2"
OFFICIAL="$3"
OUT=out/target/product/"$DEVICE"

if [ "$RELEASE" == "official" ]
then
    echo "Building Official Release";
    export RB_BUILD="$OFFICIAL"
else
    echo "Building Nightly"
    export RB_NIGHTLY="$DATE"
fi

echo "Removing previous build.prop"
rm out/target/product/"$DEVICE"/system/build.prop;

# setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

echo -e ""
echo -e "${bldblu}Starting RootBox build for $DEVICE ${txtrst}"

# start compilation
android-build rootbox_"$DEVICE"-userdebug;
echo -e ""

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGE=$OUT/$VERSION.zip

# Move the changelog into zip  & upload zip to Goo.im & Basketbuild.com
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-"$DEVICE"-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGE" Bajee@upload.goo.im:~/public_html/Nightlies/"$DEVICE"
    ncftpput -f login.cfg /Nightlies/"$DEVICE" "$PACKAGE"
else
    find "$OUT" -name *RootBox-JB-"$DEVICE"-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGE" Bajee@upload.goo.im:~/public_html/RootBox_"$DEVICE"_jb
    ncftpput -f login.cfg /"$DEVICE" "$PACKAGE"
fi

rm -rf out/target/product/"$DEVICE";



