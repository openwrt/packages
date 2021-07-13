include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mdio-netlink
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/wkz/mdio-tools
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-07-02
PKG_SOURCE_VERSION:=9f989622c21d5464168a4922542be044f21663b0
PKG_MIRROR_HASH:=9ae5d920e23a7957a5d5a8c5764969382ce6a174c5c5e7f7841fac0c81bbac75

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

