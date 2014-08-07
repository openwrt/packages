#
# Copyright (C) 2009-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sslh
PKG_VERSION:=v1.16
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://rutschle.net/tech/
PKG_MD5SUM:=c6e7d1cb0adb15f6efe480e36d98c560

include $(INCLUDE_DIR)/package.mk

define Package/sslh
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=SSL/SSH multiplexer
  URL:=http://rutschle.net/tech/sslh.shtml
  MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
endef

define Package/sslh/conffiles
/etc/config/sslh
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		USELIBCONFIG= \
		USELIBWRAP= \
		all
endef

define Package/sslh/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sslh-fork $(1)/usr/sbin/sslh
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
endef

$(eval $(call BuildPackage,sslh))
