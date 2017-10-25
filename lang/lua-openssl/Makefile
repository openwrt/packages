#
# Copyright (C) 2016 Amnon Paz <pazamnon@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-openssl
PKG_VERSION:=0.6.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Amnon Paz <pazamnon@gmail.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=33de8fa469f66bbf6df09c4ba4e3386c0613cc061f5adff0928d532af6905773
PKG_SOURCE_URL:=https://github.com/zhaozg/lua-openssl.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=1b950e6ff8617205cda1a1b612637ef21b9daf96
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/lua-openssl
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua openSSL binding
  URL:=http://github.com/zhaozg/lua-openssl
  DEPENDS:=+lua +libopenssl +librt
endef

define Package/lua-openssl/description
    A free, MIT-licensed OpenSSL binding for Lua.
endef

define Package/lua-openssl/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openssl.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lua-openssl))
