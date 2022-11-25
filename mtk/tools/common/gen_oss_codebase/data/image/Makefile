# Copyright (c) 2014 The Linux Foundation. All rights reserved.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

ifneq (1,$(DUMP))
  include $(PLATFORM_DIR_REAL)/$(SUBTARGET)/target-settings.mk
  include $(TOPDIR)/target/linux/$(BOARD)/image/dtb.mk
  -include $(TOPDIR)/../mtk/build/common/definitions.mk

  ifneq (yes,$(DISABLE_MTK_BUILD_POSTCHECK))
    -include $(TOPDIR)/../mtk/build/rules/build_postcheck.mk
  endif

  # Determine MCF image filesystem by storage type
  MTK_MCF_OTA_FS :=
  ifneq (,$(filter emmc,$(BOOTING_DEVICE)))
    MTK_MCF_OTA_FS := ext4
  else ifneq (,$(filter nand,$(BOOTING_DEVICE)))
    MTK_MCF_OTA_FS := jffs2
  endif

  ifeq (,$(MTK_MCF_OTA_FS))
    $(error booting device "$(BOOTING_DEVICE)" does not support MCF)
  endif
endif

LINUX_KARCH := $(if $(filter aarch64,$(ARCH)),arm64,arm)
ARCH_BITS := $(if $(filter aarch64,$(ARCH)),64,32)
KERNEL_IMAGE := $(if $(filter aarch64,$(ARCH)),Image.gz,zImage)
MAIN_DTB_FILE := \
	$(call qstrip,$(CONFIG_EXTERNAL_KERNEL_TREE))/arch/$(LINUX_KARCH)/boot/dts$(if $(filter aarch64,$(ARCH)),/mediatek,)/$(SUBTARGET).dtb

# Directory to look up modem binaries
MD_BIN_DIR := $(get-modem-bin-dir)
-include $(TOPDIR)/../mtk/build/common/build_info.mk

