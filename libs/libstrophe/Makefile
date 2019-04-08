#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libstrophe
PKG_VERSION:=0.9.2
PKG_RELEASE=2

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Chih-Wei Chen <changeway@gmail.com>

PKG_SOURCE_URL:=https://codeload.github.com/strophe/libstrophe/tar.gz/$(PKG_VERSION)?
PKG_SOURCE_VERSION:=9931ad4fa2aa7f204c608010eb2ebf84bcf7d542
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=158145bc1565a5fd0bbd7f57e3e15d768e58b8a460897ab5918a5a689d67ae6f

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_libstrophe-libxml2 \
	CONFIG_libstrophe-expat

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_libstrophe-libxml2),y)
CONFIGURE_ARGS += \
	--with-libxml2
endif

define Package/libstrophe
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=XMPP client library
	URL:=http://strophe.im/libstrophe
	DEPENDS:= +libopenssl +libstrophe-libxml2:libxml2 +libstrophe-expat:libexpat
	MENU:=1
endef

define Package/libstrophe/description
	A simple, lightweight C library for writing XMPP clients
endef

define Package/libstrophe/config
	source "$(SOURCE)/Config.in"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ $(1)/usr/

	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libstrophe.{la,a,so*} $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libstrophe.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libstrophe/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libstrophe.so.* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libstrophe))
