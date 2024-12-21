#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vpnc
PKG_SOURCE_DATE:=2024-12-20
PKG_SOURCE_VERSION:=d58afaaafb6a43cb21bb08282b54480d7b2cc6ab
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/streambinder/vpnc
PKG_MIRROR_HASH:=1058679c951db0f53de4cd22942bb6d2c80647bb13fb62a70d71316ce7544fc4

PKG_MAINTAINER:=Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_VPNC_GNUTLS \
	CONFIG_VPNC_OPENSSL \


include $(INCLUDE_DIR)/package.mk

define Package/vpnc/config
	source "$(SOURCE)/Config.in"
endef

define Package/vpnc/default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=\
	  +libgpg-error \
	  +libgcrypt \
	  +kmod-tun \
	  +vpnc-scripts \
	  +resolveip \

  TITLE:=VPN client for Cisco EasyVPN
  URL:=https://davidepucci.it/doc/vpnc/
  SUBMENU:=VPN
  PROVIDES:=vpnc
endef

define Package/vpnc-nossl
  $(call Package/vpnc/default)
  TITLE+= (without SSL)
  VARIANT:=nossl
endef

define Package/vpnc
  $(call Package/vpnc/default)
  TITLE+= (with SSL)
  DEPENDS+= +VPNC_OPENSSL:libopenssl \
            +VPNC_GNUTLS:libgnutls
  VARIANT:=ssl
endef

define Package/vpnc/default/description
	A VPN client compatible with Cisco's EasyVPN equipment.

	Supports IPSec (ESP) with Mode Configuration and Xauth.  Supports only
	shared-secret IPSec authentication with Xauth, AES (256, 192, 128),
	3DES, 1DES, MD5, SHA1, DH1/2/5/14/15/16/17/18 and IP tunneling.
endef

define Package/vpnc/description
	$(call Package/vpnc/default/description)
	This package is built with SSL support.
	This is needed for VPN connections which rely on SSL certificates.
	(It supports all types of connections vpnc handles.)
	If your router does not have space available for a TLS library
	and your endpoint is using a pre-shared group key, you can install
	the vpnc-nossl package instead. This will not affect the security
	of your connection.
endef

define Package/vpnc-nossl/description
	$(call Package/vpnc/default/description)
	This package is built without SSL support.
	It will only support connections with a pre-shared group key.
	(For example it allows connectiong to an AVM FRITZ!Box.)
	If this package allows you to connect to your remote endpoint,
	it means your endpoint is not using SSL and the regular package
	would only take up more space. If your endpoint uses SSL, this
	version will refuse to connect.
endef

define Package/vpnc-default/conffiles
/etc/vpnc/default.conf
endef

ifeq ($(BUILD_VARIANT),ssl)
  OPENSSL-y:=OPENSSL_GPL_VIOLATION=yes
endif

ifeq ($(BUILD_VARIANT),nossl)
  CRYPTO_NONE_MAKEFLAG:=CRYPTO_NONE=yes
endif

define Build/Compile
	mkdir $(PKG_BUILD_DIR)/bin
	$(call Build/Compile/Default, \
		OFLAGS="$(TARGET_CFLAGS)" \
		OS="Linux" \
		VERSION="$(PKG_VERSION)" \
		$(OPENSSL-$(CONFIG_VPNC_OPENSSL)) \
                $(CRYPTO_NONE_MAKEFLAG) \
		$(PKG_BUILD_DIR)/bin/vpnc \
	)
endef

define Package/vpnc/install
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/vpnc.sh $(1)/lib/netifd/proto/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP)	$(PKG_BUILD_DIR)/bin/vpnc \
		$(PKG_BUILD_DIR)/src/vpnc-disconnect \
		$(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/vpnc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/src/vpnc.conf $(1)/etc/vpnc/default.conf
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/vpnc.upgrade $(1)/lib/upgrade/keep.d/vpnc
endef

Package/vpnc-nossl/install=$(Package/vpnc/install)

$(eval $(call BuildPackage,vpnc))
$(eval $(call BuildPackage,vpnc-nossl))