MTK_MODEM_IMG := $(wildcard $(MD_BIN_DIR)/modem.img)
MTK_DSP_IMG := $(wildcard $(MD_BIN_DIR)/dsp.bin)
MTK_CATCHER_FILTER := $(wildcard $(MD_BIN_DIR)/catcher_filter*.bin)
MTK_EDB_FILES := $(wildcard $(MD_BIN_DIR)/*.EDB)
MTK_MDDB_MCF_ODB_TGZ := $(wildcard $(MD_BIN_DIR)/MDDB.MCF.ODB.tar.gz)

# MCF OTA related
MTK_MCF_OTA_FILES_TGZ := $(MD_BIN_DIR)/MCF_OTA_FILES.tar.gz
MTK_MCF_OTA_1_DIR := $(TOPDIR)/target/linux/$(BOARD)/$(SUBTARGET)/MCF_OTA_1
MTK_MCF_OTA_1_DIR_STAGING := $(TMP_DIR)/$(BOARD)-$(SUBTARGET)-MCF_OTA_1
MTK_MCF_OTA_2_DIR := $(TOPDIR)/target/linux/$(BOARD)/$(SUBTARGET)/MCF_OTA_2
MTK_MCF_OTA_2_DIR_STAGING := $(TMP_DIR)/$(BOARD)-$(SUBTARGET)-MCF_OTA_2
MTK_MCF_OTA_1_IMG := $(BIN_DIR)/MCF_OTA_1.img
MTK_MCF_OTA_2_IMG := $(BIN_DIR)/MCF_OTA_2.img
MTK_MCF_OTA_1_IMG_BSCNT := 2048 # unit: 4KB
MTK_MCF_OTA_2_IMG_BSCNT := 2048 # unit: 4KB

ifeq ($(ARCH),aarch64)
	CMDLINE:=bootopt=64S3,32N2,64N2
else
	CMDLINE:=bootopt=64S3,32S1,32S1
endif

LK_MKIMAGE_TOOL := $(TOPDIR)/../mtk/tools/common/mkimage
LK_RAW_TARGET := $(TMP_DIR)/lk_raw.img
AEE_LK_TARGET := $(TMP_DIR)/lk.img
LK_DTB_CFG_FILE := $(TMP_DIR)/img_hdr_lk_dtb.cfg
LK_MAIN_DTB_TARGET := $(TMP_DIR)/lk_main_dtb.img
LK_INSTALLED_TARGET := $(BIN_DIR)/lk.img

# to check load features
MTK_KERNEL_CONFIG_FILE := $(wildcard $(call qstrip,$(CONFIG_EXTERNAL_KERNEL_TREE))/.config)
MTK_TARGET_CONFIG_FILE := $(wildcard $(TOPDIR)/.config)

# File names in $(STAGING_DIR_IMAGE) to be copied to $(BIN)
MTK_STAGING_FILES := \
  efuse.img \
  tee.img \
  bl31.elf \
  preloader_$(call qstrip,$(CONFIG_TARGET_SUBTARGET)).bin \
  preloader_$(call qstrip,$(CONFIG_TARGET_SUBTARGET)).elf \
  loader_ext.img \
  aee_lk.elf \
  lk.elf \
  dpm.img \
  sspm.img \
  mcupm.img \
  spmfw.img \
  spmfw_version.txt \
  download_agent \
  vendor_info \
  $(call toupper,$(BOARD))_openwrt_scatter.xml

# Create MCF ext4 image
# $1: destination image file
# $2: count of input blocks
# $3: source directory to be packed into an image
define Image/Build/PackMCFImageExt4
dd if=/dev/zero of=$(1) bs=4k count=$(2) && $(STAGING_DIR_HOST)/bin/mkfs.ext4 -d $(3) $(1)
endef

# Create MCF jffs2 image
# $1: destination image file
# $2: source directory to be packed into an image
define Image/Build/PackMCFImageJffs2
$(STAGING_DIR_HOST)/bin/mkfs.jffs2 --root=$(2) -o $(1) -s 0x1000 -e 0x40000 -n
endef

# Extact specific files from MCF OTA tarball to a directory
# $1: target directory to extract files into
define Image/Build/InstallMCFOTA
for i in `tar -zmtf $(MTK_MCF_OTA_FILES_TGZ) | egrep '\.(mcfota|mcfopota|ini)$$$$'`; do tar -C $(1) -zmxf $(MTK_MCF_OTA_FILES_TGZ) $$$${i}; done
endef

define Image/Build/PackMCFImage
	@if [ ! -d $(MTK_MCF_OTA_1_DIR) ]; then echo "ERROR: $(MTK_MCF_OTA_1_DIR) does not exist" >&2; false; fi
	@if [ ! -d $(MTK_MCF_OTA_2_DIR) ]; then echo "ERROR: $(MTK_MCF_OTA_2_DIR) does not exist" >&2; false; fi
	@rm -f $(MTK_MCF_OTA_1_IMG) $(MTK_MCF_OTA_2_IMG)
	if [ 'ext4' = "$(MTK_MCF_OTA_FS)" ]; then \
		rm -rf $(MTK_MCF_OTA_1_DIR_STAGING); \
		$(CP) $(MTK_MCF_OTA_1_DIR) $(MTK_MCF_OTA_1_DIR_STAGING); \
		$(call Image/Build/PackMCFImageExt4,$(MTK_MCF_OTA_1_IMG),$(MTK_MCF_OTA_1_IMG_BSCNT),$(MTK_MCF_OTA_1_DIR_STAGING)); \
		rm -rf $(MTK_MCF_OTA_2_DIR_STAGING); \
		$(CP) $(MTK_MCF_OTA_2_DIR) $(MTK_MCF_OTA_2_DIR_STAGING); \
		$(call Image/Build/InstallMCFOTA,$(MTK_MCF_OTA_2_DIR_STAGING)); \
		$(call Image/Build/PackMCFImageExt4,$(MTK_MCF_OTA_2_IMG),$(MTK_MCF_OTA_2_IMG_BSCNT),$(MTK_MCF_OTA_2_DIR_STAGING)); \
	elif [ 'jffs2' = "$(MTK_MCF_OTA_FS)" ]; then \
		rm -rf $(MTK_MCF_OTA_1_DIR_STAGING); \
		$(CP) $(MTK_MCF_OTA_1_DIR) $(MTK_MCF_OTA_1_DIR_STAGING); \
		$(call Image/Build/PackMCFImageJffs2,$(MTK_MCF_OTA_1_IMG),$(MTK_MCF_OTA_1_DIR_STAGING)); \
		rm -rf $(MTK_MCF_OTA_2_DIR_STAGING); \
		$(CP) $(MTK_MCF_OTA_2_DIR) $(MTK_MCF_OTA_2_DIR_STAGING); \
		$(call Image/Build/InstallMCFOTA,$(MTK_MCF_OTA_2_DIR_STAGING)); \
		$(call Image/Build/PackMCFImageJffs2,$(MTK_MCF_OTA_2_IMG),$(MTK_MCF_OTA_2_DIR_STAGING)); \
	fi
endef

ifneq (,$(wildcard $(TOPDIR)/../mtk/tools/common/mkbootimg))
define Image/Build/mkbootimg
	$(call mk_dtbimg,$(MAIN_DTB_FILE))
	$(TOPDIR)/../mtk/tools/common/mkbootimg \
		--board $(BOARD) \
		--kernel $(KDIR)/$(KERNEL_IMAGE) \
		--dtb $(MTK_DTB_IMG) \
		--base $(BOOTIMG_OFFSET_BASE) \
		--kernel_offset $(BOOTIMG_OFFSET_KERNEL) \
		--tags_offset $(BOOTIMG_OFFSET_TAGS) \
		--os_version 0.0.$(ARCH_BITS) \
		--cmdline $(CMDLINE)  \
		--output $(BIN_DIR)/boot.img \
		--header_version 2
endef
endif

ifneq (,$(wildcard $(LK_MKIMAGE_TOOL)))
define Image/Build/mklkimg
	$(LK_MKIMAGE_TOOL) $(MTK_DTB_IMG) $(LK_DTB_CFG_FILE) > $(LK_MAIN_DTB_TARGET)
	cat $(LK_RAW_TARGET) $(AEE_LK_TARGET) $(LK_MAIN_DTB_TARGET) > $(LK_INSTALLED_TARGET)
endef
endif

define Image/Build/squashfs
	$(if $(wildcard $(addprefix $(STAGING_DIR_IMAGE)/,$(MTK_STAGING_FILES))), \
		$(CP) $(wildcard $(addprefix $(STAGING_DIR_IMAGE)/,$(MTK_STAGING_FILES))) $(BIN_DIR) \
	)

	$(call prepare_generic_squashfs,$(KDIR)/root.squashfs)
	$(CP) $(KDIR)/root.squashfs $(BIN_DIR)
	$(if $(wildcard $(TOPDIR)/target/linux/$(BOARD)/$(SUBTARGET)/bin), \
		$(CP) $(TOPDIR)/target/linux/$(BOARD)/$(SUBTARGET)/bin/* $(BIN_DIR)/ \
	)
	$(if $(wildcard $(MAIN_DTB_FILE)),$(CP) $(MAIN_DTB_FILE) $(BIN_DIR)/Image.dtb)
	$(CP) $(KDIR)/root.squashfs $(BIN_DIR)/root.squashfs
	$(if $(MTK_MODEM_IMG),$(CP) $(MTK_MODEM_IMG) $(BIN_DIR))
	$(if $(MTK_DSP_IMG),$(CP) $(MTK_DSP_IMG) $(BIN_DIR))
	$(if $(MTK_CATCHER_FILTER),$(CP) $(MTK_CATCHER_FILTER) $(BIN_DIR))
	$(if $(wildcard $(MTK_MCF_OTA_FILES_TGZ)),$(CP) $(MTK_MCF_OTA_FILES_TGZ) $(BIN_DIR))
	$(if $(MTK_MDDB_MCF_ODB_TGZ),$(CP) $(MTK_MDDB_MCF_ODB_TGZ) $(BIN_DIR))
	$(if $(MTK_EDB_FILES),$(CP) $(MTK_EDB_FILES) $(BIN_DIR))
	$(if $(MTK_KERNEL_CONFIG_FILE),$(CP) $(MTK_KERNEL_CONFIG_FILE) $(BIN_DIR)/kernel.config)
	$(if $(MTK_TARGET_CONFIG_FILE),$(CP) $(MTK_TARGET_CONFIG_FILE) $(BIN_DIR)/openwrt.config)

	$(Image/Build/mkbootimg)
	$(Image/Build/mklkimg)
endef

ifneq (,$(wildcard $(TOPDIR)/../mtk/tools/common/security/tool/sign_image.sh))
define Image/Build/SignImage
	@echo 'Image/Build/SignImage starts'; \
	cd $(TOPDIR)/..; \
	mtk/tools/common/security/tool/sign_image.sh $(BOARD) $(SUBTARGET) $(call qstrip,$(CONFIG_MTK_PLATFORM)) $(BIN_DIR); \
	cd - > /dev/null
endef
endif

define Image/Build
	$(call Image/Build/$(1),$(1))
	$(Image/Build/PackMCFImage)
	$(Image/Build/CheckRequiredBinDirFiles)
	$(Image/Build/SignImage)
	$(MTKBuildInfo)
endef

$(eval $(BuildImage))

