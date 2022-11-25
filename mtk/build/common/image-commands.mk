include $(TOPDIR)/../mtk/build/common/definitions.mk
include $(TOPDIR)/../mtk/build/common/build_info.mk

LINUX_KARCH := $(if $(filter aarch64,$(ARCH)),arm64,arm)
MAIN_DTB_FILE := $(LINUX_DIR)/arch/$(LINUX_KARCH)/boot/dts$(if $(filter aarch64,$(ARCH)),/mediatek,)/$(SUBTARGET).dtb
MTK_MD_BIN_DIR := $(get-modem-bin-dir)

MTK_MCF_OTA_FILES_TGZ := $(MTK_MD_BIN_DIR)/MCF_OTA_FILES.tar.gz
MTK_MCF_OTA_1_DIR := $(TOPDIR)/target/linux/$(BOARD)/$(SUBTARGET)/MCF_OTA_1
MTK_MCF_OTA_1_DIR_STAGING := $(TMP_DIR)/$(BOARD)-$(SUBTARGET)-MCF_OTA_1
MTK_MCF_OTA_2_DIR := $(TOPDIR)/target/linux/$(BOARD)/$(SUBTARGET)/MCF_OTA_2
MTK_MCF_OTA_2_DIR_STAGING := $(TMP_DIR)/$(BOARD)-$(SUBTARGET)-MCF_OTA_2

# Create MCF OTA image
# $1: boot device type, either emmc or nand.
# $2: destination image file
# $3: source directory to be packed into an image, specific for ext4 images
define mcfota-img
	if [ 'emmc' = "$(1)" ]; then \
		dd if=/dev/zero of=$(2) bs=4k count=2048 && $(STAGING_DIR_HOST)/bin/mkfs.ext4 -d $(3) $(2); \
	elif [ 'nand' = "$(1)" ]; then \
		$(STAGING_DIR_HOST)/bin/mkfs.jffs2 --root=$(3) -o $(2) -s 0x1000 -e 0x40000 -n; \
	else \
		echo "ERROR: booting device $(1) does not support MCF" >&2; \
		false; \
	fi
endef

# Extact specific files from MCF OTA tarball to a directory
# $1: target directory to extract files into
define mcfota-install
	for i in `tar -zmtf $(MTK_MCF_OTA_FILES_TGZ) | egrep '\.(mcfota|mcfopota|ini)$$'`; do tar -C $(1) -zmxf $(MTK_MCF_OTA_FILES_TGZ) $${i}; done
endef

################################################################################
# Build first MCF OTA image
################################################################################
# $1: boot device type
define Build/mkmcfota1
	@if [ ! -d $(MTK_MCF_OTA_1_DIR) ]; then echo "ERROR: $(MTK_MCF_OTA_1_DIR) does not exist" >&2; false; fi
	rm -rf $(MTK_MCF_OTA_1_DIR_STAGING)
	$(CP) $(MTK_MCF_OTA_1_DIR) $(MTK_MCF_OTA_1_DIR_STAGING)
	$(call mcfota-img,$(1),$@,$(MTK_MCF_OTA_1_DIR_STAGING))
endef

################################################################################
# Build second MCF OTA image
################################################################################
# $1: boot device type
define Build/mkmcfota2
	@if [ ! -d $(MTK_MCF_OTA_2_DIR) ]; then echo "ERROR: $(MTK_MCF_OTA_2_DIR) does not exist" >&2; false; fi
	rm -rf $(MTK_MCF_OTA_2_DIR_STAGING)
	$(CP) $(MTK_MCF_OTA_2_DIR) $(MTK_MCF_OTA_2_DIR_STAGING)
	$(call mcfota-install,$(MTK_MCF_OTA_2_DIR_STAGING))
	$(call mcfota-img,$(1),$@,$(MTK_MCF_OTA_2_DIR_STAGING))
endef

