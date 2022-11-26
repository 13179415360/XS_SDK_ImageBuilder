cmd_arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dtb := mkdir -p arch/arm64/boot/dts/mediatek/ ; gcc -E -Wp,-MD,arch/arm64/boot/dts/mediatek/.xs5g01_5gbox.dtb.d.pre.tmp -nostdinc -I./scripts/dtc/include-prefixes -I./arch/arm64/boot/dts -I./arch/arm64/boot/dts/include -I./include/ -Iarch/arm64/boot/dts -undef -D__DTS__ -x assembler-with-cpp -o arch/arm64/boot/dts/mediatek/.xs5g01_5gbox.dtb.dts.tmp arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dts ; ./scripts/dtc/dtc -O dtb -o arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dtb -b 0 -iarch/arm64/boot/dts/mediatek/ -i./scripts/dtc/include-prefixes -Wno-unit_address_vs_reg -Wno-unit_address_format -Wno-avoid_unnecessary_addr_size -Wno-alias_paths -Wno-graph_child_address -Wno-simple_bus_reg -Wno-unique_unit_address -Wno-pci_device_reg  -d arch/arm64/boot/dts/mediatek/.xs5g01_5gbox.dtb.d.dtc.tmp arch/arm64/boot/dts/mediatek/.xs5g01_5gbox.dtb.dts.tmp ; cat arch/arm64/boot/dts/mediatek/.xs5g01_5gbox.dtb.d.pre.tmp arch/arm64/boot/dts/mediatek/.xs5g01_5gbox.dtb.d.dtc.tmp > arch/arm64/boot/dts/mediatek/.xs5g01_5gbox.dtb.d

source_arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dtb := arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dts

deps_arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dtb := \
  scripts/dtc/include-prefixes/dt-bindings/interrupt-controller/irq.h \
  scripts/dtc/include-prefixes/dt-bindings/interrupt-controller/arm-gic.h \
  arch/arm64/boot/dts/mediatek/xs_mt6890.dtsi \
    $(wildcard include/config/mtk/gmo/ram/optimize.h) \
    $(wildcard include/config/mtk/met/mem/alloc.h) \
  scripts/dtc/include-prefixes/dt-bindings/clock/mt6890-clk.h \
  scripts/dtc/include-prefixes/dt-bindings/pinctrl/mt68xx-pinfunc.h \
  scripts/dtc/include-prefixes/dt-bindings/pinctrl/mt65xx.h \
  scripts/dtc/include-prefixes/dt-bindings/memory/mt6880-larb-port.h \
  scripts/dtc/include-prefixes/dt-bindings/power/mt6890-power.h \
  scripts/dtc/include-prefixes/dt-bindings/reset/ti-syscon.h \
  scripts/dtc/include-prefixes/dt-bindings/soc/mediatek,boot-mode.h \
  scripts/dtc/include-prefixes/dt-bindings/spmi/spmi.h \
  scripts/dtc/include-prefixes/dt-bindings/gpio/gpio.h \
  scripts/dtc/include-prefixes/dt-bindings/input/input.h \
  scripts/dtc/include-prefixes/dt-bindings/input/linux-event-codes.h \
  scripts/dtc/include-prefixes/dt-bindings/phy/phy.h \
  scripts/dtc/include-prefixes/dt-bindings/interconnect/mtk,mt6873-emi.h \
  scripts/dtc/include-prefixes/dt-bindings/iio/mt635x-auxadc.h \
  scripts/dtc/include-prefixes/dt-bindings/gce/mt6890-gce.h \
  scripts/dtc/include-prefixes/dt-bindings/thermal/thermal.h \
  arch/arm64/boot/dts/mediatek/mt6890-clkao.dtsi \
  arch/arm64/boot/dts/mediatek/mt6330.dtsi \
  arch/arm64/boot/dts/mediatek/xs_cust_mt6890_msdc.dtsi \
  arch/arm64/boot/dts/mediatek/tcpc_config.dtsi \
    $(wildcard include/config/mtk/gauge/version.h) \
  arch/arm64/boot/dts/mediatek/rt9467.dtsi \
  arch/arm64/boot/dts/mediatek/xs5g01_5gbox/cust.dtsi \

arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dtb: $(deps_arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dtb)

$(deps_arch/arm64/boot/dts/mediatek/xs5g01_5gbox.dtb):
