include $(TOPDIR)/rules.mk

PKG_NAME:=luv
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/luvit/luv.git
PKG_SOURCE_VERSION:=1.9.1-1
PKG_SOURCE_DATE:=2016-12-16

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/luv
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Luv
  URL:=https://github.com/luvit/luv
  MAINTAINER:=Morteza Milani <milani@pichak.co>
  DEPENDS:=+libuv +!LUV_USE_LUAJIT_ENGINE:lua
endef

define Package/luv/description
  Bare libuv bindings for lua
endef

define Package/luv/config
	source "$(SOURCE)/Config.in"
endef

CMAKE_OPTIONS += -DLUA_BUILD_TYPE=System
CMAKE_OPTIONS += -DWITH_SHARED_LIBUV=ON
CMAKE_OPTIONS += -DBUILD_MODULE=OFF
CMAKE_OPTIONS += -DBUILD_SHARED_LIBS=ON

ifeq ($(CONFIG_LUV_USE_LUAJIT_ENGINE),y)
	CMAKE_OPTIONS += -DWITH_LUA_ENGINE=Luajit
else
	CMAKE_OPTIONS += -DWITH_LUA_ENGINE=Lua
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/luv
	$(CP) $(PKG_INSTALL_DIR)/usr/include/luv/*.h $(1)/usr/include/luv
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
endef

define Package/luv/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libluv.so.1.9.1 $(1)/usr/lib/lua/luv.so
endef


$(eval $(call BuildPackage,luv))
