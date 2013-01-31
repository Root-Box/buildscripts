#!/bin/bash

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate="$2"
cdate=`date +"%m_%d_%Y"`
DATE=`date +"%Y%m%d"`
rdir=`pwd`
RELEASE="$1"
OFFICIAL="$3"

# Remove previous build info
echo "Removing previous build.prop"
rm out/target/product/d2att/system/build.prop;
rm out/target/product/d2tmo/system/build.prop;
rm out/target/product/grouper/system/build.prop;
rm out/target/product/mako/system/build.prop;
rm out/target/product/i9100/system/build.prop;
rm out/target/product/i9100g/system/build.prop;
rm out/target/product/i9300/system/build.prop;

if [ "$RELEASE" == "official" ]
then
    echo "Building Official Release";
    export RB_BUILD="$OFFICIAL"
else
    echo "Building Nightly"
fi

# Build RootBox SGH-I747
. build/envsetup.sh;
brunch rootbox_d2att-userdebug;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2att=$OUT/$VERSION1.zip

# Generate Changelog

# Check the date start range is set
if [ -z "$sdate" ]; then
    sdate=${ydate}
fi

# Find the directories to log
find $rdir -name .git | sed 's/\/.git//g' | sed 'N;$!P;$!D;$d' | while read line
do
    cd $line
    # Test to see if the repo needs to have a changelog written.
    log=$(git log --pretty="%an - %s" --no-merges --since=$sdate --date-order)
    project=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')
    if [ -z "$log" ]; then
        echo "Nothing updated on $project, skipping"
    else
        # Prepend group project ownership to each project.
        origin=`grep "$project" $rdir/.repo/manifest.xml | awk {'print $4'} | cut -f2 -d '"'`
        if [ "$origin" = "aokp" ]; then
            proj_credit=AOKP
        elif [ "$origin" = "aosp" ]; then
            proj_credit=AOSP
        elif [ "$origin" = "cm" ]; then
            proj_credit=CyanogenMod
        elif [ "$origin" = "faux" ]; then
            proj_credit=Faux123
        elif [ "$origin" = "rootbox" ]; then
            proj_credit=RootBox
        else
            proj_credit=""
        fi
        # Write the changelog
        echo "$proj_credit Project name: $project" >> "$rdir"/changelog.txt
        echo "$log" | while read line
        do
             echo "  •$line" >> "$rdir"/changelog.txt
        done
        echo "" >> "$rdir"/changelog.txt
    fi
done

# Create Version Changelog
if [ "$RELEASE" == "nightly" ]
then
    echo "Not generating version changelog for nightlies"
else
    cp changelog.txt changelog_"$RB_BUILD".txt
fi

# Move the changelog into d2att zip  & upload zip/changelog to Goo.im

if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-d2att-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" Bajee@upload.goo.im:~/public_html/Nightlies/d2att
else
    find "$rdir"/out/target/product -name *RootBox-JB-d2att-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" Bajee@upload.goo.im:~/public_html/RootBox_d2att_jb
    scp "$rdir"/changelog_"$RB_BUILD".txt Bajee@upload.goo.im:~/public_html/RootBox_Changelogs
fi

# Build RootBox SGH-T999
brunch rootbox_d2tmo-userdebug;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION2=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2tmo=$OUT/$VERSION2.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-d2tmo-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" Bajee@upload.goo.im:~/public_html/Nightlies/d2tmo
else
    find "$OUT" -name *RootBox-JB-d2tmo-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" Bajee@upload.goo.im:~/public_html/RootBox_d2tmo_jb
fi

# Build RootBox GT-I9100
brunch rootbox_i9100-userdebug;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION3=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100=$OUT/$VERSION3.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-i9100-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" Bajee@upload.goo.im:~/public_html/Nightlies/i9100
else
    find "$OUT" -name *RootBox-JB-i9100-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" Bajee@upload.goo.im:~/public_html/RootBox_i9100_jb
fi

# Build RootBox GT-I9100G
brunch rootbox_i9100g-userdebug;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION4=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100g=$OUT/$VERSION4.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-i9100g-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" Bajee@upload.goo.im:~/public_html/Nightlies/i9100g
else
    find "$OUT" -name *RootBox-JB-i9100g-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" Bajee@upload.goo.im:~/public_html/RootBox_i9100g_jb
fi

# Build RootBox GT-I9300
brunch rootbox_i9300-userdebug;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION5=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9300=$OUT/$VERSION5.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-i9300-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Bajee@upload.goo.im:~/public_html/Nightlies/i9300
else
    find "$OUT" -name *RootBox-JB-i9300-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Bajee@upload.goo.im:~/public_html/RootBox_i9300_jb
fi

# Build RootBox Grouper
brunch rootbox_grouper-userdebug;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION6=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEgrouper=$OUT/$VERSION6.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-grouper-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" Bajee@upload.goo.im:~/public_html/Nightlies/grouper
else
    find "$OUT" -name *RootBox-JB-grouper-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" Bajee@upload.goo.im:~/public_html/RootBox_grouper_jb
fi

# Build RootBox Mako (Nexus 4)
brunch rootbox_mako-userdebug;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION7=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmako=$OUT/$VERSION7.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-mako-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Bajee@upload.goo.im:~/public_html/Nightlies/mako
else
    find "$OUT" -name *RootBox-JB-mako-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Bajee@upload.goo.im:~/public_html/RootBox_mako_jb
fi


# Remove Changelogs
if [ "$RELEASE" == "nightly" ]
then
    rm "$rdir"/changelog.txt
else
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$RB_BUILD".txt
fi

echo "RootBox packages built, Changelog generated and everything uploaded to server!"


exit 0

