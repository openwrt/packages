#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=transmission
PKG_VERSION:=2.92
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/transmission/transmission-releases/raw/master
PKG_MD5SUM:=3fce404a436e3cd7fde80fb6ed61c264

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/transmission/template
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BitTorrent client
  URL:=http://www.transmissionbt.com
  MAINTAINER:=Cezary Jackiewicz <cezary@eko.one.pl>
endef

define Package/transmission-daemon/Default
  $(call Package/transmission/template)
  DEPENDS:=+libcurl +libpthread +libevent2 +librt +zlib
  USERID:=transmission=224:transmission=224
endef

define Package/transmission-daemon-openssl
  $(call Package/transmission-daemon/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+=+libopenssl
  VARIANT:=openssl
endef

define Package/transmission-daemon-polarssl
  $(call Package/transmission-daemon/Default)
  TITLE+= (with PolarSSL)
  DEPENDS+=+libpolarssl
  VARIANT:=polarssl
endef

define Package/transmission-cli/Default
  $(call Package/transmission/template)
  DEPENDS:=+libcurl +libpthread +libevent2 +librt +zlib
endef

define Package/transmission-cli-openssl
  $(call Package/transmission-cli/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+=+libopenssl
  VARIANT:=openssl
endef

define Package/transmission-cli-polarssl
  $(call Package/transmission-cli/Default)
  TITLE+= (with PolarSSL)
  DEPENDS+=+libpolarssl
  VARIANT:=polarssl
endef

define Package/transmission-remote/Default
  $(call Package/transmission/template)
  DEPENDS:=+libcurl +libpthread +libevent2 +librt +zlib
endef

define Package/transmission-remote-openssl
  $(call Package/transmission-remote/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+=+libopenssl
  VARIANT:=openssl
endef

define Package/transmission-remote-polarssl
  $(call Package/transmission-remote/Default)
  TITLE+= (with PolarSSL)
  DEPENDS+=+libpolarssl
  VARIANT:=polarssl
endef

define Package/transmission-web
  $(call Package/transmission/template)
  TITLE+= (webinterface)
  DEPENDS:=@(PACKAGE_transmission-daemon-openssl||PACKAGE_transmission-daemon-polarssl)
endef


define Package/transmission-daemon/Default/description
 Transmission is a simple BitTorrent client.
 It features a very simple, intuitive interface
 on top on an efficient, cross-platform back-end.
 This package contains the daemon itself.
endef
Package/transmission-daemon-openssl/description = $(Package/transmission-daemon/Default/description)
Package/transmission-daemon-polarssl/description = $(Package/transmission-daemon/Default/description)

define Package/transmission-cli/Default/description
 CLI utilities for transmission.
endef
Package/transmission-cli-openssl/description = $(Package/transmission-cli/Default/description)
Package/transmission-cli-polarssl/description = $(Package/transmission-cli/Default/description)

define Package/transmission-remote/Default/description
 CLI remote interface for transmission.
endef
Package/transmission-remote-openssl/description = $(Package/transmission-remote/Default/description)
Package/transmission-remote-polarssl/description = $(Package/transmission-remote/Default/description)

define Package/transmission-web/description
 Webinterface resources for transmission.
endef

define Package/transmission-daemon-openssl/conffiles
/etc/config/transmission
endef
Package/transmission-daemon-polarssl/conffiles = $(Package/transmission-daemon-openssl/conffiles)


CONFIGURE_VARS += \
	LIBEVENT_LIBS="$(STAGING_DIR)/usr/lib/libevent-2.0.so.5"

CONFIGURE_ARGS += \
	--enable-daemon \
	--enable-cli \
	--without-gtk \
	--enable-largefile \
	--enable-lightweight

ifeq ($(BUILD_VARIANT),openssl)
  CONFIGURE_ARGS += \
	--with-crypto=openssl
endif

ifeq ($(BUILD_VARIANT),polarssl)
  CONFIGURE_ARGS += \
	--with-crypto=polarssl
endif

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE"

TARGET_CFLAGS += -std=gnu99

define Package/transmission-daemon-openssl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-daemon $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/transmission.init $(1)/etc/init.d/transmission
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/transmission.config $(1)/etc/config/transmission
endef
Package/transmission-daemon-polarssl/install = $(Package/transmission-daemon-openssl/install)

define Package/transmission-cli-openssl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-cli \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-create \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-edit \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-show \
			$(1)/usr/bin/
endef
Package/transmission-cli-polarssl/install = $(Package/transmission-cli-openssl/install)

define Package/transmission-remote-openssl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-remote $(1)/usr/bin/
endef
Package/transmission-remote-polarssl/install = $(Package/transmission-remote-openssl/install)

define Package/transmission-web/install
	$(INSTALL_DIR) $(1)/usr/share/transmission
	$(CP) $(PKG_INSTALL_DIR)/usr/share/transmission/web $(1)/usr/share/transmission/
endef

$(eval $(call BuildPackage,transmission-daemon-openssl))
$(eval $(call BuildPackage,transmission-daemon-polarssl))
$(eval $(call BuildPackage,transmission-cli-openssl))
$(eval $(call BuildPackage,transmission-cli-polarssl))
$(eval $(call BuildPackage,transmission-remote-openssl))
$(eval $(call BuildPackage,transmission-remote-polarssl))
$(eval $(call BuildPackage,transmission-web))
