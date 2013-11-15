#!/bin/sh

# script for triks with system apps that uses android.uid.phone shared UID
# written by agent_007
# use jBART for decompile ROM 
# run this script
# compile ROM with jBART
# PROJDIR - jBART project directory for your ROM
# will break the GuardProvider.apk

if [ -z "$1" ] ; then
    echo "Example: $0 working-directory.bzproject"
    exit 1
fi

PROJDIR="$1"
APKS='StkSelection.apk Phone.apk CellConnService.apk Stk1.apk TelephonyProvider.apk'

# prepare dir for apk sign trick
mkdir -p $PROJDIR/apkTricks

for NAME in $APKS ; do 
    # remove original META-INF folder
    rm -vrf "$PROJDIR/apkDecompiled/$NAME/original/META-INF"
    # copy original signed apk to new location
    cp -vf "$PROJDIR/baseROM/system/app/$NAME" "$PROJDIR/apkTricks"
    # decompile original signed apk
    apktool -f -r -p data/frameworks -o "$PROJDIR/apkTricks/${NAME%.apk}" d "$PROJDIR/apkTricks/$NAME"
    # remove META-INF folder for original decompiled apk
    rm -vrf "$PROJDIR/apkTricks/${NAME%.apk}/original/META-INF"
    # compile unsigned apk
    apktool -a data/tools/nix/aapt -p data/frameworks b "$PROJDIR/apkTricks/${NAME%.apk}"
    # sign compiled apk
    java -jar signapk.jar testkey.x509.pem testkey.pk8 "$PROJDIR/apkTricks/${NAME%.apk}/dist/$NAME" "$PROJDIR/apkTricks/${NAME%.apk}-signed.apk"
    # decompile signed apk
    apktool -f -r -p data/frameworks -o "$PROJDIR/apkTricks/${NAME%.apk}-signed" d "$PROJDIR/apkTricks/${NAME%.apk}-signed.apk"
    # copy META-INF folder from signed apk to original apk
    cp -Rvf "$PROJDIR/apkTricks/${NAME%.apk}-signed/original/META-INF" "$PROJDIR/apkDecompiled/$NAME/original"
done

echo "Done. Now you should compile ROM with jBART."

