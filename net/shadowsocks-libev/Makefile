#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-libev
PKG_VERSION:=2.5.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-libev.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_SOURCE_VERSION:=983c1dcac0e845f68616bf55eea3cc8d5aa711df
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocks-libev/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy $(2)
	URL:=https://github.com/shadowsocks/shadowsocks-libev
	VARIANT:=$(1)
	DEPENDS:=$(3) +libpthread
endef

Package/shadowsocks-libev = $(call Package/shadowsocks-libev/Default,openssl,(OpenSSL),+libopenssl)
Package/shadowsocks-libev-server = $(call Package/shadowsocks-libev/Default,openssl,(OpenSSL),+libopenssl)
Package/shadowsocks-libev-polarssl = $(call Package/shadowsocks-libev/Default,polarssl,(PolarSSL),+libpolarssl)
Package/shadowsocks-libev-server-polarssl = $(call Package/shadowsocks-libev/Default,polarssl,(PolarSSL),+libpolarssl)

define Package/shadowsocks-libev/description
Shadowsocks-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

Package/shadowsocks-libev-server/description = $(Package/shadowsocks-libev/description)
Package/shadowsocks-libev-polarssl/description = $(Package/shadowsocks-libev/description)
Package/shadowsocks-libev-server-polarssl/description = $(Package/shadowsocks-libev/description)

CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert

ifeq ($(BUILD_VARIANT),polarssl)
	CONFIGURE_ARGS += --with-crypto-library=polarssl
endif

define Package/shadowsocks-libev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel} $(1)/usr/bin
endef

Package/shadowsocks-libev-polarssl/install = $(Package/shadowsocks-libev/install)

define Package/shadowsocks-libev-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-server $(1)/usr/bin
endef

Package/shadowsocks-libev-server-polarssl/install = $(Package/shadowsocks-libev-server/install)

$(eval $(call BuildPackage,shadowsocks-libev))
$(eval $(call BuildPackage,shadowsocks-libev-server))
$(eval $(call BuildPackage,shadowsocks-libev-polarssl))
$(eval $(call BuildPackage,shadowsocks-libev-server-polarssl))
