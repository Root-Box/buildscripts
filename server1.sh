#!/bin/bash

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate="$2"
cdate=`date +"%m_%d_%Y"`
DATE=`date +"%Y%m%d"`
rdir=`pwd`
RELEASE="$1"
OFFICIAL="$3"

if [ "$RELEASE" == "official" ]
then
    echo "Building Official Release";
    export RB_BUILD="$OFFICIAL"
else
    echo "Building Nightly"
    export RB_NIGHTLY="$DATE"
fi

echo "Generating Changelog"

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
        elif [ "$origin" = "bajee" ]; then
            proj_credit=RootBox
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
    echo "Generating and Uploading Changelog for Nightly"
    cp changelog.txt changelog_"$DATE".txt
    scp "$rdir"/changelog_"$DATE".txt Bajee@upload.goo.im:~/public_html/Nightlies/Changelogs
. basket_changelog.sh $RELEASE
else
    echo "Generating and Uploading Changelog for Official Release"
    cp changelog.txt changelog_"$RB_BUILD".txt
    scp "$rdir"/changelog_"$RB_BUILD".txt Bajee@upload.goo.im:~/public_html/RootBox_Changelogs
. basket_changelog.sh $RELEASE
fi

# Build Devices on Server 1

. build_release1.sh mako "$RELEASE" "$OFFICIAL"

. build_release1.sh grouper "$RELEASE" "$OFFICIAL"

. build_release1.sh manta "$RELEASE" "$OFFICIAL"

. build_release1.sh maguro "$RELEASE" "$OFFICIAL"

. build_release1.sh toro "$RELEASE" "$OFFICIAL"

. build_release1.sh d2att "$RELEASE" "$OFFICIAL"

. build_release1.sh d2tmo "$RELEASE" "$OFFICIAL"

. build_release1.sh d2vzw "$RELEASE" "$OFFICIAL"

. build_release1.sh d2spr "$RELEASE" "$OFFICIAL"

. build_release1.sh d2usc "$RELEASE" "$OFFICIAL"

. build_release1.sh jflteatt "$RELEASE" "$OFFICIAL"

. build_release1.sh jfltecan "$RELEASE" "$OFFICIAL"

. build_release1.sh jfltespr "$RELEASE" "$OFFICIAL"

. build_release1.sh jfltetmo "$RELEASE" "$OFFICIAL"

. build_release1.sh jfltevzw "$RELEASE" "$OFFICIAL"

# Remove Changelogs
if [ "$RELEASE" == "nightly" ]
then
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$DATE".txt
else
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$RB_BUILD".txt
fi

echo "RootBox packages built, Changelog generated and everything uploaded to server!"


