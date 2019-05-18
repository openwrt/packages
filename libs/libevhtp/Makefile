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
PKG_VERSION:=1.2.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/criticalstack/libevhtp/tar.gz/$(PKG_VERSION)?
PKG_HASH:=d8d98072693f5f68ccd74d327dedfa2f6add4446ac2799689c2f58dd480aa301

PKG_MAINTAINER:=
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
    DEPENDS:=+libevent2 +libevent2-openssl +libevent2-pthreads
endef

define Package/libevhtp/description
   Libevhtp was created as a replacement API for Libevent's current HTTP API.
   The reality of libevent's http interface is that it was created as a JIT server,
   meaning the developer never thought of it being used for creating a full-fledged HTTP service.
endef

$(eval $(call BuildPackage,libevhtp))
