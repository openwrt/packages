#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GPL 2 license.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ldbus
PKG_SOURCE_DATE:=2019-03-25
PKG_SOURCE_VERSION:=345d820b0f34bd35ea01dae633d35ea3cf7faf2a
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/daurnimator/ldbus
PKG_MIRROR_HASH:=c0f5d1b34bc8b82d0f70bad23ecaca10ef84730c2c3ea318673b5a941f4dfc85

PKG_MAINTAINER:=Enrico Mioso <mrkiko.rs@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=luarocks/host

include $(INCLUDE_DIR)/package.mk

define Package/ldbus
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=ldbus Lua DBus bindings
  DEPENDS:=+dbus +lua
endef

define Package/ldbus/description
  This package contains "ldbus": LUA bindings to interact with the DBUS
  message bus system, and services connected to it.
  See https://github.com/daurnimator/ldbus
  for details.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include

MAKE_FLAGS += \
	FPIC="$(FPIC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

define Build/Compile
  cd $(PKG_BUILD_DIR) && \
  luarocks make --pack-binary-rock ldbus-scm-0.rockspec \
    LUA_LIBDIR=$(STAGING_DIR)/usr/lib/lua \
    LUA_PKGNAME=lua5.1 \
    DBUS_INCDIR=$(STAGING_DIR)/usr/include/dbus-1.0/ \
    DBUS_ARCH_INCDIR=$(STAGING_DIR)/usr/lib/dbus-1.0/include \
    DBUS_LIBDIR=$(STAGING_DIR)/usr/lib \
    CC="$(TARGET_CC)" LD="$(TARGET_CC)"
endef

define Package/ldbus/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ldbus.so $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,ldbus))
