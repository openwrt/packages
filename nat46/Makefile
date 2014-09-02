#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=nat46
PKG_VERSION:=1
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/ayourtch/nat46.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=758a02e6f9e4c43553e0fc37d83c286c77febe94
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>

include $(INCLUDE_DIR)/package.mk

define Package/map-t
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+map +kmod-nat46
  TITLE:=MAP-T configuration support
endef

define KernelPackage/nat46
  DEPENDS:=+kmod-ipv6
  TITLE:=Stateless NAT46 translation kernel module
  SECTION:=kernel
  SUBMENU:=Network Support
  FILES:=$(PKG_BUILD_DIR)/nat46/modules/nat46.ko 
  AUTOLOAD:=$(call AutoLoad,33,nat46)
endef

include $(INCLUDE_DIR)/kernel-defaults.mk

define Build/Compile
	$(MAKE) $(KERNEL_MAKEOPTS) SUBDIRS="$(PKG_BUILD_DIR)/nat46/modules" \
		MODFLAGS="-DMODULE -mlong-calls" \
		modules
endef

define Package/map-t/install
	true
endef

$(eval $(call KernelPackage,nat46))
$(eval $(call BuildPackage,map-t))
