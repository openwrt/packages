include $(TOPDIR)/rules.mk

PKG_NAME:=lua-ffi
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://github.com/zhaojh329/lua-ffi/releases/download/v$(PKG_VERSION)
PKG_HASH:=e26a8ed685c1aa31566683e3c06b057fd9ae6c7eec9922abe7661eeb678f1cd8

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lua-ffi/default
  TITLE:=A portable lightweight C FFI for $(1), based on libffi
  CATEGORY:=Languages
  SECTION:=lang
  SUBMENU:=Lua
  DEPENDS:=+libffi
  URL:=https://github.com/zhaojh329/lua-ffi
endef

define Package/lua-ffi/default/description
  Lua-ffi is a portable lightweight C FFI for Lua, based on libffi
  and aiming to be mostly compatible with LuaJIT FFI, but written
  from scratch in C language.
endef

define Package/lua-ffi
  $(call Package/lua-ffi/default,lua5.1)
  DEPENDS+=+liblua
  VARIANT:=lua51
endef

define Package/lua-ffi-lua5.3
  $(call Package/lua-ffi/default,lua5.3)
  DEPENDS+=+liblua5.3
  VARIANT:=lua53
endef

define Package/lua-ffi-lua5.4
  $(call Package/lua-ffi/default,lua5.4)
  DEPENDS+=+liblua5.4
  VARIANT:=lua54
endef

Package/lua-ffi/description = $(Package/lua-ffi/default/description)
Package/lua-ffi-lua5.3/description = $(Package/lua-ffi/default/description)
Package/lua-ffi-lua5.4/description = $(Package/lua-ffi/default/description)

ifeq ($(BUILD_VARIANT),lua51)
  CMAKE_OPTIONS += -DLUA_INCLUDE_DIR="$(STAGING_DIR)/usr/include"
endif

ifeq ($(BUILD_VARIANT),lua53)
  CMAKE_OPTIONS += -DLUA_INCLUDE_DIR="$(STAGING_DIR)/usr/include/lua5.3"
endif

ifeq ($(BUILD_VARIANT),lua54)
  CMAKE_OPTIONS += -DLUA_INCLUDE_DIR="$(STAGING_DIR)/usr/include/lua5.4"
endif

define Package/lua-ffi/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ffi.so $(1)/usr/lib/lua
endef

define Package/lua-ffi-lua5.3/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ffi.so $(1)/usr/local/lib/lua/5.3
endef

define Package/lua-ffi-lua5.4/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.4
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ffi.so $(1)/usr/local/lib/lua/5.4
endef

$(eval $(call BuildPackage,lua-ffi))
$(eval $(call BuildPackage,lua-ffi-lua5.3))
$(eval $(call BuildPackage,lua-ffi-lua5.4))
