#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=kplex
PKG_VERSION:=20150809

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/stripydog/kplex.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=fec47cd1877ec7903969adefa4220838a706d940
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/kplex
  SECTION:=net
  CATEGORY:=Network
  TITLE:=NMEA-0183 multiplexer and router
  DEPENDS:=+libpthread
  URL:=http://www.stripydog.com/kplex/
endef

define Package/kplex/description
  Kplex is a program for combining and routing NMEA-0183 data to and from multiple
  sources and destinations. kplex inputs and outputs may be any of Serial lines,
  Pseudo Terminals (ptys), Network Interfaces and Files.
endef

define Package/kplex/conffiles
/etc/kplex.conf
endef

define Package/kplex/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/kplex $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/kplex.init $(1)/etc/init.d/kplex
endef

$(eval $(call BuildPackage,kplex))