define Build/check-kernel-size
	SIZE_CHECKER='$(TOPDIR)/../mtk/tools/internal/check_kernel_size.py'; \
	if [ -f $${SIZE_CHECKER} ]; then \
		python2 $${SIZE_CHECKER} $(KDIR) $(call qstrip,$(CONFIG_MTK_PLATFORM)) $(SUBTARGET) $(TOPDIR)/../; \
	fi
endef

MTK_DTB_IMG := $(BIN_DIR)/dtb.img
MTK_DTB_CFG := $(BIN_DIR)/dtb.cfg

# Create dtb config file
# $1: list of dtb names
# $2: config file
define mk_dtbimg_cfg
	$(INSTALL_DIR) $(dir $(2))
	rm -f $(2)
	my_dtb_id=0; \
	for i in $(1); do \
		echo $${i} >> $(2); \
		echo " id=$${my_dtb_id}" >> $(2); \
		my_dtb_id=$$(expr $${my_dtb_id} + 1); \
	done
endef

################################################################################
# Ubinize root.squash
################################################################################
define Build/ubinize-root.squashfs
	if [ "$(1)" = "ubifs" -a "$(CONFIG_TARGET_ROOTFS_UBIFS)" = 'y' ]; then \
		echo "Build/ubinize-root.squashfs: ubinize $(KDIR)/root.squashfs ..."; \
		$(TOPDIR)/scripts/ubinize-image.sh \
			$(KDIR)/root.squashfs \
			$(KDIR)/ubinized-root.squashfs \
			$(call qstrip,$(CONFIG_UBI_OPS)); \
		$(CP) $(KDIR)/ubinized-root.squashfs $(BIN_DIR)/root.squashfs; \
	fi
endef

################################################################################
# Create dtb image
################################################################################
define Build/mkdtbimg
	$(call mk_dtbimg_cfg,$(MAIN_DTB_FILE) $(patsubst %,$(KDIR)/arch/$(LINUX_KARCH)/boot/dts/%.dtb,$(EXTRA_DTB_NAMES)),$(MTK_DTB_CFG))
	$(TOPDIR)/../mtk/tools/common/mkdtimg cfg_create $(MTK_DTB_IMG) $(MTK_DTB_CFG)
endef

define Build/mkbootimg
	$(TOPDIR)/../mtk/tools/common/mkbootimg \
		--board $(call qstrip,$(CONFIG_MTK_PLATFORM)) \
		--kernel $(KDIR)/$(if $(filter aarch64,$(ARCH)),Image.gz,zImage) \
		--dtb $(MTK_DTB_IMG) \
		--base $(CONFIG_BOOTIMG_OFFSET_BASE) \
		--kernel_offset $(CONFIG_BOOTIMG_OFFSET_KERNEL) \
		--tags_offset $(CONFIG_BOOTIMG_OFFSET_TAGS) \
		--os_version 0.0.$(if $(filter aarch64,$(ARCH)),64,32) \
		--cmdline bootopt=$(if $(filter aarch64,$(ARCH)),64S3$(comma)32N2$(comma)64N2,64S3$(comma)32S1$(comma)32S1) \
		--output $@ \
		--header_version 2
endef

define Build/sign-image
	@echo 'Build/sign-image starts'; \
	cd $(TOPDIR)/..; \
	mtk/tools/common/security/tool/sign_image.sh $(BOARD) $(SUBTARGET) $(call qstrip,$(CONFIG_MTK_PLATFORM)) $(BIN_DIR); \
	cd - > /dev/null
endef

define Build/mklkimg
	$(TOPDIR)/../mtk/tools/common/mkimage $(MTK_DTB_IMG) $(TMP_DIR)/img_hdr_lk_dtb.cfg > $(TMP_DIR)/lk_main_dtb.img
	cat $(TMP_DIR)/lk_raw.img $(TMP_DIR)/lk.img $(TMP_DIR)/lk_main_dtb.img > $(BIN_DIR)/lk.img
endef

