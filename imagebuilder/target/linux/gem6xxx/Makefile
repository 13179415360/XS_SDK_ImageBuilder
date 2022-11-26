# Copyright (c) 2015 OpenWrt.org
#
include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=gem6xxx
BOARDNAME:=MediaTek gem6xxx (ARM)
FEATURES:=squashfs nand ubifs
CPU_TYPE:=cortex-a55
CPU_SUBTYPE:=neon-vfpv4

LINUX_VERSION:=5.4.124
KERNEL_PATCHVER:=5.4

KERNELNAME:=Image dtbs

include $(INCLUDE_DIR)/target.mk

# Include build time checks if any
ifneq (yes,$(DISABLE_MTK_BUILD_PRECHECK))
-include $(TOPDIR)/../mtk/build/common/build_precheck.mk
-include $(TOPDIR)/../mtk/build/rules/build_precheck.mk
endif

-include $(TOPDIR)/../mtk/build/rules/build_prepare.mk

PYTHON := python2.7

define Kernel/Build/Dws
	KTREE=$(call qstrip,$(LINUX_DIR)); \
	KARCH=$(if $(filter aarch64,$(call qstrip,$(CONFIG_ARCH))),arm64,$(call qstrip,$(CONFIG_ARCH))); \
	DTS_ROOT_DIR=$$$${KTREE}/arch/$$$${KARCH}/boot/dts/mediatek; \
	DRVGEN_TOOL=$(TOPDIR)/../mtk/tools/dct/python/DrvGen.py; \
	DRVGEN_FIG=$(TOPDIR)/mtk/tools/dct/*.fig; \
	DWS_FILE="$(wildcard $(call qstrip,$(LINUX_DIR))/drivers/misc/mediatek/dws/*/*.dws)"; \
	for dws in $$$${DWS_FILE}; do \
		PROJECT=`echo $$$${dws} | sed -nr 's#.*/([^.]+)\.dws#\1#gp'`; \
		DTS_DIR=$$$${DTS_ROOT_DIR}/$$$${PROJECT}; \
		mkdir -p $$$${DTS_DIR}; \
		$(PYTHON) $$$${DRVGEN_TOOL} $$$${dws} $$$${DTS_DIR} $$$${DTS_DIR} cust_dtsi; \
	done
endef

$(eval $(call BuildTarget))
