#!/bin/bash

##-------------------
##  Set Common revision
##-------------------
TITLE="XS."
VERSION=".01.01.10"


##-------------------
##  Set WIFI Name
##-------------------
if [ "`dirname "$0"`" == "." ] ;
then
    OPENWRT=`pwd`/..
else
    OPENWRT=`pwd`
fi

#if [ ! -z "`cat $OPENWRT/.config | grep 'MT7915D' | awk -F'"' '{print $2}'`" ]; then
#    WIFI=".MT7915D"
#fi

##TARGET_NAME=`cat .config | grep "_Default=y" | awk -F'_Default=y' '{print $1}' | awk -F'gem6xxx_' '{print $2}' | tr '[:lower:]' '[:upper:]'`
TARGET_NAME=`cat .config | grep "PROFILE=" | awk -F'"' '{printf $2}' | awk -F'xs5g01_' '{print $2}' | tr '[:lower:]' '[:upper:]'`

##-------------------
##  Set revision
##-------------------
REVISION=$TITLE$TARGET_NAME$WIFI$VERSION
echo $REVISION
