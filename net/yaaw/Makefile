#
# Copyright (C) 2016-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yaaw
PKG_VERSION:=2017-04-11
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/binux/yaaw.git
PKG_SOURCE_VERSION:=d3a8346c5b9c2c1875dc79e1db2533b584fc8def

PKG_LICENSE:=LGPL-3.0
PKG_MAINTAINER:=Hsing-Wang Liao <kuoruan@gmail.com>

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
	$(CP) \
		$(PKG_BUILD_DIR)/{css,img,js} \
		$(1)/www/yaaw
	$(CP) \
		$(PKG_BUILD_DIR)/{index.html,offline.appcache} \
		$(1)/www/yaaw
endef

$(eval $(call BuildPackage,yaaw))
