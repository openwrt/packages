include $(TOPDIR)/rules.mk

PKG_NAME:=lua-struct
PKG_VERSION:=0.9.2
PKG_RELEASE:=1

PKG_VERSION_TAG:=$(PKG_VERSION)-1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION_TAG).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/iryont/$(PKG_NAME)/tar.gz/$(PKG_VERSION_TAG)?
PKG_HASH:=30d4e3584e27caa504745fdf5e191f2469ae284dc51271292654856905a4603d

PKG_MAINTAINER:=jasle <jasle@riseup.net>
PKG_LICENSE:=MIT/X11

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION_TAG)

include $(INCLUDE_DIR)/package.mk

define Package/lua-struct
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Implementation of binary packing/unpacking in pure lua
  URL:=https://github.com/iryont/lua-struct
endef

define Package/lua-struct/desription
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

