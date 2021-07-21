include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mdio-netlink
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/wkz/mdio-tools
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-07-19
PKG_SOURCE_VERSION:=65f6898f25b00deebe1c38811e893d9dcd4d7ef3
PKG_MIRROR_HASH:=9db854037b3e8596ccd71567a45aa60fd3cac88b01c9197d4dd9cf3f32589cb2

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Damien Mascord <tusker@tusker.org>

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mdio-netlink
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  TITLE:=mdio-netlink Linux MDIO netlink kernel module
  KCONFIG:=CONFIG_PHYLIB=y CONFIG_MDIO_BUS=y
  URL:=https://github.com/wkz/mdio-tools.git
  FILES:=$(PKG_BUILD_DIR)/kernel/mdio-netlink.ko
  AUTOLOAD:=$(call AutoProbe,mdio-netlink)
endef

define KernelPackage/mdio-netlink/description
  mdio-netlink Linux MDIO netlink kernel module
endef

define Build/Compile
	$(KERNEL_MAKE) M=$(PKG_BUILD_DIR)/kernel modules
endef

$(eval $(call KernelPackage,mdio-netlink))
