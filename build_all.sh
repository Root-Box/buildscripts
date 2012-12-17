#!/bin/bash

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate="$2"
cdate=`date +"%m_%d_%Y"`
rdir=`pwd`
VERSION=`date +%Y%m%d`
RELEASE="$1"


# Build RootBox SGH-I747
make clobber;
. build/envsetup.sh;
brunch rootbox_d2att-userdebug -j12;

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

PACKAGEi747=`sed -n -e'/ro.rootbox.version/s/^.*=//' -e's/rootbox_//p' $OUT/system/build.prop`

# Move the changelog into d2att zip  & upload zip/changelog to Goo.im

if [ "$RELEASE" == "nightly" ]
then
    find "$rdir"/out/target/product -name *RootBox-JB-*${VERSION}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$rdir"/out/target/product/d2att/$PACKAGEi747.zip Bajee@upload.goo.im:~/public_html/Nightlies/d2att
else
    find "$rdir"/out/target/product -name *RootBox-JB-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$rdir"/out/target/product/d2att/$PACKAGEi747.zip Bajee@upload.goo.im:~/public_html/RootBox_d2att_jb
    scp "$rdir"/changelog_"$RB_BUILD".txt Bajee@upload.goo.im:~/public_html/RootBox_Changelogs
fi




# Build RootBox GT-I9100
make clobber;
. build/envsetup.sh;
brunch rootbox_i9100-userdebug -j12;

PACKAGEi9100=`sed -n -e'/ro.rootbox.version/s/^.*=//' -e's/rootbox_//p' $OUT/system/build.prop`

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$rdir"/out/target/product -name *RootBox-JB-*${VERSION}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$rdir"/out/target/product/i9100/$PACKAGEi9100.zip Bajee@upload.goo.im:~/public_html/Nightlies/i9100
else
    find "$rdir"/out/target/product -name *RootBox-JB-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
   scp "$rdir"/out/target/product/i9100/$PACKAGEi9100.zip Bajee@upload.goo.im:~/public_html/RootBox_i9100_jb
fi



# Build RootBox GT-I9100P
make clobber;
. build/envsetup.sh;
brunch rootbox_i9100p-userdebug -j12;

PACKAGEi9100p=`sed -n -e'/ro.rootbox.version/s/^.*=//' -e's/rootbox_//p' $OUT/system/build.prop`

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$rdir"/out/target/product -name *RootBox-JB-*${VERSION}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$rdir"/out/target/product/i9100/$PACKAGEi9100p.zip Bajee@upload.goo.im:~/public_html/Nightlies/i9100p
else
    find "$rdir"/out/target/product -name *RootBox-JB-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$rdir"/out/target/product/i9100/$PACKAGEi9100p.zip Bajee@upload.goo.im:~/public_html/RootBox_i9100p_jb
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

