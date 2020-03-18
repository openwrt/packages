#
# Copyright (C) 2019 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=spice-protocol
PKG_VERSION:=0.14.1
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://www.spice-space.org/download/releases
PKG_HASH:=79e6da61834b080a143234c1cd4c099a8ead1a64b5039489610b72ab282c132a
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_INSTALL:=1
PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

include $(INCLUDE_DIR)/package.mk


define Package/spice-protocol
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=SPICE - headers defining protocols
  URL:=https://www.spice-space.org/index.html
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/share/pkgconfig/* $(1)/usr/lib/pkgconfig
endef

$(eval $(call BuildPackage,spice-protocol))
