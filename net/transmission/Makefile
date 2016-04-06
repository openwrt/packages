#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=transmission
PKG_VERSION:=2.92
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://download-origin.transmissionbt.com/files/ http://mirrors.m0k.org/transmission/files
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
  TITLE:=A free, lightweight BitTorrent client
  URL:=http://www.transmissionbt.com
  MAINTAINER:=Cezary Jackiewicz <cezary@eko.one.pl>
  DEPENDS:=+libcurl +libpthread +libevent2 +librt +TRANSMISSION_OPENSSL:libopenssl +TRANSMISSION_POLARSSL:libpolarssl +TRANSMISSION_POLARSSL:zlib
endef

define Package/transmission-daemon
  $(call Package/transmission/template)
  USERID:=transmission=224:transmission=224
endef

define Package/transmission-cli
  $(call Package/transmission/template)
endef

define Package/transmission-remote
  $(call Package/transmission/template)
endef

define Package/transmission-web
  $(call Package/transmission/template)
  DEPENDS:=transmission-daemon
endef


define Package/transmission-daemon/description
 Transmission is a simple BitTorrent client.
 It features a very simple, intuitive interface
 on top on an efficient, cross-platform back-end.
 This package contains the daemon itself.
endef

define Package/transmission-cli/description
 CLI utilities for transmission.
endef

define Package/transmission-remote/description
 CLI remote interface for transmission.
endef

define Package/transmission-web/description
 Webinterface resources for transmission.
endef

define Package/transmission-daemon/conffiles
/etc/config/transmission
endef

CONFIGURE_VARS += \
	LIBEVENT_LIBS="$(STAGING_DIR)/usr/lib/libevent-2.0.so.5"

CONFIGURE_ARGS += \
	$(if $(CONFIG_TRANSMISSION_OPENSSL),--with-crypto=openssl,) \
	$(if $(CONFIG_TRANSMISSION_POLARSSL),--with-crypto=polarssl,) \
	--enable-daemon \
	--enable-cli \
	--without-gtk \
	--enable-largefile \
	--enable-lightweight

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE"

TARGET_CFLAGS += -std=gnu99

define Package/transmission-daemon/config
  source "$(SOURCE)/Config.in"
endef

define Package/transmission-daemon/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-daemon $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/transmission.init $(1)/etc/init.d/transmission
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/transmission.config $(1)/etc/config/transmission
endef

define Package/transmission-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-cli \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-create \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-edit \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-show \
			$(1)/usr/bin/
endef

define Package/transmission-remote/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-remote $(1)/usr/bin/
endef

define Package/transmission-web/install
	$(INSTALL_DIR) $(1)/usr/share/transmission
	$(CP) $(PKG_INSTALL_DIR)/usr/share/transmission/web $(1)/usr/share/transmission/
endef

$(eval $(call BuildPackage,transmission-daemon))
$(eval $(call BuildPackage,transmission-cli))
$(eval $(call BuildPackage,transmission-remote))
$(eval $(call BuildPackage,transmission-web))
