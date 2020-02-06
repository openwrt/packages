#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rsyslog
PKG_VERSION:=8.39.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.rsyslog.com/files/download/rsyslog/
PKG_HASH:=c71f96fed6538de397df25da602384f6ee2cb67329d9f3362af2a18508616ab4

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:rsyslog:rsyslog

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/rsyslog
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Enhanced system logging and kernel message trapping daemons
  URL:=https://www.rsyslog.com/
  DEPENDS:=+libestr +libfastjson +libuuid +zlib
endef

define Package/rsyslog/conffiles
/etc/rsyslog.conf
endef

CONFIGURE_ARGS+= \
	--disable-libgcrypt \
	--disable-fmhttp \
	--disable-default-tests \
	--disable-libsystemd

define Package/rsyslog/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/rsyslogd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib/rsyslog
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/rsyslog/* $(1)/usr/lib/rsyslog/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/rsyslog.conf $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rsyslog.init $(1)/etc/init.d/rsyslog
endef

$(eval $(call BuildPackage,rsyslog))
