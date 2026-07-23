#
# Copyright (C) 2009-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=prosody
PKG_VERSION:=13.0.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://prosody.im/downloads/source
PKG_HASH:=ec696f9cf562c3af4a04b07d3fb36a1cedcc4e69a392fddcfc524bc67d93050f

PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=MIT/X11
PKG_CPE_ID:=cpe:/a:prosody:prosody

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=lua5.4/host

include $(INCLUDE_DIR)/package.mk

define Package/prosody
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Instant Messaging
  DEPENDS:=+libidn +libopenssl +liblua5.4 +lua5.4 \
           +luafilesystem5.4 +luaexpat5.4 +luasec5.4 +luasocket5.4
  TITLE:=XMPP server
  URL:=https://prosody.im/
  USERID:=prosody=54:prosody=54
endef

define Package/prosody/description
  Prosody is a modern XMPP/Jabber communication server, written in Lua.
  It aims to be easy to set up and configure, and efficient with system
  resources.
endef

define Package/prosody/conffiles
/etc/prosody/prosody.cfg.lua
endef

TARGET_CFLAGS += $(FPIC) -I$(STAGING_DIR)/usr/include/lua5.4
TARGET_LDFLAGS += -shared

MAKE_FLAGS += LD="$(TARGET_CC)" TARGET="../util/"

define Build/Configure
	# this is *NOT* GNU autoconf stuff
	(cd $(PKG_BUILD_DIR); ./configure \
		--prefix=/usr \
		--ostype=linux \
		--lua-version=5.4 \
		--with-lua="$(STAGING_DIR_HOSTPKG)" \
		--with-lua-include="$(STAGING_DIR)/usr/include/lua5.4" \
		--with-lua-lib="$(STAGING_DIR)/usr/lib" \
		--runwith=lua5.4 \
		--idn-library=idn \
		--cflags="$(TARGET_CFLAGS)" \
		--ldflags="$(TARGET_LDFLAGS)" \
		--c-compiler="$(CC)" \
		--datadir="/etc/prosody/data" \
	)
endef

define Package/prosody/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/prosody.init $(1)/etc/init.d/prosody
	$(INSTALL_DIR) $(1)/etc/prosody
	$(INSTALL_DATA) ./files/prosody.cfg.lua $(1)/etc/prosody/
	$(INSTALL_DIR) $(1)/etc/prosody/certs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/prosody/certs/localhost.{crt,key} $(1)/etc/prosody/certs/
	$(INSTALL_DIR) $(1)/etc/prosody/data
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/prosody{,ctl} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/prosody
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/prosody/prosody.version $(1)/usr/lib/prosody/
	# maps the 13.x "prosody.*" requires onto the installed layout
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/loader.lua $(1)/usr/lib/prosody/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/core
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/core/*.lua $(1)/usr/lib/prosody/core/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/fallbacks
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/fallbacks/*.lua $(1)/usr/lib/prosody/fallbacks/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/modules
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/modules/*.lua $(1)/usr/lib/prosody/modules/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/modules/adhoc
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/modules/adhoc/*.lua $(1)/usr/lib/prosody/modules/adhoc/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/modules/muc
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/modules/muc/*.lua $(1)/usr/lib/prosody/modules/muc/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/modules/mod_pubsub
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/modules/mod_pubsub/*.lua $(1)/usr/lib/prosody/modules/mod_pubsub/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/modules/mod_mam
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/modules/mod_mam/*.lua $(1)/usr/lib/prosody/modules/mod_mam/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/modules/mod_debug_stanzas
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/modules/mod_debug_stanzas/*.lua $(1)/usr/lib/prosody/modules/mod_debug_stanzas/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/net
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/net/*.lua $(1)/usr/lib/prosody/net/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/net/http
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/net/http/*.lua $(1)/usr/lib/prosody/net/http/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/net/resolvers
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/net/resolvers/*.lua $(1)/usr/lib/prosody/net/resolvers/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/net/websocket
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/net/websocket/*.lua $(1)/usr/lib/prosody/net/websocket/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/util
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/util/*.lua $(1)/usr/lib/prosody/util/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/prosody/util/*.so $(1)/usr/lib/prosody/util/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/util/sasl
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/util/sasl/*.lua $(1)/usr/lib/prosody/util/sasl/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/util/human
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/util/human/*.lua $(1)/usr/lib/prosody/util/human/
	$(INSTALL_DIR) $(1)/usr/lib/prosody/util/prosodyctl
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/prosody/util/prosodyctl/*.lua $(1)/usr/lib/prosody/util/prosodyctl/
endef

$(eval $(call BuildPackage,prosody))
