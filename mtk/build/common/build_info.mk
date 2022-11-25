# dump build information to BIN dir
include $(TOPDIR)/../mtk/build/common/definitions.mk

BUILD_INFO_TXT_CREATED_TIME := $(strip $(shell TZ=$(shell cat /etc/timezone) date +"%Y%m%d %H:%M:%S"))
ABS_MTK_MODEM_BIN_DIR := $(abspath $(get-modem-bin-dir))
MD_VERSION_INFO_LOG := $(ABS_MTK_MODEM_BIN_DIR)/md_version_info.log
BUILD_INFO_FILE = $(BIN_DIR)/build_info.txt
VENDOR_INFO_FILE = $(BUILD_DIR)/vendor_info/out/vendor_info

ifneq ($(wildcard $(MD_VERSION_INFO_LOG)),)
    MD_LABEL = $(strip $(subst LABEL=,,$(shell grep 'LABEL=' $(MD_VERSION_INFO_LOG))))
    MD_PROJECT = $(strip $(subst PROJECT=,,$(shell grep 'PROJECT=' $(MD_VERSION_INFO_LOG))))
    MD_BRANCH = $(strip $(subst BRANCH=,,$(shell grep 'BRANCH=' $(MD_VERSION_INFO_LOG))))
    MD_TYPE = $(strip $(subst TYPE=,,$(shell grep 'TYPE=' $(MD_VERSION_INFO_LOG))))
    MD_VERSION = $(MD_LABEL)/$(MD_PROJECT)
else
    MD_VERSION = unknown
    MD_BRANCH = unknown
    MD_TYPE = unknown
endif


define Build/build-info
	@rm -f $(BUILD_INFO_FILE)
	@echo "MD_VERSION=$(MD_VERSION)" > $(BUILD_INFO_FILE)
	@echo "MD_BRANCH=$(MD_BRANCH)" >> $(BUILD_INFO_FILE)
	@echo "MD_TYPE=$(MD_TYPE)" >> $(BUILD_INFO_FILE)
	@echo "MD_BIN_PATH=$(ABS_MTK_MODEM_BIN_DIR)" >> $(BUILD_INFO_FILE)
	@echo "PROFILE=$(strip $(PROFILE))" >> $(BUILD_INFO_FILE)
	@echo "BUILD_INFO_TXT_CREATED_TIME=$(BUILD_INFO_TXT_CREATED_TIME)" >> $(BUILD_INFO_FILE)
	@if [ -f $(VENDOR_INFO_FILE) ]; then \
		cat $(VENDOR_INFO_FILE) >> $(BUILD_INFO_FILE); \
	else \
		echo "SUBTARGET=$(SUBTARGET)" >> $(BUILD_INFO_FILE); \
		echo "PLATFORM=$(BOARD)" >> $(BUILD_INFO_FILE); \
	fi

	@echo "BIN_DIR=$(BIN_DIR)" >> $(BUILD_INFO_FILE)
	@echo "BUILD_DIR=$(BUILD_DIR)" >> $(BUILD_INFO_FILE)
	@echo "BUILD_DIR_BASE=$(BUILD_DIR_BASE)" >> $(BUILD_INFO_FILE)
	@echo "BUILD_DIR_HOST=$(BUILD_DIR_HOST)" >> $(BUILD_INFO_FILE)
	@echo "BUILD_DIR_TOOLCHAIN=$(BUILD_DIR_TOOLCHAIN)" >> $(BUILD_INFO_FILE)
	@echo "INCLUDE_DIR=$(INCLUDE_DIR)" >> $(BUILD_INFO_FILE)
	@echo "KERNEL_BUILD_DIR=$(KERNEL_BUILD_DIR)" >> $(BUILD_INFO_FILE)
	@echo "MAKE_VARS=$(MAKE_VARS)" >> $(BUILD_INFO_FILE)
	@echo "PACKAGE_DIR=$(PACKAGE_DIR)" >> $(BUILD_INFO_FILE)
	@echo "STAGING_DIR=$(STAGING_DIR)" >> $(BUILD_INFO_FILE)
	@echo "STAGING_DIR_HOST=$(STAGING_DIR_HOST)" >> $(BUILD_INFO_FILE)
	@echo "STAGING_DIR_HOSTPKG=$(STAGING_DIR_HOSTPKG)" >> $(BUILD_INFO_FILE)
	@echo "STAGING_DIR_ROOT=$(STAGING_DIR_ROOT)" >> $(BUILD_INFO_FILE)
	@echo "TARGET_CONFIGURE_OPTS=$(TARGET_CONFIGURE_OPTS)" >> $(BUILD_INFO_FILE)
	@echo "TARGET_PATH=$(TARGET_PATH)" >> $(BUILD_INFO_FILE)
	@echo "TMP_DIR=$(TMP_DIR)" >> $(BUILD_INFO_FILE)
	@echo "TOOLCHAIN_DIR=$(TOOLCHAIN_DIR)" >> $(BUILD_INFO_FILE)
	@echo "TOPDIR=$(TOPDIR)" >> $(BUILD_INFO_FILE)

	@echo "Build/build-info: build info is written to $(BUILD_INFO_FILE)"
endef
