#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GPL 2 license.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ldbus
PKG_RELEASE:=2
PKG_MIRROR_HASH:=0e39a80e126a77a937226e49ae0246e1fd4600a03dee6bdee5ac822963a234e1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f4a1464e915a2313c80fb40c5c40b0bee7583677
PKG_SOURCE_DATE:=2017-10-03
PKG_SOURCE_URL=https://github.com/daurnimator/ldbus
PKG_MAINTAINER:=Enrico Mioso <mrkiko.rs@gmail.com>
PKG_LICENSE:=MIT

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

define Package/ldbus/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ldbus.so $(1)/usr/lib/lua
endef

define Build/Compile
  cd $(PKG_BUILD_DIR) && \
  luarocks make --pack-binary-rock ldbus-scm-0.rockspec \
    DBUS_INCDIR=$(STAGING_DIR)/usr/include/dbus-1.0/ \
    DBUS_ARCH_INCDIR=$(STAGING_DIR)/usr/lib/dbus-1.0/include \
    DBUS_LIBDIR=$(STAGING_DIR)/usr/lib \
    CC="$(TARGET_CC)" LD="$(TARGET_CC)"
endef

$(eval $(call BuildPackage,ldbus))
