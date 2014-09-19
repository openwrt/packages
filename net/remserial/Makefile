#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=remserial
PKG_VERSION:=1.4
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://lpccomp.bc.ca/remserial/
PKG_MD5SUM:=b19b57fd118329c5ea3aaf9887f946a6

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/remserial
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Bridge TCP/IP port with a device
  URL:=http://lpccomp.bc.ca/remserial/
endef

define Package/remserial/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/remserial $(1)/usr/bin/
endef

$(eval $(call BuildPackage,remserial))
