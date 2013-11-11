#!/bin/sh

# remove signature checking from android
# written by agent_007
# use jBART for decompile ROM 
# run this script
# compile ROM with jBART
# PROJDIR - jBART project directory for your ROM

if [ -z "$1" ] ; then
    echo "Example: $0 working-directory.bzproject"
    exit 1
fi

EXECDIR=$(pwd)
PROJDIR="$1"

PATCH0=lenovo_S820_services.jar-remove-check-sign.patch
PATCH1=lenovo_S820_MTK_GEMINI_3G_SWITCH.patch

cp "$PATCH0" "$PROJDIR"
cp "$PATCH1" "$PROJDIR"

cd "$PROJDIR"
# decompile 
baksmali -o baseROM/system/framework/services baseROM/system/framework/services.jar
# patch signature check
patch -p0 < "$PATCH0"
# patch MTK_GEMINI_3G_SWITCH (IMO it doesn't works)
patch -p0 < "$PATCH1"
# compile services
smali -o baseROM/system/framework/classes.dex baseROM/system/framework/services
# pack into jar
cd baseROM/system/framework
zip -1 -r services.jar classes.dex
# cleanup
rm -rf classes.dex services 
# return to base
cd "$EXECDIR"

echo "Done. Now you should compile ROM with jBART."

