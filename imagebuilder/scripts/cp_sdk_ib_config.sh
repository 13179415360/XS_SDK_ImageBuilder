#!/bin/bash

config=""
model=""

config_path=""

debug(){
    echo config="$config"
    echo model=$model
    echo openwrt=$openwrt
}

show_help(){
    echo "cp_sdk_ib_config help"
    echo "-i : build imageBuild"
    echo "-s : build SDK"
    echo "-t : model name"
    echo "example 1 : ./scripts/cp_sdk_ib_config.sh -i -s -t xs5g01_cpe"
}

check_model_path_is_exist(){
    config_path=$openwrt"/target/linux/gem6xxx/$model/target.config"

    if [[ ! -f $config_path ]]
    then
        echo "Not found $config_path"
        exit 0
    fi
}

cp_target_config(){
    cp $config_path $openwrt/.config
    echo "$config" >> $openwrt/.config
}

while getopts "ist:wh" opt; do
  case "$opt" in
    i)
        config=$config$'CONFIG_IB=y\n'$'CONFIG_IB_STANDALONE=y\n'
        ;;
    s)
        config=$config$'CONFIG_SDK=y\n'
        ;;
    t)
        model=$OPTARG
        ;;
    h)
        show_help
        exit 0
        ;;
  esac
done

if [ "`dirname "$0"`" == "." ] ;
then
    openwrt=`pwd`/..
else
    openwrt=`pwd`
fi

##debug

check_model_path_is_exist

cp_target_config

