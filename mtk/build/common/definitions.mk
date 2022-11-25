# This file contains common variables and functions

include $(TOPDIR)/rules.mk
# .config does not exist in package/symlinks stage, hence optional
-include .config

# The path cannot be fetched from branch property config since it's not
# available for customers
MTK_MODEM_PREBUILT_DIR_TOP := $(TOPDIR)/../mtk/prebuilt/mdbin

# Get the path of prebuilt modem direcoty. If CONFIG_MTK_MODEM_BIN_DIR is not
# empty, it is used, otherwise search it with predefined policies.
define get-modem-bin-dir
$(strip \
  $(if $(call qstrip,$(CONFIG_MTK_MODEM_BIN_DIR)), \
    $(call qstrip,$(CONFIG_MTK_MODEM_BIN_DIR)), \
    $(firstword \
      $(wildcard \
        $(MTK_MODEM_PREBUILT_DIR_TOP)/$(call qstrip,$(CONFIG_MTK_MDBIN_PLATFORM))_internal \
        $(MTK_MODEM_PREBUILT_DIR_TOP)/$(call qstrip,$(CONFIG_MTK_MDBIN_PLATFORM)) \
      ) \
    ) \
  ) \
)
endef

# Get the SHA1 checksum from the list of SHA1 checksum of all files in given
# directory. The path of files are irrelevant. Only the existence and content
# matter.
#
# $1: directory path
dir_files_checksum = find $(1) -type f -print0 | xargs -0 sha1sum | awk '{print $$1}' | sort | sha1sum - | awk '{print $$1}'
