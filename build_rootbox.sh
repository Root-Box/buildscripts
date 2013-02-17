#!/bin/bash

# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

DEVICE="$1"
SYNC="$2"
THREADS="$3"
CLEAN="$4"

# Build Date/Version
VERSION=`date +%Y%m%d`


# Time of build startup
res1=$(date +%s.%N)

echo -e "${cya}Building ${bldcya}Vanilla RootBox Nightly-$VERSION ${txtrst}";
echo -e ""
echo -e ""
echo -e  ${bldblue}"  ____                    __    ____"                    
echo -e  " /\  _'\                 /\ \__/\  _'\ "
echo -e  " \ \ \L\ \    ___     ___\ \ ,_\ \ \L\ \    ___   __  _"
echo -e  "  \ \ ,  /   / __'\  / __'\ \ \/\ \  _ <   / __ \/\ \/'\ "
echo -e  "   \ \ \ \ \/\ \L\ \/\ \L\ \ \ \_\ \ \L\ \/\ \L\ \/>  </"
echo -e  "    \ \_\ \_\ \____/\ \____/\ \_\ \ \____/\ \____//\_/\_\ "
echo -e  "     \/_/\/ /\/___/  \/___/  \/__/ \/___/  \/___/ \//\/_/ "
echo -e

# sync with latest sources
echo -e ""
if [ "$SYNC" == "sync" ]
then
   echo -e "${bldblu}Syncing latest RootBox sources ${txtrst}"
   repo sync -j"$THREADS"
   echo -e ""
fi

# setup environment
if [ "$CLEAN" == "clean" ]
then
   echo -e "${bldblu}Cleaning up out folder ${txtrst}"
   make clobber;
else
  echo -e "${bldblu}Skipping out folder cleanup ${txtrst}"
fi


# setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

# lunch device
echo -e ""
echo -e "${bldblu}Lunching your device ${txtrst}"
lunch "rootbox_$DEVICE-userdebug";

echo -e ""
echo -e "${bldblu}Starting RootBox build for $DEVICE ${txtrst}"

# start compilation
brunch "rootbox_$DEVICE-userdebug" -j"$THREADS";
echo -e ""

# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
