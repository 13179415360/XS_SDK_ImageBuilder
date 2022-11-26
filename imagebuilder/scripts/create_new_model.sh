#!/bin/bash

copy_folder(){
    echo ${FUNCNAME[0]}
    rm -rf $OPENWRT/target/linux/gem6xxx/$NEW_MODEL $MTK/package/firmware/tinysys/medmcu/project/RV33_A/mt6890/$NEW_MODEL $MTK/package/firmware/trustzone/atf/custom/build/project/custom/$NEW_MODEL $MTK/package/boot/preloader/custom/$NEW_MODEL $MTK/package/boot/lk/target/$NEW_MODEL
    cp -rf $OPENWRT/target/linux/gem6xxx/$OLD_MODEL/ $OPENWRT/target/linux/gem6xxx/$NEW_MODEL
    cp -rf $MTK/package/firmware/tinysys/medmcu/project/RV33_A/mt6890/$OLD_MODEL/ $MTK/package/firmware/tinysys/medmcu/project/RV33_A/mt6890/$NEW_MODEL
    cp -rf $MTK/package/firmware/trustzone/atf/custom/build/project/custom/$OLD_MODEL/ $MTK/package/firmware/trustzone/atf/custom/build/project/custom/$NEW_MODEL
    cp -rf $MTK/package/boot/preloader/custom/$OLD_MODEL/ $MTK/package/boot/preloader/custom/$NEW_MODEL
    cp -rf $MTK/package/boot/lk/target/$OLD_MODEL/ $MTK/package/boot/lk/target/$NEW_MODEL
    sync
}

copy_file(){
    echo ${FUNCNAME[0]}
    cp -rf $OPENWRT/target/linux/gem6xxx/files-5.4/arch/arm64/boot/dts/mediatek/$OLD_MODEL.dts $OPENWRT/target/linux/gem6xxx/files-5.4/arch/arm64/boot/dts/mediatek/$NEW_MODEL.dts
    cp -rf $OPENWRT/target/linux/gem6xxx/files-5.4/drivers/misc/mediatek/dws/mt6890/$OLD_MODEL.dws $OPENWRT/target/linux/gem6xxx/files-5.4/drivers/misc/mediatek/dws/mt6890/$NEW_MODEL.dws
    cp -rf $LINUX_5_4/arch/arm64/boot/dts/mediatek/$OLD_MODEL.dts $LINUX_5_4/arch/arm64/boot/dts/mediatek/$NEW_MODEL.dts
    cp -rf $LINUX_5_4/drivers/misc/mediatek/dws/mt6890/$OLD_MODEL.dws $LINUX_5_4/drivers/misc/mediatek/dws/mt6890/$NEW_MODEL.dws
    cp -rf $MTK/package/boot/lk/project/$OLD_MODEL.mk $MTK/package/boot/lk/project/$NEW_MODEL.mk
    mv $MTK/package/firmware/trustzone/atf/custom/build/project/custom/$NEW_MODEL/$OLD_MODEL.mk $MTK/package/firmware/trustzone/atf/custom/build/project/custom/$NEW_MODEL/$NEW_MODEL.mk
    mv $MTK/package/boot/preloader/custom/$NEW_MODEL/$OLD_MODEL.mk $MTK/package/boot/preloader/custom/$NEW_MODEL/$NEW_MODEL.mk
    sync
}

replace_content(){
    echo ${FUNCNAME[0]}
    path1="$OPENWRT/target/linux/gem6xxx/files-5.4/arch/arm64/boot/dts/mediatek/$OLD_MODEL.dts"
    path2="$OPENWRT/target/linux/gem6xxx/files-5.4/arch/arm64/boot/dts/mediatek/$NEW_MODEL.dts"
    sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2

    path1="$OPENWRT/target/linux/gem6xxx/$OLD_MODEL/target.mk"
    path2="$OPENWRT/target/linux/gem6xxx/$NEW_MODEL/target.mk"
    sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2
    sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g; s/XS5G01 CPE/'$NEW_MODEL'/g' $path1 > $path2

    path1="$OPENWRT/target/linux/gem6xxx/$OLD_MODEL/target.config"
    path2="$OPENWRT/target/linux/gem6xxx/$NEW_MODEL/target.config"
    sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2

    path1="$OPENWRT/target/linux/gem6xxx/$OLD_MODEL/device.mk"
    path2="$OPENWRT/target/linux/gem6xxx/$NEW_MODEL/device.mk"
    sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2

    path1="$LINUX_5_4/arch/arm64/boot/dts/mediatek/$OLD_MODEL.dts"
    path2="$LINUX_5_4/arch/arm64/boot/dts/mediatek/$NEW_MODEL.dts"
    sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2

    path1="$MTK/package/boot/preloader/custom/$OLD_MODEL/$OLD_MODEL.mk"
    path2="$MTK/package/boot/preloader/custom/$NEW_MODEL/$NEW_MODEL.mk"
    sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2

    path1="$MTK/package/boot/lk/project/$OLD_MODEL.mk"
    path2="$MTK/package/boot/lk/project/$NEW_MODEL.mk"
    sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2

    ##
    ## XSQUARE
    ##
    path1="$OPENWRT/target/linux/gem6xxx/$OLD_MODEL/target.docker.config"
    path2="$OPENWRT/target/linux/gem6xxx/$NEW_MODEL/target.docker.config"
    #sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2
    
    path1="$OPENWRT/target/linux/gem6xxx/$OLD_MODEL/base-files/sbin/sysupgrade"
    path2="$OPENWRT/target/linux/gem6xxx/$NEW_MODEL/base-files/sbin/sysupgrade"
    #sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2

    path1="$OPENWRT/target/linux/gem6xxx/$OLD_MODEL/target_all.config"
    path2="$OPENWRT/target/linux/gem6xxx/$NEW_MODEL/target_all.config"
    #sed 's/'$OLD_MODEL'/'$NEW_MODEL'/g' $path1 > $path2
}

