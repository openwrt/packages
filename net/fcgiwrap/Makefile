#
# Copyright (C) 2017 Alf Brand <git.alf@alftand.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fcgiwrap
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@DISTFILES
PKG_HASH:=4c7de0db2634c38297d5fcef61ab4a3e21856dd7247d49c33d9b19542bd1c61f

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Alf Brand <git.alf@alftand.de>

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/autotools.mk

define Package/fcgiwrap
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=FastCGI Wrapper
  URL:=https://github.com/gnosek/fcgiwrap
  DEPENDS:=+fcgi +spawn-fcgi
endef

define Package/fcgiwrap/description
  Wraps the CGI Protocol in FastCGI
endef

define Package/fcgiwrap/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call BuildPackage,fcgiwrap))
