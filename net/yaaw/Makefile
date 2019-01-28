#
# Copyright (C) 2016-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yaaw
PKG_SOURCE_DATE:=2017-10-15
PKG_SOURCE_VERSION:=6ac3046b49aafcfba9f65a04efcdce80150fc29a
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/binux/yaaw/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=60bc14768434fcef889621ddb9a8196d0854d319584657918f19e593f4a70c7a
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Hsing-Wang Liao <kuoruan@gmail.com>
PKG_LICENSE:=LGPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/yaaw
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Download Manager
  DEPENDS:=
  TITLE:=Yet another aria2 web frontend
  URL:=https://binux.github.io/yaaw/
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
