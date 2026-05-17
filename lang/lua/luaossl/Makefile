#
# Copyright (C) 2021 Siger Yang <siger.yang@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luaossl
PKG_VERSION:=20220711
PKG_RELEASE:=2
PKG_MAINTAINER:=Siger Yang <siger.yang@outlook.com>

PKG_MIRROR_HASH:=7abb1070da36906f9ef310af1a12827543bb5de4bbe239068420fd8b3e3858d2
PKG_SOURCE_URL:=https://github.com/wahern/luaossl.git
PKG_SOURCE_VERSION:=rel-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/luaossl/default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Comprehensive binding to OpenSSL for $(1)
  URL:=https://25thandclement.com/~william/projects/luaossl.html
  DEPENDS:=+libopenssl
endef

define Package/luaossl/default/description
 luaossl is a comprehensive binding to OpenSSL for Lua 5.1, 5.2, and
 later. It includes support for certificate and key management, key
 generation, signature verification, and deep bindings to the
 distinguished name, alternative name, and X.509v3 extension interfaces. 
endef

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += $(FPIC)

define Package/luaossl
  $(call Package/luaossl/default,lua5.1)
  DEPENDS+=+liblua
  VARIANT:=lua51
endef
define Package/luaossl-lua5.3
  $(call Package/luaossl/default,lua5.3)
  DEPENDS+=+liblua5.3
  VARIANT:=lua53
endef
define Package/luaossl-lua5.4
  $(call Package/luaossl/default,lua5.4)
  DEPENDS+=+liblua5.4
  VARIANT:=lua54
endef

Package/luaossl/description = $(Package/luaossl/default/description)
Package/luaossl-lua5.3/description = $(Package/luaossl/default/description)
Package/luaossl-lua5.4/description = $(Package/luaossl/default/description)

ifeq ($(BUILD_VARIANT),lua51)
  MAKE_FLAGS += \
	LUA_APIS="5.1" \
	LUA51_CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
	lua51cpath="/usr/lib/lua" \
	lua51path="/usr/lib/lua"
endif
ifeq ($(BUILD_VARIANT),lua53)
  MAKE_FLAGS += \
	LUA_APIS="5.3" \
	LUA53_CPPFLAGS="-I$(STAGING_DIR)/usr/include/lua5.3" \
	lua53cpath="/usr/local/lib/lua/5.3" \
	lua53path="/usr/local/lib/lua/5.3"
endif
ifeq ($(BUILD_VARIANT),lua54)
  MAKE_FLAGS += \
	LUA_APIS="5.4" \
	LUA54_CPPFLAGS="-I$(STAGING_DIR)/usr/include/lua5.4" \
	lua54cpath="/usr/local/lib/lua/5.4" \
	lua54path="/usr/local/lib/lua/5.4"
endif

define Package/luaossl/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/_openssl.so $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/openssl.lua $(1)/usr/lib/lua/

	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/openssl $(1)/usr/lib/lua/
endef
define Package/luaossl-lua5.3/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/lib/lua/5.3/_openssl.so $(1)/usr/local/lib/lua/5.3/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/lib/lua/5.3/openssl.lua $(1)/usr/local/lib/lua/5.3/

	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/lua/5.3/openssl $(1)/usr/local/lib/lua/5.3/
endef
define Package/luaossl-lua5.4/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.4
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/lib/lua/5.4/_openssl.so $(1)/usr/local/lib/lua/5.4/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/lib/lua/5.4/openssl.lua $(1)/usr/local/lib/lua/5.4/

	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/lua/5.4/openssl $(1)/usr/local/lib/lua/5.4/
endef

$(eval $(call BuildPackage,luaossl))
$(eval $(call BuildPackage,luaossl-lua5.3))
$(eval $(call BuildPackage,luaossl-lua5.4))
