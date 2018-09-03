#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=umurmur
PKG_VERSION:=0.2.17
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=d41db898c826077735d48ec1d1ff9ed200d6520f46ae3dbb0a89dfaad49310cd
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/umurmur/umurmur.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c4f6b1f6d27f7d7a556d30aedee73a675b5a6c48

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
  URL:=http://umurmur.net
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

define Build/Compile
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	$(MAKE) -C $(PKG_BUILD_DIR)/src all
endef

define Package/umurmur-openssl/conffiles
/etc/umurmur.conf
endef

Package/umurmur-mbedtls/conffiles = $(Package/umurmur-openssl/conffiles)

define Package/umurmur-openssl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/umurmurd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/openwrt/files/umurmur.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/umurmur.init $(1)/etc/init.d/umurmur
	$(INSTALL_DIR) $(1)/etc/umurmur
endef

Package/umurmur-mbedtls/install = $(Package/umurmur-openssl/install)

ifeq ($(BUILD_VARIANT),openssl)
  CONFIGURE_ARGS += \
	--with-ssl=openssl
endif

ifeq ($(BUILD_VARIANT),mbedtls)
  CONFIGURE_ARGS += \
	--with-ssl=mbedtls
endif

$(eval $(call BuildPackage,umurmur-openssl))
$(eval $(call BuildPackage,umurmur-mbedtls))
