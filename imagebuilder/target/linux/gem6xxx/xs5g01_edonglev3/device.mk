define Device/xs5g01_edonglev3
  DEVICE_MODEL := Generic MT6890 EVB for emmc CPE
  DEVICE_PACKAGES := $(MT6890_DEFAULT_PACKAGES)
endef
TARGET_DEVICES += xs5g01_edonglev3

define Device/xs5g01_edonglev3_debug
  DEVICE_MODEL := Generic MT6890 EVB for emmc CPE (debug)
  DEVICE_PACKAGES := $(MT6890_DEFAULT_PACKAGES) $(DEVICE_PACKAGES_DEBUG)
endef
TARGET_DEVICES += xs5g01_edonglev3_debug
