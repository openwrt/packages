#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-curl-v3
PKG_VERSION:=0.3.13~9f8b6dba8
PKG_RELEASE:=2
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_URL:=https://github.com/Lua-cURL/Lua-cURLv3.git
PKG_MIRROR_HASH:=41f9e418b203fe3bdf256e4a5517ac8dbaf5ab5026b972f603052a0c56dfcfc7
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=9f8b6dba8b5ef1b26309a571ae75cda4034279e5

include $(INCLUDE_DIR)/package.mk

define Package/lua-curl-v3
    SUBMENU:=Lua
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=Lua-curl
    DEPENDS:=+libcurl +lua
    MAINTAINER:=Rainer Poisel <rainer.poisel@gmail.com>
endef

MAKE_FLAGS += \
	UNAME="Linux"

define Package/lua-curl-v3/description
	Lua bindings to libcurl (Lua-cURLv3)
endef

define Package/lua-curl-v3/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lcurl.so $(1)/usr/lib/lua
	$(CP) $(PKG_BUILD_DIR)/src/lua/* $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-curl-v3))

