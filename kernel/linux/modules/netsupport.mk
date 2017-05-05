#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

NETWORK_SUPPORT_MENU:=Network Support

define KernelPackage/openvswitch
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  TITLE:=Open vSwitch Kernel Package
  KCONFIG:= \
	CONFIG_BRIDGE \
	CONFIG_OPENVSWITCH \
	CONFIG_OPENVSWITCH_GRE=n \
	CONFIG_OPENVSWITCH_VXLAN=n \
	CONFIG_OPENVSWITCH_GENEVE=n
  DEPENDS:= \
	@IPV6 +kmod-gre +kmod-lib-crc32c +kmod-mpls \
	+kmod-vxlan +kmod-nf-nat +kmod-nf-nat6
  FILES:= $(LINUX_DIR)/net/openvswitch/openvswitch.ko
  AUTOLOAD:=$(call AutoLoad,21,openvswitch)
endef

define KernelPackage/openvswitch/description
  This package contains the Open vSwitch kernel moodule and bridge compat
  module. Furthermore, it supports OpenFlow.
endef

$(eval $(call KernelPackage,openvswitch))

