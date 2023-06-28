#
# Copyright (C) 2017-2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=inadyn
PKG_VERSION:=2.11.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/troglobit/inadyn/releases/download/v$(PKG_VERSION)
PKG_HASH:=9c8b2a425acb9681564e9fc25a319f2109c7d2ebe1ffe99b06d4a722efb6ecba

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/inadyn/default
  TITLE:=A Dynamic DNS client with SSL/TLS support
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  DEPENDS:=+confuse +ca-certificates
  URL:=https://troglobit.com/projects/inadyn/
endef

define Package/inadyn-openssl
  $(Package/inadyn/default)
  TITLE += (uses OpenSSL)
  VARIANT := openssl
  PROVIDES := inadyn
  DEPENDS += +PACKAGE_inadyn-openssl:libopenssl
endef

define Package/inadyn-mbedtls
  $(Package/inadyn/default)
  TITLE += (uses Mbed TLS)
  VARIANT := mbedtls
  DEPENDS += +PACKAGE_inadyn-mbedtls:libmbedtls
  CONFLICTS := inadyn-openssl
endef

CONFIGURE_ARGS += \
  --enable-shared \
  --disable-static \
  --with-pic

ifeq ($(BUILD_VARIANT),openssl)
CONFIGURE_ARGS += \
  --enable-openssl
else
CONFIGURE_ARGS += \
  --enable-mbedtls \
  MbedTLS_CFLAGS="-I$(STAGING_DIR)/usr/include" \
  MbedTLS_LIBS="-lmbedtls"
endif

define Package/inadyn-$(BUILD_VARIANT)/conffiles
/etc/inadyn.conf
endef

define Package/inadyn-$(BUILD_VARIANT)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/inadyn $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,inadyn-openssl))
$(eval $(call BuildPackage,inadyn-mbedtls))
