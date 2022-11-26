#
# Copyright (C) 2009 OpenWrt.org
#
ARCH:=aarch64
SUBTARGET:=xs5g01_edonglev3
BOARDNAME:=MT6890 xs5g01_edonglev3 development (64 bits)
FEATURES+=squashfs
CPU_TYPE:=cortex-a55
CPU_SUBTYPE:=neon-vfpv4
DDR_SUPPORT_NUM:=5

KERNELNAME:=Image.gz dtbs

define Target/Description
	Build firmware images for MTK MT6890 xs5g01_edonglev3 development with eMMC support
endef

DEVICE_TYPE:=router
