# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021-2022 Gerald Kerma
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-cs-bouncer
PKG_SOURCE_DATE:=2022-01-18
PKG_SOURCE_VERSION:=e0f68b1265c386715c1d6ab79fe9063c0a9e3d3a
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/crowdsecurity/$(PKG_NAME)/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=c7e92cc9dc023ebcd84f3632d6cf0e38a7d9f5e7bba15367247753a306b89829
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gerald Kerma <gandalf@gk2.net>

HOST_BUILD_DEPENDS:=lua/host
PKG_BUILD_DEPENDS:=luarocks/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/lua-cs-bouncer
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua Crowdsec Bouncer module
  URL:=https://github.com/crowdsecurity/lua-cs-bouncer
  DEPENDS:=+lua \
        +luasec
endef

define Package/lua-cs-bouncer/description
  Lua module to allow ip (or not) from CrowdSec API.
endef

define Build/Compile
endef

define Package/lua-cs-bouncer/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/crowdsec
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/lib/*.lua \
	        $(1)/usr/lib/lua/crowdsec/
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/template.conf \
	        $(1)/usr/lib/lua/crowdsec/crowdsec.conf

	$(INSTALL_DIR) $(1)/usr/lib/crowdsec/lua/plugins/crowdsec
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/nginx/config.lua \
	        $(1)/usr/lib/crowdsec/lua/plugins/crowdsec/
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/nginx/crowdsec.lua \
	        $(1)/usr/lib/crowdsec/lua/
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/nginx/recaptcha.lua \
	        $(1)/usr/lib/crowdsec/lua/
	$(INSTALL_DATA) \
	        $(PKG_BUILD_DIR)/nginx/access.lua \
	        $(1)/usr/lib/crowdsec/lua/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) \
		./files/lua-cs-bouncer.defaults \
		$(1)/etc/uci-defaults/99_lua-cs-bouncer
endef

define Package/lua-cs-bouncer/conffiles
/usr/lib/lua/crowdsec/crowdsec.conf
endef

$(eval $(call BuildPackage,lua-cs-bouncer))
