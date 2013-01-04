#!/bin/bash

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate="$1"
cdate=`date +"%m_%d_%Y"`
rdir=`pwd`


# Build AOKP SGH-I747
. build/envsetup.sh;
brunch aokp_d2att-userdebug;

# Get Package Name
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
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
            proj_credit=Bajee11
        elif [ "$origin" = "bajee" ]; then
            proj_credit=Baje11
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

# Make changelog copy
cp changelog.txt Changelog_"$cdate".txt

# Upload changelog to Andro and Goo
scp "$rdir"/Changelog_$cdate.txt bajee11@exynos.co:~/AOKP_Changelog
scp "$rdir"/Changelog_$cdate.txt aokp_s2@upload.goo.im:~/public_html/Nightlies/Changelogs

# Upload zip to Andro and Goo
find "$OUT" -name *aokp_d2att_unofficial*.zip -exec zip -j {} "$rdir"/changelog.txt \;
scp "$PACKAGEd2att" bajee11@exynos.co:~/AOKP_d2att_NIGHTLIES
scp "$PACKAGEd2att" aokp_s2@upload.goo.im:~/public_html/Nightlies/d2att


# Build AOKP GT-I9100
. build/envsetup.sh;
brunch aokp_i9100-userdebug;

# Get Package Name
find "$OUT" -name *aokp_i9100_unofficial*.zip -exec zip -j {} "$rdir"/changelog.txt \;
VERSION2=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100=$OUT/$VERSION2.zip

# Upload package to Andro and Goo
scp "$PACKAGEi9100" bajee11@exynos.co:~/AOKP_i9100_NIGHTLIES
scp "$PACKAGEi9100" aokp_s2@upload.goo.im:~/public_html/Nightlies/i9100

# Build RootBox GT-I9100G
. build/envsetup.sh;
brunch aokp_i9100g-userdebug;

# Get Package Name
find "$OUT" -name *aokp_i9100g_unofficial*.zip -exec zip -j {} "$rdir"/changelog.txt \;
VERSION3=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100g=$OUT/$VERSION3.zip

# Upload package to Andro
scp "$PACKAGEi9100g" bajee11@exynos.co:~/AOKP_i9100g_NIGHTLIES
scp "$PACKAGEi9100g" aokp_s2@upload.goo.im:~/public_html/Nightlies/i9100g


# Build RootBox GT-I9300
. build/envsetup.sh;
brunch aokp_i9300-userdebug;

# Get Package Name
find "$OUT" -name *aokp_i9300_unofficial*.zip -exec zip -j {} "$rdir"/changelog.txt \;
VERSION4=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9300=$OUT/$VERSION4.zip

# Upload package to Andro
scp "$PACKAGEi9300" bajee11@exynos.co:~/AOKP_i9300_NIGHTLIES
scp "$PACKAGEi9300" aokp_s2@upload.goo.im:~/public_html/Nightlies/i9300

# Remove Changelogs
rm "$rdir"/changelog.txt
rm "$rdir"/Changelog_$cdate.txt

echo "AOKP packages built, Changelog generated and everything uploaded to server!"


exit 0

