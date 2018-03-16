#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libumqtt
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL=https://github.com/zhaojh329/libumqtt.git
PKG_MIRROR_HASH:=
CMAKE_INSTALL:=1

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libumqtt/default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=libumqtt
  DEPENDS:=+libubox
endef

define Package/libumqtt/default/description
A Lightweight and fully asynchronous MQTT 3.1.1 client C library based on
libubox for Embedded Linux. Support QoS 0, 1 and 2. Support ssl.
endef

define Package/libumqtt-nossl
  $(Package/libumqtt/default)
  TITLE += (NO SSL)
  VARIANT:=nossl
endef

define Package/libumqtt-openssl
  $(Package/libumqtt/default)
  TITLE += (openssl)
  DEPENDS += +libustream-openssl
  VARIANT:=openssl
endef

define Package/libumqtt-wolfssl
  $(Package/libumqtt/default)
  TITLE += (wolfssl)
  DEPENDS += +libustream-wolfssl
  VARIANT:=wolfssl
endef

define Package/libumqtt-mbedtls
  $(Package/libumqtt/default)
  TITLE += (mbedtls)
  DEPENDS += +libustream-mbedtls
  VARIANT:=mbedtls
endef

Package/libumqtt-nossl/description = $(Package/libumqtt/default/description)
Package/libumqtt-openssl/description = $(Package/libumqtt/default/description)
Package/libumqtt-wolfssl/description = $(Package/libumqtt/default/description)
Package/libumqtt-mbedtls/description = $(Package/libumqtt/default/description)

ifeq ($(BUILD_VARIANT),nossl)
  CMAKE_OPTIONS += -DUMQTT_SSL_SUPPORT=off
endif

define Package/libumqtt/default/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libumqtt.so* $(1)/usr/lib/
endef

Package/libumqtt-nossl/install = $(Package/libumqtt/default/install)
Package/libumqtt-openssl/install = $(Package/libumqtt/default/install)
Package/libumqtt-wolfssl/install = $(Package/libumqtt/default/install)
Package/libumqtt-mbedtls/install = $(Package/libumqtt/default/install)

$(eval $(call BuildPackage,libumqtt-nossl))
$(eval $(call BuildPackage,libumqtt-mbedtls))
$(eval $(call BuildPackage,libumqtt-wolfssl))
$(eval $(call BuildPackage,libumqtt-openssl))
