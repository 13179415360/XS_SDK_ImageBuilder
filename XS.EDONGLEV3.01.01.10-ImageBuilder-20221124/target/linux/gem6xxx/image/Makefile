# Copyright (c) 2014 The Linux Foundation. All rights reserved.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

include $(TOPDIR)/../mtk/build/common/image-commands.mk

ifneq (yes,$(DISABLE_MTK_BUILD_POSTCHECK))
  -include $(TOPDIR)/../mtk/build/rules/build_postcheck.mk
endif

DEFAULT_DEVICE_PACKAGES := libpam preloader lk atf spmfw sspm mcupm dpm mddb_installer vendor_info
MT6880_DEFAULT_PACKAGES := $(DEFAULT_DEVICE_PACKAGES)
MT6890_DEFAULT_PACKAGES := $(DEFAULT_DEVICE_PACKAGES) medmcu
DEVICE_PACKAGES_DEBUG := \
	$(if $(wildcard $(TOPDIR)/../mtk/package/utils/ioctlfuzzer),ioctlfuzzer) \
	$(if $(wildcard $(TOPDIR)/../mtk/package/utils/mmap_sec_check),mmap_sec_check) \
	$(if $(wildcard $(TOPDIR)/../mtk/package/utils/procrank),procrank) \
	$(if $(wildcard $(TOPDIR)/../mtk/package/system/monitor_hang),monitor_hang) \
	$(if $(wildcard $(TOPDIR)/../mtk/package/system/sys_dbg_cfg),sys_dbg_cfg)
UBIFS_OPTS := $(call qstrip,$(CONFIG_UBIFS_OPTS))

define Device/Default
  DEVICE_VENDOR := MediaTek
  PROFILES = Default
  KERNEL := kernel-bin

  IMAGES := mcfota1.img mcfota2.img boot.img
  IMAGE/mcfota1.img := mkmcfota1 $(call qstrip,$(CONFIG_BOOTING_DEVICE)) | install-bin MCF_OTA_1.img
  IMAGE/mcfota2.img := mkmcfota2 $(call qstrip,$(CONFIG_BOOTING_DEVICE)) | install-bin MCF_OTA_2.img
  IMAGE/boot.img := mkdtbimg | mklkimg | mkbootimg | check-kernel-size | install-bin boot.img

  ARTIFACTS := install-extra.txt
  ARTIFACT/install-extra.txt := install-config-files | install-image-dtb | install-md-files | touch-target
endef

define Image/Build
	$(Build/install-rootfs)
	$(call Build/ubinize-root.squashfs,$(1))
	$(Build/install-staging-imgs)
	$(Build/sign-image)
	$(Build/pack-sysupgrade-bin)
	$(Build/build-info)
	$(KernelConfigPostCheck)
endef

include $(wildcard ../$(SUBTARGET)/device.mk)

$(eval $(BuildImage))
