#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lpack
PKG_REV:=16f8aafb4e7f15a657f41052c048db510eba8348
PKG_VERSION:=master
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.gz
PKG_SOURCE_URL:=https://github.com/LuaDist/lpack
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=lua/host luac/host

include $(INCLUDE_DIR)/package.mk

define Package/lpack
	SUBMENU:=Lua
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=lpack
	URL:=http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/install.html
	DEPENDS:=+lua +luac +liblua +libgcc +libc
	MAINTAINER:=Vladimir Malyutin <first-leon@yandex.ru>
endef

define Package/lpack/description
	This is a simple Lua library for packing and unpacking binary data
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
        CC="$(TARGET_CC)" \
        LUA="$(STAGING_DIR_HOSTPKG)/bin/lua" \
        OPT_FLAGS="$(TARGET_CFLAGS) --std=c99 -Dpthread_yield=sched_yield"
endef

define Package/lpack/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/pack.so $(1)/usr/lib/lua/pack.so
endef

define Package/lpack/postinst
#!/bin/sh

ln -s /lib/libc.so.0 /lib/libc.so

exit 0
endef

define Package/lpack/prerm
#!/bin/sh

rm /lib/libc.so

exit 0
endef

$(eval $(call BuildPackage,lpack))
