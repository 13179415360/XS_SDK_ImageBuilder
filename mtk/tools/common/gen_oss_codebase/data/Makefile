# Copyright (c) 2015 OpenWrt.org
#
include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=mt6880
BOARDNAME:=MediaTek mt6880 (ARM)
FEATURES:=squashfs nand ubifs
CPU_TYPE:=cortex-a55
CPU_SUBTYPE:=neon-vfpv4
MAINTAINER:=John Crispin <john@phrozen.org>

LINUX_VERSION:=4.19.98
KERNEL_PATCHVER:=4.19

KERNELNAME:=Image dtbs

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += vendor_info

# Include build time checks if any
ifneq (yes,$(DISABLE_MTK_BUILD_PRECHECK))
-include $(TOPDIR)/../mtk/build/common/build_precheck.mk
-include $(TOPDIR)/../mtk/build/rules/build_precheck.mk
endif

ifneq (,$(wildcard $(TOPDIR)/../mtk/tools/dct/python))
define Kernel/Prepare/Post
	KTREE=$(call qstrip,$(CONFIG_EXTERNAL_KERNEL_TREE)); \
	KARCH=$(if $(filter aarch64,$(call qstrip,$(CONFIG_ARCH))),arm64,$(call qstrip,$(CONFIG_ARCH))); \
	DTS_ROOT_DIR=$$$${KTREE}/arch/$$$${KARCH}/boot/dts/mediatek; \
	DRVGEN_TOOL=$(TOPDIR)/../mtk/tools/dct/python/DrvGen.py; \
	DRVGEN_FIG=$(TOPDIR)/mtk/tools/dct/*.fig; \
	DWS_FILE="$(wildcard $(call qstrip,$(CONFIG_EXTERNAL_KERNEL_TREE))/drivers/misc/mediatek/dws/*/*.dws)"; \
	for dws in $$$${DWS_FILE}; do \
		PROJECT=`echo $$$${dws} | sed -nr 's#.*/([^.]+)\.dws#\1#gp'`; \
		DTS_DIR=$$$${DTS_ROOT_DIR}/$$$${PROJECT}; \
		mkdir -p $$$${DTS_DIR}; \
		python $$$${DRVGEN_TOOL} $$$${dws} $$$${DTS_DIR} $$$${DTS_DIR} cust_dtsi; \
	done
endef
endif

$(eval $(call BuildTarget))

