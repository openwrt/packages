#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=radsecproxy
PKG_VERSION:=1.6.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://software.uninett.no/radsecproxy/
PKG_MD5SUM:=b868f7faf4887a10376d1bd96ef75368

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/radsecproxy
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libopenssl +libpthread
  TITLE:=radsecproxy
  URL:=http://software.uninett.no/radsecproxy
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
endef

define Package/radsecproxy/description
  A generic radius proxy for UDP/TLS (RadSec)
endef

CONFIGURE_ARGS+= \
	--with-ssl="$(STAGING_DIR)/usr"

#TARGET_CFLAGS += -ansi
#TARGET_CFLAGS += -std=c99
TARGET_CFLAGS += -Wno-long-long


define Package/radsecproxy/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/radsecproxy $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DATA) ./files/radsecproxy.conf $(1)/etc/config/radsecproxy
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/radsecproxy.init $(1)/etc/init.d/radsecproxy
endef

define Package/radsecproxy/conffiles
/etc/config/radsecproxy
endef

$(eval $(call BuildPackage,radsecproxy))

