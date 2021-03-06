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
PATCH1=MIUI-enable-memory-select.patch
PATCH2=MIUI-stable-remove-sound-profiles.patch

cp "$PATCH0" "$PROJDIR"
cp "$PATCH1" "$PROJDIR"
cp "$PATCH2" "$PROJDIR"

cd "$PROJDIR"

grep -q '<perm' baseROM/system/etc/permissions/platform.xml

if [ "$?" != 0 ] ; then 
    rm -vf baseROM/system/etc/permissions/media_codecs.xml
fi

# backup services.jar
cp baseROM/system/framework/services.jar .
# decompile services.jar 
baksmali -a17 -l -b -o baseROM/system/framework/services baseROM/system/framework/services.jar

# apply patches
for PATCH in "$PATCH0" "$PATCH1" "$PATCH2" ; do
    patch -p0 < $PATCH
    if [ "$?" != 0 ] ; then
        exit 1
    fi
done

# compile services
smali -a17 -o baseROM/system/framework/classes.dex baseROM/system/framework/services
if [ "$?" != 0 ] ; then
    exit 1
fi
# pack into jar
cd baseROM/system/framework
zip -1 -r services.jar classes.dex
# cleanup
rm -rf classes.dex services 
# return to base
cd "$EXECDIR"

echo "Done. Now you should compile ROM with jBART."

