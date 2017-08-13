#
# Copyright (C) 2012-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=aria2
PKG_VERSION:=1.32.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/aria2/aria2/releases/download/release-$(PKG_VERSION)/
PKG_HASH:=546e9194a9135d665fce572cb93c88f30fb5601d113bfa19951107ced682dc50
PKG_INSTALL:=1

PKG_MAINTAINER:=Imre Kaloz <kaloz@openwrt.org>, Hsing-Wang Liao <kuoruan@gmail.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_CONFIG_DEPENDS := \
  ARIA2_NOSSL \
  ARIA2_OPENSSL \
  ARIA2_GNUTLS \
  ARIA2_BITTORRENT \
  ARIA2_SFTP \
  ARIA2_ASYNC_DNS \
  ARIA2_COOKIE \
  ARIA2_METALINK \
  ARIA2_EXPAT \
  ARIA2_LIBXML2

include $(INCLUDE_DIR)/package.mk

define Package/aria2/config
  source "$(SOURCE)/Config.in"
endef

define Package/aria2
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  TITLE:=lightweight download utility
  URL:=https://aria2.github.io/
  DEPENDS:=+zlib +libstdcpp +ARIA2_SFTP:libssh2 +ARIA2_ASYNC_DNS:libcares +ARIA2_COOKIE:libsqlite3 +ARIA2_LIBXML2:libxml2 +ARIA2_EXPAT:libexpat +ARIA2_OPENSSL:libopenssl +ARIA2_GNUTLS:libgnutls
  USERID:=aria2=6800:aria2=6800
endef

define Package/aria2/description
 aria2 is a lightweight multi-protocol & multi-source command-line download
 utility
endef

CONFIGURE_ARGS += \
	--disable-nls \
	$(if $(CONFIG_ARIA2_NOSSL),--disable,--enable)-ssl \
	$(if $(CONFIG_ARIA2_BITTORRENT),--enable,--disable)-bittorrent \
	$(if $(CONFIG_ARIA2_METALINK),--enable,--disable)-metalink \
	$(if $(CONFIG_ARIA2_OPENSSL),--with,--without)-openssl \
	$(if $(CONFIG_ARIA2_GNUTLS),--with,--without)-gnutls \
	$(if $(CONFIG_ARIA2_SFTP),--with,--without)-libssh2 \
	$(if $(CONFIG_ARIA2_ASYNC_DNS),--with,--without)-libcares \
	$(if $(CONFIG_ARIA2_COOKIE),--with,--without)-sqlite3 \
	$(if $(CONFIG_ARIA2_LIBXML2),--with,--without)-libxml2 \
	$(if $(CONFIG_ARIA2_EXPAT),--with,--without)-libexpat \
	--without-libnettle \
	--without-libgmp \
	--without-libgcrypt \
	--without-libuv \
	--with-libz

define Package/aria2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/aria2c $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/aria2.init $(1)/etc/init.d/aria2

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/aria2.conf $(1)/etc/config/aria2
endef

$(eval $(call BuildPackage,aria2))