add_content(){
    echo ${FUNCNAME[0]}
 
    path="$OPENWRT/target/linux/gem6xxx/patches-5.4/0301-arm64-dts-mt6890-new-dts.patch"
    new_line=`grep -n ""$OLD_MODEL".dtb" $path | cut -f1 -d:`
    new_content="dtb-\$(CONFIG_ARCH_MEDIATEK) += $NEW_MODEL.dtb"
    sed -i ''$new_line'i\'"$new_content" $path

    path="$LINUX_5_4/arch/arm64/boot/dts/mediatek/Makefile"
    new_line=`grep -n ""$OLD_MODEL".dtb" $path | cut -f1 -d:`
    new_content="dtb-\$(CONFIG_ARCH_MEDIATEK) += $NEW_MODEL.dtb"
    sed -i ''$new_line'i\'"$new_content" $path

    path="$OPENWRT/target/linux/gem6xxx/base-files/lib/preinit/99_sysinfo"
    new_line=`grep -n ","evb6890v1_64_cpe"" $path | cut -f1 -d:`
    new_content="    mediatek,"$NEW_MODEL"*)\n		model="$NEW_MODEL";\n		board="$NEW_MODEL";\n		;;"
    sed -i ''$new_line'i\'"$new_content" $path

    #path="$MTK/ext_kernel-4.19/arch/arm64/boot/dts/mediatek/Makefile"
    #new_line=`grep -n "DTC_FLAGS_"$OLD_MODEL"" $path | cut -f1 -d:`
    #new_content="DTC_FLAGS_$NEW_MODEL += -@"
    #sed -i ''$new_line'i\'"$new_content" $path
    
    #path="$OPENWRT/target/linux/mt6890/$NEW_MODEL/base-files/lib/preinit/99_sysinfo"
    #new_line=`grep -n ","$OLD_MODEL"" $path | cut -f1 -d:`
    #new_content="    mediatek,"$NEW_MODEL"*)\n		board="$NEW_MODEL";\n		;;"
    #sed -i ''$new_line'i\'"$new_content" $path

    #path="$OPENWRT/package/network/config/firewall/Makefile"
    #new_line=$((`grep -n "$OLD_MODEL" $path | cut -f1 -d:`+2))
    #new_content="else ifeq (\$(CONFIG_TARGET_mt6890_"$NEW_MODEL"""),y)\n    FIREWALL_FILE := firewall_"$NEW_MODEL".config"
    #sed -i ''$new_line'i\'"$new_content" $path

    #path="$OPENWRT/package/xsquare/xsutil/led_off.sh"
    #case_1=`grep -n "1)" $path | cut -f1 -d:`
    #case_2=`grep -n "2)" $path | cut -f1 -d:`
    #case_l=`grep -n "l)" $path | cut -f1 -d:`
    #tmp=`sed ''$case_1','$case_2'!d' $path | grep -i -n $OLD_MODEL | cut -f1 -d:`
    #new_line=$((case_1+tmp+1))
    #new_content="    elif [ \$model == $NEW_MODEL ]; then\n    gpio=9"
    #sed -i ''$new_line'i\'"$new_content" $path
    #tmp=`sed ''$case_2','$case_l'!d' $path | grep -i -n $OLD_MODEL | cut -f1 -d:`
    #new_line=$((case_2+tmp+1))
    #new_content="    elif [ \$model == $NEW_MODEL ]; then\n    gpio=10"
    #sed -i ''$new_line'i\'"$new_content" $path
}

##-------------------
##  Check model name
##-------------------
if [ "$1" == "" ] ;
then
	echo "FAIL : no new model name"
    exit
fi


##-------------------
##  Ser Parameters
##-------------------
NEW_MODEL=$1
OLD_MODEL=xs5g01_cpe
if [ "$OLD_MODEL" == "$NEW_MODEL" ] ;
then
	echo "FAIL : the new model name can't be $OLD_MODEL"
    exit
fi

if [ "`dirname "$0"`" == "." ] ;
then
    OPENWRT=`pwd`/..
else
    OPENWRT=`pwd`
fi
MTK=$OPENWRT/../mtk
LINUX_5_4=$OPENWRT/../linux-5.4


##-------------------
##  Start to create
##-------------------
echo "Old model : "$OLD_MODEL
echo "New model : "$NEW_MODEL

copy_folder
copy_file
replace_content
add_content
