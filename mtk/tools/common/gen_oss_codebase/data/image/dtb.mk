MTK_DTB_IMG := $(BIN_DIR)/dtb.img
MTK_DTB_CFG := $(BIN_DIR)/dtb.cfg
MKDTIMG_UTIL := $(TOPDIR)/../mtk/tools/common/mkdtimg

ifneq (,$(wildcard $(MKDTIMG_UTIL)))

# $1: list of dtb names
# $2: config file
define mk_dtbimg_cfg
	rm -f $(2)
	my_dtb_id=0; \
	for i in $(1); do \
		echo $$$${i} >> $(2); \
		echo " id=$$$${my_dtb_id}" >> $(2); \
		my_dtb_id=$$$$(expr $$$${my_dtb_id} + 1); \
	done
endef

# $1: main dtb image
define mk_dtbimg
	$(call mk_dtbimg_cfg,$(1) $(patsubst %,$(call qstrip,$(CONFIG_EXTERNAL_KERNEL_TREE))/arch/$(LINUX_KARCH)/boot/dts/%.dtb,$(EXTRA_DTB_NAMES)),$(MTK_DTB_CFG))
	$(MKDTIMG_UTIL) cfg_create $(MTK_DTB_IMG) $(MTK_DTB_CFG)
endef

endif # MKDTIMG_UTIL exists

