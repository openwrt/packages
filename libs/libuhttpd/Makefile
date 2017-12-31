#
# Copyright (C) 2014-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libuhttpd
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/zhaojh329/libuhttpd.git
PKG_SOURCE_VERSION:=4fb0f0b692daaf337bcc71ec135a6c0e8bbbb6e3
PKG_MIRROR_HASH:=d75b1edc81e2eed0d70385c1f9ff2a836c700400c71fd16d9bc4b41ec3c6f576
CMAKE_INSTALL:=1

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# CMAKE_OPTIONS += -DUHTTP_DEBUG=on

define Package/libuhttpd/default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=libuhttpd
  DEPENDS:=+libubox
endef

define Package/libuhttpd-nossl
  $(Package/libuhttpd/default)
  TITLE += (NO SSL)
  VARIANT:=nossl
endef

define Package/libuhttpd-openssl
  $(Package/libuhttpd/default)
  TITLE += (openssl)
  DEPENDS += +libustream-openssl
  VARIANT:=openssl
endef

define Package/libuhttpd-wolfssl
  $(Package/libuhttpd/default)
  TITLE += (wolfssl)
  DEPENDS += +libustream-wolfssl
  VARIANT:=wolfssl
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
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libuhttpd.so* $(1)/usr/lib/
endef

Package/libuhttpd-nossl/install = $(Package/libuhttpd/default/install)
Package/libuhttpd-openssl/install = $(Package/libuhttpd/default/install)
Package/libuhttpd-wolfssl/install = $(Package/libuhttpd/default/install)
Package/libuhttpd-mbedtls/install = $(Package/libuhttpd/default/install)

$(eval $(call BuildPackage,libuhttpd-nossl))
$(eval $(call BuildPackage,libuhttpd-mbedtls))
$(eval $(call BuildPackage,libuhttpd-wolfssl))
$(eval $(call BuildPackage,libuhttpd-openssl))
