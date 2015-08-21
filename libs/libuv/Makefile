#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libuv
PKG_VERSION:=1.4.2
PKG_RELEASE:=1

PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://dist.libuv.org/dist/v$(PKG_VERSION)/
PKG_MD5SUM:=d116fbe695157b799fb8805477e24eff

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libuv
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Cross-platform asychronous I/O library
  URL:=https://github.com/libuv/libuv
  DEPENDS:=+libpthread +librt
endef

define Package/libuv/description
 libuv is a multi-platform support library with a focus on asynchronous I/O. It
 was primarily developed for use by Node.js, but it's also used by Luvit, Julia,
 pyuv, and others.
endef

define Build/Configure
	( cd $(PKG_BUILD_DIR); ./autogen.sh )
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libuv.so* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libuv.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libuv/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libuv.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libuv))
