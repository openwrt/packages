include $(TOPDIR)/rules.mk

PKG_NAME:=luv
PKG_VERSION:=1.36.0-0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/luvit/luv/releases/download/$(PKG_VERSION)
PKG_HASH:=f2e7eb372574f25c6978c1dc74280d22efdcd7df2dda4a286c7fe7dceda26445

PKG_MAINTAINER:=Morteza Milani <milani@pichak.co>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include ../../devel/ninja/ninja-cmake.mk

define Package/luv
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Luv
  URL:=https://github.com/luvit/luv
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

define Package/luv/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libluv.so.1.36.0 $(1)/usr/lib/lua/luv.so
endef


$(eval $(call BuildPackage,luv))
