#
# Copyright (C) 2007-2017 OpenWrt.org
# Original port by FreeWRT project.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Alexander Tsvyashchenko	Created OpenWRT package as per Trac ticket 2497
#

include $(TOPDIR)/rules.mk

PKG_NAME:=daemontools
PKG_VERSION:=0.76
PKG_RELEASE:=1

PKG_SOURCE:=${PKG_NAME}-${PKG_VERSION}.tar.gz
PKG_SOURCE_URL:=http://cr.yp.to/daemontools/
PKG_HASH:=a55535012b2be7a52dcd9eccabb9a198b13be50d0384143bd3b32b8710df4c1f
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=Thomas Guyot-Sionnest <tguyot@gmail.com>
PKG_LICENSE:=Public Domain

include $(INCLUDE_DIR)/package.mk

PKG_UNPACK += && mv $(PKG_BUILD_DIR)/../admin/$(PKG_NAME)-$(PKG_VERSION)/* $(PKG_BUILD_DIR)/ && rmdir -p --ignore-fail-on-non-empty $(PKG_BUILD_DIR)/../admin/$(PKG_NAME)-$(PKG_VERSION)

define Package/daemontools
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=
  TITLE:=Tools for managing UNIX services
  URL:=http://cr.yp.to/daemontools.html
endef

define Package/daemontools/description
	Daemontools is a collection of tools for managing UNIX services by DJ Bernstein.
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	$(PKG_BUILD_DIR)/package/compile
endef

define Package/daemontools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/command/* $(1)/usr/bin
endef

$(eval $(call BuildPackage,daemontools))
