#
# Copyright (C) 2016 Amnon Paz <pazamnon@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-openssl
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/zhaozg/lua-openssl.git
PKG_SOURCE_VERSION:=0.8.5-1
PKG_MIRROR_HASH:=3187a2342b01b88dfac5502a66902f4ef74695bcb512cc86cc5105e608202dfe

PKG_MAINTAINER:=Amnon Paz <pazamnon@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

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
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/5.1/openssl.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lua-openssl))
