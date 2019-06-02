#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# NOTE: please DO NOT update this package without the maintainer's consent.
# See https://github.com/haiwen/seafile/issues/1119

include $(TOPDIR)/rules.mk

PKG_NAME:=libevhtp
PKG_VERSION:=1.2.18
PKG_RELEASE:=2
# This package is building a static library, used by seafile-server
# Every time the built library changes (metadata changes are exempt),
# seafile-server needs a release bump to ensure the update is used.

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/criticalstack/libevhtp/tar.gz/$(PKG_VERSION)?
PKG_HASH:=316ede0d672be3ae6fe489d4ac1c8c53a1db7d4fe05edaff3c7c853933e02795

PKG_MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libevhtp
    SECTION:=libs
    CATEGORY:=Libraries
    TITLE:=A more flexible replacement for libevent's httpd API
    URL:=https://github.com/criticalstack/libevhtp
    DEPENDS:=+libevent2 +libevent2-openssl +libevent2-pthreads +oniguruma
endef

define Package/libevhtp/description
   Libevhtp was created as a replacement API for Libevent's current HTTP API.
   The reality of libevent's http interface is that it was created as a JIT server,
   meaning the developer never thought of it being used for creating a full-fledged HTTP service.
endef

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,^\(include\|lib\)dir=,\0$(STAGING_DIR)/usr/\1,' "$(1)/usr/lib/pkgconfig/evhtp.pc"
endef

$(eval $(call BuildPackage,libevhtp))