################################################################################
# Copy MD related files to BIN_DIR
################################################################################
MTK_MODEM_IMG := $(wildcard $(MTK_MD_BIN_DIR)/modem.img)
MTK_DSP_IMG := $(wildcard $(MTK_MD_BIN_DIR)/dsp.bin)
MTK_CATCHER_FILTER := $(wildcard $(MTK_MD_BIN_DIR)/catcher_filter*.bin)
MTK_EDB_FILES := $(wildcard $(MTK_MD_BIN_DIR)/*.EDB)
MTK_MDDB_MCF_ODB_TGZ := $(wildcard $(MTK_MD_BIN_DIR)/MDDB.MCF.ODB.tar.gz)
MTK_MDDB_META_ODB_XML_GZ := $(wildcard $(MTK_MD_BIN_DIR)/MDDB.META.ODB_*.XML.GZ)
define Build/install-md-files
	$(shell cp -rf $(MTK_MODEM_IMG) $(BIN_DIR))
	$(shell cp -rf $(MTK_DSP_IMG) $(BIN_DIR))
	$(shell cp -rf $(MTK_CATCHER_FILTER) $(BIN_DIR))
	$(shell cp -rf $(MTK_EDB_FILES) $(BIN_DIR))
	$(shell cp -rf $(MTK_MDDB_MCF_ODB_TGZ) $(BIN_DIR))
	$(shell cp -rf $(MTK_MDDB_META_ODB_XML_GZ) $(BIN_DIR))
	$(shell cp -rf $(MTK_MCF_OTA_FILES_TGZ) $(BIN_DIR))
endef

################################################################################
# Copy file defined in $(STAGING_DIR_IMAGE) to BIN_DIR
################################################################################
MTK_STAGING_FILES := \
  efuse.img \
  tee.img \
  bl31.elf \
  preloader_$(call qstrip,$(CONFIG_TARGET_SUBTARGET)).bin \
  preloader_$(call qstrip,$(CONFIG_TARGET_SUBTARGET)).elf \
  loader_ext.img \
  preloader_$(call qstrip,$(CONFIG_TARGET_SUBTARGET))_SBOOT_DIS.bin \
  preloader_$(call qstrip,$(CONFIG_TARGET_SUBTARGET))_SBOOT_DIS.elf \
  loader_ext_SBOOT_DIS.img \
  aee_lk.elf \
  lk.elf \
  dpm.img \
  sspm.img \
  tinysys-medmcu-RV33_A.elf \
  medmcu.img \
  mcupm.img \
  spmfw.img \
  spmfw_version.txt \
  download_agent \
  pi_img.img \
  vendor_info \
  logo.bin \
  *_openwrt_scatter.xml

define Build/install-staging-imgs
	$(if $(wildcard $(addprefix $(STAGING_DIR_IMAGE)/,$(MTK_STAGING_FILES))), \
		$(CP) $(wildcard $(addprefix $(STAGING_DIR_IMAGE)/,$(MTK_STAGING_FILES))) $(BIN_DIR) \
	)
endef

################################################################################
# Touch or create target file
################################################################################
SYSUPGRADE_FILES := \
  MCF_OTA_1.img \
  MCF_OTA_2.img \
  modem.img \
  dsp.bin \
  spmfw.img \
  dpm.img \
  medmcu.img \
  sspm.img \
  mcupm.img \
  lk.img \
  tee.img \
  boot.img \
  root.squashfs \
  ubi-rootfs.squashfs \
  root_ro.sig \
  pi_img.img \
  loader_ext.img \
  model \
  ddr_num \
  preloader_$(call qstrip,$(CONFIG_TARGET_SUBTARGET)).bin

define Build/pack-sysupgrade-bin
	cd $(BIN_DIR); \
    echo $(SUBTARGET) > model; \
	echo $(DDR_SUPPORT_NUM) > ddr_num; \
	FILES=''; \
	FILES_MODEM=''; \
	FILES_AP=''; \
	for i in $(SYSUPGRADE_FILES); do \
		if [ $$$${i} = root.squashfs ] && [ -f root.squashfs ] && [ -f ubi-rootfs.squashfs ]; then \
			echo "sysupgrade.bin: skip $$$${i}"; \
		else \
			IMAGE_VERIFIED="$$$${i/.img/-verified.img}"; \
			IMAGE_VERIFIED="$$$${IMAGE_VERIFIED/dsp.bin/dsp-verified.bin}"; \
			if [ $$$${IMAGE_VERIFIED} = modem-verified.img ] || [ $$$${IMAGE_VERIFIED} = dsp-verified.bin ]; then \
			  FILES_MODEM="$$$${FILES_MODEM} $$$${IMAGE_VERIFIED}"; \
			  FILES="$$$${FILES} $$$${IMAGE_VERIFIED}"; \
			elif [ $$$${i} = model ]; then \
			  FILES_MODEM="$$$${FILES_MODEM} $$$${i}"; \
			  FILES_AP="$$$${FILES_AP} $$$${i}"; \
			  FILES="$$$${FILES} $$$${i}"; \
			elif [ $$$${i} = ddr_num ]; then \
			  FILES_MODEM="$$$${FILES_MODEM} $$$${i}"; \
			  FILES_AP="$$$${FILES_AP} $$$${i}"; \
			  FILES="$$$${FILES} $$$${i}"; \
			elif [ $$$${i} = MCF_OTA_1.img ] || [ $$$${i} = MCF_OTA_2.img ]; then \
			  FILES_MODEM="$$$${FILES_MODEM} $$$${i}"; \
			  FILES="$$$${FILES} $$$${i}"; \
			elif [ $$$${IMAGE_VERIFIED} = boot-verified.img ] || [ $$$${IMAGE_VERIFIED} = lk-verified.img ]; then \
			  FILES_AP="$$$${FILES_AP} $$$${IMAGE_VERIFIED}"; \
			  FILES="$$$${FILES} $$$${IMAGE_VERIFIED}"; \
			elif [ $$$${i} = root.squashfs ] || [ $$$${i} = root_ro.sig ] ; then \
			  FILES_AP="$$$${FILES_AP} $$$${i}"; \
			  FILES="$$$${FILES} $$$${i}"; \
			elif [ -f $$$${IMAGE_VERIFIED} ]; then \
				FILES="$$$${FILES} $$$${IMAGE_VERIFIED}"; \
			elif [ -f $$$${i} ]; then \
				FILES="$$$${FILES} $$$${i}"; \
			fi \
		fi \
	done; \
   	echo "$(REVISION)_modem.bin: files included: $$$${FILES_MODEM}"; \
	tar -czf $(REVISION)_modem.bin $$$${FILES_MODEM}; \
	echo "$(REVISION)_ap.bin: files included: $$$${FILES_AP}"; \
	tar -czf $(REVISION)_ap.bin $$$${FILES_AP}; \
	echo "$(REVISION).bin: files included: $$$${FILES}"; \
	tar -czf $(REVISION).bin $$$${FILES}; \
	cd - > /dev/null
endef

################################################################################
# Copy kernel and OpenWrt config files to BIN_DIR
################################################################################
define Build/install-config-files
	$(if $(wildcard $(LINUX_DIR)/.config),$(shell cp -rf $(LINUX_DIR)/.config $(BIN_DIR)/kernel.config))
	$(if $(wildcard $(TOPDIR)/.config),$(shell cp -rf $(TOPDIR)/.config $(BIN_DIR)/openwrt.config))
endef

################################################################################
# Copy dtb file to BIN_DIR
################################################################################
define Build/install-image-dtb
	$(shell cp -rf $(MAIN_DTB_FILE) $(BIN_DIR)/Image.dtb)
endef

################################################################################
# Copy root.*, such as root.squashfs, to BIN_DIR
################################################################################
define Build/install-rootfs
	$(CP) $(KDIR)/root.* $(BIN_DIR)
endef

################################################################################
# Copy target file to BIN_DIR
################################################################################
# $1: new file name under BIN_DIR
define Build/install-bin
	@echo "Build/install-bin: cp $@ $(BIN_DIR)/$(1)"
	$(CP) $@ $(BIN_DIR)/$(1)
endef

################################################################################
# Touch or create target file
################################################################################
define Build/touch-target
	$(shell touch $@)
endef
