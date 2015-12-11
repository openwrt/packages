#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=nat46
PKG_VERSION:=6
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/ayourtch/nat46.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=8ff2ae59ec9840a7b8b45f976c51cae80abe0226
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/map-t
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+map +kmod-nat46
  TITLE:=MAP-T configuration support
endef

define Package/464xlat
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-nat46
  TITLE:=464xlat CLAT support
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

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -Wall" \
		LDFLAGS="$(TARGET_LDFLAGS)"
	$(MAKE) $(KERNEL_MAKEOPTS) SUBDIRS="$(PKG_BUILD_DIR)/nat46/modules" \
		MODFLAGS="-DMODULE -mlong-calls" \
		EXTRA_CFLAGS="-DNAT46_VERSION=\\\"$(PKG_SOURCE_VERSION)\\\"" \
		modules
endef

define Package/map-t/install
	true
endef

define Package/464xlat/install
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/464xlat.sh $(1)/lib/netifd/proto/464xlat.sh
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/464xlatcfg $(1)/sbin
endef

$(eval $(call KernelPackage,nat46))
$(eval $(call BuildPackage,map-t))
$(eval $(call BuildPackage,464xlat))
