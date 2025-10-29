#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=umurmur
PKG_VERSION:=0.3.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/umurmur/umurmur/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8327dd0b2c5bd187a38d098295e896a6b85d698c9268205bcb27f6244f760a73

PKG_MAINTAINER:=Martin Johansson <martin@fatbob.nu>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/umurmur/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Instant Messaging
  TITLE:=uMurmur
  DEPENDS:=+libconfig +libprotobuf-c
  URL:=https://umurmur.net
endef

define Package/umurmur/Default/description
  Minimalistic Mumble server daemon.
endef

define Package/umurmur-openssl
  $(call Package/umurmur/Default)
  TITLE+= (with OpenSSL support)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/umurmur-openssl/description
  $(call Package/umurmur/Default/description)
  Uses OpenSSL library for SSL and crypto.
endef

define Package/umurmur-mbedtls
  $(call Package/umurmur/Default)
  TITLE+= (with mbed TLS support)
  DEPENDS+= +libmbedtls
  VARIANT:=mbedtls
endef

define Package/umurmur-mbedtls/description
  $(call Package/umurmur/Default/description)
  Uses the mbed TLS library for SSL and crypto.
endef

define Package/umurmur-openssl/conffiles
/etc/umurmur/umurmur.conf
endef

Package/umurmur-mbedtls/conffiles = $(Package/umurmur-openssl/conffiles)

define Package/umurmur-openssl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/umurmurd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/umurmur/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/openwrt/files/umurmur.conf $(1)/etc/umurmur/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/umurmur.init $(1)/etc/init.d/umurmur
endef

Package/umurmur-mbedtls/install = $(Package/umurmur-openssl/install)

CMAKE_OPTIONS += \
	-DLIBCONFIG_INCLUDE_DIR="$(STAGING_DIR)/usr/include" \
	-DLIBCONFIG_LIBRARIES="$(STAGING_DIR)/usr/lib/libconfig.so" \
	-DLIBCONFIG_LIB_DIR="$(STAGING_DIR)/usr/lib" \
	-DPROTOBUFC_INCLUDE_DIR="$(STAGING_DIR)/usr/include" \
	-DPROTOBUFC_LIBRARIES="$(STAGING_DIR)/usr/lib/libprotobuf-c.so" \
	-DPROTOBUFC_LIB_DIR="$(STAGING_DIR)/usr/lib"

ifeq ($(BUILD_VARIANT),openssl)
CMAKE_OPTIONS += -DSSL=openssl
else
CMAKE_OPTIONS += -DSSL=mbedtls \
	-DMBEDTLS_INCLUDE_DIR="$(STAGING_DIR)/usr/include/mbedtls" \
	-DMBEDTLS_LIBRARIES="$(STAGING_DIR)/usr/lib" \
	-DMBEDTLS_LIB_DIR="$(STAGING_DIR)/usr/lib"
endif

$(eval $(call BuildPackage,umurmur-openssl))
$(eval $(call BuildPackage,umurmur-mbedtls))
