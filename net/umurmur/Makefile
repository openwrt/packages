#
# Copyright (C) 2009-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=umurmur
PKG_VERSION:=0.2.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/fatbob313/umurmur.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f66c0c3d630aaff1c4d589bc4d884067f00b6529

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

PKG_MAINTAINER:=Martin Johansson <martin@fatbob.nu>
PKG_LICENSE:=BSD-3-Clause

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/umurmur/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Instant Messaging
  TITLE:=uMurmur
  DEPENDS:=+libconfig +libprotobuf-c
  URL:=http://code.google.com/p/umurmur
  MAINTAINER:=Martin Johansson <martin@fatbob.nu>
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

define Package/umurmur-polarssl
  $(call Package/umurmur/Default)
  TITLE+= (with PolarSSL support)
  DEPENDS+= +libpolarssl
  VARIANT:=polarssl
endef

define Package/umurmur-polarssl/description
  $(call Package/umurmur/Default/description)
  Uses the PolarSSL library for SSL and crypto.
endef

define Build/Compile
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	$(MAKE) -C $(PKG_BUILD_DIR)/src all
endef

define Package/umurmur-openssl/conffiles
/etc/umurmur.conf
endef

Package/umurmur-polarssl/conffiles = $(Package/umurmur-openssl/conffiles)

define Package/umurmur-openssl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/umurmurd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/openwrt/files/umurmur.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/umurmur.init $(1)/etc/init.d/umurmur
	$(INSTALL_DIR) $(1)/etc/umurmur
endef

Package/umurmur-polarssl/install = $(Package/umurmur-openssl/install)

ifeq ($(BUILD_VARIANT),openssl)
  CONFIGURE_ARGS += \
	--with-ssl=openssl
endif

ifeq ($(BUILD_VARIANT),polarssl)
  CONFIGURE_ARGS += \
	--with-ssl=polarssl
endif

$(eval $(call BuildPackage,umurmur-openssl))
$(eval $(call BuildPackage,umurmur-polarssl))
