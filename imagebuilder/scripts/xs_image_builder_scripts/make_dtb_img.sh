#!/bin/bash

if [ "$1" == "" ] ;
then
	echo "FATAL:No target name"
    echo "example:"
    echo "./scripts/xs_image_builder_scripts/make_dtb_img.sh xs5g01_cpe"
	exit;
fi

target=$1

../mtk/tools/common/mkdtimg cfg_create bin/targets/gem6xxx/$target/dtb.img bin/targets/gem6xxx/$target/dtb.cfg
