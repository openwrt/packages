#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ser2net
PKG_VERSION:=2.10.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/ser2net
PKG_MD5SUM:=cd937041144de83d41d811521e72158c

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ser2net
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Serial to Network Proxy
  URL:=http://sourceforge.net/projects/ser2net/
endef

define Package/ser2net/description
  This project provides a proxy that allows telnet/tcp connections to be made to
  serial ports on a machine.
endef

define Package/ser2net/conffiles
/etc/ser2net.conf
endef

define Package/ser2net/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/ser2net $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/ser2net.conf $(1)/etc/
endef

$(eval $(call BuildPackage,ser2net))
