#!/bin/bash

if [ "$1" == "" ] ;
then
	echo "FATAL:No target name"
    echo "example:"
    echo "./scripts/xs_sdk_scripts/make_dtb.sh xs5g01_cpe"
	exit;
fi

target=$1

cd build_dir/target-aarch64_cortex-a55+neon-vfpv4_musl/linux-gem6xxx_$target/linux-5.4.179/ && ../../../../staging_dir/toolchain-aarch64_cortex-a55+neon-vfpv4_gcc-8.4.0_musl/bin/aarch64-openwrt-linux-gcc -E -Wp,-MD,arch/arm64/boot/dts/mediatek/.$target.dtb.d.pre.tmp -nostdinc -I./scripts/dtc/include-prefixes -I./arch/arm64/boot/dts -I./arch/arm64/boot/dts/include -I./include/ -Iarch/arm64/boot/dts -undef -D__DTS__ -x assembler-with-cpp -o arch/arm64/boot/dts/mediatek/.$target.dtb.dts.tmp arch/arm64/boot/dts/mediatek/$target.dts && ./scripts/dtc/dtc -O dtb -o arch/arm64/boot/dts/mediatek/$target.dtb -b 0 -iarch/arm64/boot/dts/mediatek/ -i./scripts/dtc/include-prefixes -Wno-unit_address_vs_reg -Wno-unit_address_format -Wno-avoid_unnecessary_addr_size -Wno-alias_paths -Wno-graph_child_address -Wno-graph_port -Wno-simple_bus_reg -Wno-unique_unit_address -Wno-pci_device_reg -@ -d arch/arm64/boot/dts/mediatek/.$target.dtb.d.dtc.tmp arch/arm64/boot/dts/mediatek/.$target.dtb.dts.tmp && cat arch/arm64/boot/dts/mediatek/.$target.dtb.d.pre.tmp arch/arm64/boot/dts/mediatek/.$target.dtb.d.dtc.tmp > arch/arm64/boot/dts/mediatek/.$target.dtb.d && cd - && cp build_dir/target-aarch64_cortex-a55+neon-vfpv4_musl/linux-gem6xxx_$target/linux-5.4.179/arch/arm64/boot/dts/mediatek/$target.dtb .
echo "========== Please copy $target.dtb to linux-5.4/arch/arm64/boot/dts/mediatek folder in imagebuilder ========="
