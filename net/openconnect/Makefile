#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openconnect
PKG_VERSION:=9.12
PKG_RELEASE:=6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.infradead.org/openconnect/download
PKG_HASH:=a2bedce3aa4dfe75e36e407e48e8e8bc91d46def5335ac9564fbf91bd4b2413e

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LGPL
PKG_CPE_ID:=cpe:/a:infradead:openconnect

PKG_CONFIG_DEPENDS:= \
	CONFIG_OPENCONNECT_GNUTLS \
	CONFIG_OPENCONNECT_OPENSSL \

PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/openconnect/config
	source "$(SOURCE)/Config.in"
endef

define Package/openconnect
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libxml2 +kmod-tun +resolveip +vpnc-scripts +OPENCONNECT_OPENSSL:libopenssl +OPENCONNECT_OPENSSL:p11-kit +OPENCONNECT_OPENSSL:libp11 +OPENCONNECT_GNUTLS:libgnutls +OPENCONNECT_GNUTLS:libtasn1 +OPENCONNECT_STOKEN:libstoken $(ICONV_DEPENDS) $(INTL_DEPENDS)
  TITLE:=OpenConnect VPN client (Cisco AnyConnect and Juniper/Pulse compatible)
  MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
  URL:=https://www.infradead.org/openconnect/
  SUBMENU:=VPN
endef

define Package/openconnect/description
	A VPN client compatible with several SSL VPN implementations (ocserv, Cisco AnyConnect, Juniper, Palo Alto)

	OpenConnect is an SSL VPN client initially created to support Cisco's
	AnyConnect SSL VPN. It has since been extended to support the Pulse Connect
	Secure VPN (formerly known as Juniper Network Connect or Junos Pulse) and
	the Palo Alto Networks GlobalProtect SSL VPN.

	A corresponding OpenConnect VPN server implementation can be found in the
	ocserv package.
endef

CONFIGURE_ARGS += \
	--disable-shared \
	--with-libiconv-prefix=$(ICONV_PREFIX) \
	--with-libintl-prefix=$(INTL_PREFIX) \
	--with-vpnc-script=/lib/netifd/vpnc-script \
	--without-libpcsclite \
	--without-stoken \
	--without-libpskc \
	--without-gssapi \
	--without-lz4

ifeq ($(CONFIG_OPENCONNECT_OPENSSL),y)
CONFIGURE_ARGS += \
	--without-gnutls
endif

ifeq ($(CONFIG_OPENCONNECT_STOKEN),y)
CONFIGURE_ARGS += \
	--with-stoken
endif

define Package/openconnect/install
	$(INSTALL_DIR) $(1)/etc/openconnect/
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/openconnect.sh $(1)/lib/netifd/proto/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openconnect $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/openconnect-wrapper $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/openconnect.upgrade $(1)/lib/upgrade/keep.d/openconnect
endef

$(eval $(call BuildPackage,openconnect))
