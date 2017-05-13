#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=softflowd
PKG_VERSION:=0.9.9
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://softflowd.googlecode.com/files/
PKG_MD5SUM:=ba83e2715e6250e6645ebcaa9ae1009d
PKG_MAINTAINER:=Ross Vandegrift <ross@kallisti.us>
PKG_LICENSE:=BSD-3-Clause

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/softflowd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap
  TITLE:=softflowd
  URL:=http://code.google.com/p/softflowd/
endef

define Package/softflowd/description
	Software netflow exporter
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR="$(PKG_INSTALL_DIR)" softflowd softflowctl
endef

define Package/softflowd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/softflowd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/softflowctl $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef

define Package/softflowd/conffiles
/etc/config/softflowd
endef

$(eval $(call BuildPackage,softflowd))
