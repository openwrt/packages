#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cgi-io
PKG_RELEASE:=20

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=$(PROJECT_GIT)/project/cgi-io.git
PKG_SOURCE_DATE:=2021-09-08
PKG_SOURCE_VERSION:=98cef9dda63623eff07bd574ad7c98ef282af18d
PKG_MIRROR_HASH:=dfbec859e261ef6851f76474739c19baaadc1e5cd3ae2d2b9d56a7782ac79963
CMAKE_INSTALL:=1

PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/cgi-io
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=+libubox +libubus
  TITLE:=CGI utility for handling up/downloading of files
endef

define Package/cgi-io/description
  This package contains an cgi utility that is useful for up/downloading files
endef

define Package/cgi-io/install
	$(INSTALL_DIR) $(1)/usr/libexec $(1)/www/cgi-bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cgi-io $(1)/usr/libexec
	$(LN) ../../usr/libexec/cgi-io $(1)/www/cgi-bin/cgi-upload
	$(LN) ../../usr/libexec/cgi-io $(1)/www/cgi-bin/cgi-download
	$(LN) ../../usr/libexec/cgi-io $(1)/www/cgi-bin/cgi-backup
	$(LN) ../../usr/libexec/cgi-io $(1)/www/cgi-bin/cgi-exec
endef

$(eval $(call BuildPackage,cgi-io))
