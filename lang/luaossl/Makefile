#
# Copyright (C) 2021 Siger Yang <sigeryeung@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luaossl
PKG_VERSION:=20200709
PKG_RELEASE:=1
PKG_MAINTAINER:=Siger Yang <sigeryeung@gmail.com>

PKG_MIRROR_HASH:=6dbca3cdc50ed7e3b0821783da2407accfb6d25addc3edf1d8e17b00530f5a25
PKG_SOURCE_URL:=https://github.com/wahern/luaossl.git
PKG_SOURCE_VERSION:=rel-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/luaossl
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Comprehensive binding to OpenSSL for Lua 5.1, 5.2, and later
  URL:=http://25thandclement.com/~william/projects/luaossl.html
  DEPENDS:=+liblua +libopenssl
endef

define Package/luaossl/description
 luaossl is a comprehensive binding to OpenSSL for Lua 5.1, 5.2, and
 later. It includes support for certificate and key management, key
 generation, signature verification, and deep bindings to the
 distinguished name, alternative name, and X.509v3 extension interfaces. 
endef

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += $(FPIC)

MAKE_FLAGS += \
	LUA_APIS="5.1" \
	lua51cpath="/usr/lib/lua" \
	lua51path="/usr/lib/lua"

define Package/luaossl/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/_openssl.so $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/openssl.lua $(1)/usr/lib/lua/

	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/openssl $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,luaossl))
