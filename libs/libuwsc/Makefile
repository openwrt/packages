#
# Copyright (C) 2018 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libuwsc
PKG_VERSION:=2.0.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL=https://github.com/zhaojh329/libuwsc.git
PKG_MIRROR_HASH:=8f384a41aa9adf50fefa933a01b695d1bb6505af03d6c0cb3506283fc0229b34
CMAKE_INSTALL:=1

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libuwsc/default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=Lightweight WebSocket client library
  DEPENDS:=+libubox
endef

define Package/libuwsc-nossl
  $(Package/libuwsc/default)
  TITLE += (NO SSL)
  VARIANT:=nossl
endef

define Package/libuwsc-openssl
  $(Package/libuwsc/default)
  TITLE += (openssl)
  DEPENDS += +libustream-openssl
  VARIANT:=openssl
endef

define Package/libuwsc-wolfssl
  $(Package/libuwsc/default)
  TITLE += (wolfssl)
  DEPENDS += +libustream-wolfssl
  VARIANT:=wolfssl
endef

define Package/libuwsc-mbedtls
  $(Package/libuwsc/default)
  TITLE += (mbedtls)
  DEPENDS += +libustream-mbedtls
  VARIANT:=mbedtls
endef

ifeq ($(BUILD_VARIANT),nossl)
  CMAKE_OPTIONS += -DUWSC_SSL_SUPPORT=off
endif

define Package/libuwsc/default/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libuwsc.so* $(1)/usr/lib/
endef

Package/libuwsc-nossl/install = $(Package/libuwsc/default/install)
Package/libuwsc-openssl/install = $(Package/libuwsc/default/install)
Package/libuwsc-wolfssl/install = $(Package/libuwsc/default/install)
Package/libuwsc-mbedtls/install = $(Package/libuwsc/default/install)

$(eval $(call BuildPackage,libuwsc-nossl))
$(eval $(call BuildPackage,libuwsc-mbedtls))
$(eval $(call BuildPackage,libuwsc-wolfssl))
$(eval $(call BuildPackage,libuwsc-openssl))
