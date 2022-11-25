#!/bin/bash

function usage() {
	echo "sign_image.sh ${PLATFORM} ${PRODUCT} ${BIN_DIR}"
	echo "e.g. sign_image.sh mt6880 evb6880v1_datacard [bin dir]"
	echo "sign_image.sh ${BOARD} ${PRODUCT} ${PLATFORM} ${BIN_DIR}"
	echo "e.g. sign_image.sh mt68xx evb6880v1_datacard mt6880 [bin dir]"
}

function sign() {
	echo python2.7 ${TOOL_PATH}/sign_flow.py "${PLATFORM}" "${PRODUCT}"
	PYTHONDONTWRITEBYTECODE=True PRODUCT_OUT=${PRODUCT_OUT} BOARD_AVB_ENABLE= python2.7 ${TOOL_PATH}/sign_flow.py -env_cfg ${TOOL_PATH}/env.cfg "${PLATFORM}" "${PRODUCT}"
}

if [ "$1" == "" ]; then
	usage;
	exit 1
fi
PLATFORM=$1

if [ "$2" == "" ]; then
	usage;
	exit 0
fi
PRODUCT=$2

BOARD=${PLATFORM}
if [[ $# -eq 3 ]]; then
PRODUCT_OUT=$3
fi

if [[ $# -eq 4 ]]; then
PLATFORM=$3
PRODUCT_OUT=$4
fi

TOOL_PATH=mtk/tools/common/security/tool
CONFIG_PATH=mtk/tools/common/security/config

if [ -z $PRODUCT_OUT ]; then
PRODUCT_OUT=openwrt/bin/targets/${BOARD}/${PRODUCT}
fi

sign
