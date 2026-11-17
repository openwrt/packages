include $(TOPDIR)/rules.mk

PKG_NAME:=lua-struct
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/iryont/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=7f14d5d9e4a9f5392dc095377a1c98976a36a2cd0e4939feb8fb5302ce67777b

PKG_MAINTAINER:=Jakob Schade <jasle@riseup.net>
PKG_LICENSE:=MIT/X11

include $(INCLUDE_DIR)/package.mk

define Package/lua-struct
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Implementation of binary packing/unpacking in pure lua
  URL:=https://github.com/iryont/lua-struct
endef

define Package/lua-struct/description
	lua-struct is a pure lua Implementation for packing and unpacking 
	binary data. 
endef

define Build/Compile
	echo "Nothing to compile, pure lua package"
endef

define Package/lua-struct/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/struct.lua $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lua-struct))

