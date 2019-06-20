#
# Copyright (C) 2014-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libuhttpd
PKG_VERSION:=2.2.2
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL=https://github.com/zhaojh329/libuhttpd.git
PKG_MIRROR_HASH:=98f217238160489468fafe8c643b7f96f168c80000ee07d3ca808d54f4c6a608
CMAKE_INSTALL:=1

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libuhttpd/default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=libuhttpd
  DEPENDS:=+libubox +liblua
endef

define Package/libuhttpd-nossl
  $(Package/libuhttpd/default)
  TITLE += (NO SSL)
  VARIANT:=nossl
  CONFLICTS:=libuhttpd-openssl libuhttpd-wolfssl libuhttpd-mbedtls
endef

define Package/libuhttpd-openssl
  $(Package/libuhttpd/default)
  TITLE += (openssl)
  DEPENDS += +libustream-openssl
  VARIANT:=openssl
  CONFLICTS:=libuhttpd-wolfssl libuhttpd-mbedtls
endef

define Package/libuhttpd-wolfssl
  $(Package/libuhttpd/default)
  TITLE += (wolfssl)
  DEPENDS += +libustream-wolfssl
  VARIANT:=wolfssl
  CONFLICTS:=libuhttpd-mbedtls
endef

define Package/libuhttpd-mbedtls
  $(Package/libuhttpd/default)
  TITLE += (mbedtls)
  DEPENDS += +libustream-mbedtls
  VARIANT:=mbedtls
endef

ifeq ($(BUILD_VARIANT),nossl)
  CMAKE_OPTIONS += -DUHTTPD_SSL_SUPPORT=off
endif

define Package/libuhttpd/default/install
	$(INSTALL_DIR) $(1)/usr/lib/ $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuhttpd.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/uhttpd.so* $(1)/usr/lib/lua/
endef

Package/libuhttpd-nossl/install = $(Package/libuhttpd/default/install)
Package/libuhttpd-openssl/install = $(Package/libuhttpd/default/install)
Package/libuhttpd-wolfssl/install = $(Package/libuhttpd/default/install)
Package/libuhttpd-mbedtls/install = $(Package/libuhttpd/default/install)

$(eval $(call BuildPackage,libuhttpd-nossl))
$(eval $(call BuildPackage,libuhttpd-mbedtls))
$(eval $(call BuildPackage,libuhttpd-wolfssl))
$(eval $(call BuildPackage,libuhttpd-openssl))
