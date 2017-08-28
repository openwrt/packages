#
# Copyright (C) 2009-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sslh
PKG_VERSION:=v1.18
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://rutschle.net/tech/sslh/
PKG_HASH:=1601a5b377dcafc6b47d2fbb8d4d25cceb83053a4adcc5874d501a2d5a7745ad
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/sslh
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=SSL/SSH multiplexer
  DEPENDS:=+libconfig +USE_UCLIBC:libpcre +USE_MUSL:libpcre
  URL:=http://rutschle.net/tech/sslh.shtml
  PKG_MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
endef

define Package/sslh/conffiles
/etc/config/sslh
/etc/sslh.conf
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		ENABLE_REGEX=1 \
		USELIBCONFIG=1 \
		USELIBWRAP= \
		USELIBPCRE= \
		$(if $(CONFIG_USE_GLIBC),USELIBPCRE=,USELIBPCRE=1)\
		all
endef

define Package/sslh/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sslh-fork $(1)/usr/sbin/sslh
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/basic.cfg $(1)/etc/sslh.conf
endef

$(eval $(call BuildPackage,sslh))
