#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yaaw
PKG_VERSION:=2016-05-28
PKG_RELEASE:=1
PKG_MAINTAINER:=Hsing-Wang Liao <kuoruan@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/binux/yaaw.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=c28cde2252b707fe0661693f78c5e5e3beee09a1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_LICENSE:=LGPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/yaaw
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Download Manager
  DEPENDS:=
  TITLE:=Yet another aria2 web frontend
  URL:=https://github.com/binux/yaaw
  PKGARCH:=all
endef

define Package/yaaw/description
	Yet Another Aria2 Web Frontend in pure HTML/CSS/Javascirpt.
endef

define Build/Compile
endef

define Package/yaaw/install
	$(INSTALL_DIR) $(1)/www/yaaw
	$(CP) $(PKG_BUILD_DIR)/js $(1)/www/yaaw
	$(CP) $(PKG_BUILD_DIR)/img $(1)/www/yaaw
	$(CP) $(PKG_BUILD_DIR)/css $(1)/www/yaaw
	$(CP) $(PKG_BUILD_DIR)/index.html $(1)/www/yaaw
	$(CP) $(PKG_BUILD_DIR)/offline.appcache $(1)/www/yaaw
endef

$(eval $(call BuildPackage,yaaw))
