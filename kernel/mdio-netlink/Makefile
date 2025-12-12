include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mdio-netlink
PKG_VERSION:=1.3.1
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://github.com/wkz/mdio-tools
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f74eaf38dbda441df4fcaeb21ca4465957953a2f
PKG_MIRROR_HASH:=fdabb78a4fe26713c4c83aab707f57254145184614b9b39b17649a2151394005

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
