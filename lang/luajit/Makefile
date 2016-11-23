#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#


include $(TOPDIR)/rules.mk

PKG_NAME:=LuaJIT
PKG_VERSION:=2.1.0-beta2
PKG_RELEASE:=1
PKG_SOURCE_URL:=http://luajit.org/download
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=fa14598d0d775a7ffefb138a606e0d7b
include $(INCLUDE_DIR)/package.mk

define Package/luajit
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LuaJIT
  URL:=http://luajit.org
  MAINTAINER:=Israel Lot <israel@fleety.com.br>
endef

define Package/luajit/description
 LuaJIT is a Just-In-Time Compiler for the Lua* programming language.
 LuaJIT implements the full set of language features defined by Lua 5.1.
 The virtual machine (VM) is API- and ABI-compatible to the standard Lua interpreter and can be deployed as a drop-in replacement.
 LuaJIT offers more performance, at the expense of portability.
 It currently runs on all popular operating systems based on x86 or x64 CPUs (Linux, Windows, OSX etc.) or embedded systems based on ARM (Android, iOS), PPC or MIPS CPUs.
 Other platforms will be supported in the future, based on user demand and sponsoring.
endef



HOST_CFLAGS+= -fPIC -m32
TARGET_CFLAGS = -Os -pipe -mno-branch-likely -mips32r2 -mtune=34kc -fno-caller-saves -fhonour-copts -Wno-error=unused-but-set-variable -Wno-error=unused-result -msoft-float -fPIC
TARGET_LDFLAGS+= -msoft-float
TARGET_SHLDFLAGS+= -msoft-float

define Build/Compile
#	$(call Build/Compile/Default)
	$(MAKE) -C $(PKG_BUILD_DIR) HOST_CC="gcc -m32 -fPIC" CROSS=$(TARGET_CROSS) TARGET_FLAGS="$(TARGET_FLAGS)" TARGET_CFLAGS="$(TARGET_CFLAGS)" TARGET_LDFLAGS="$(TARGET_LDFLAGS)" TARGET_SHLDFLAGS="$(TARGET_SHLDFLAGS)" DESTDIR="$(PKG_INSTALL_DIR)" PREFIX=/usr 
	$(MAKE) -C $(PKG_BUILD_DIR) HOST_CC="gcc -m32 -fPIC" CROSS=$(TARGET_CROSS) TARGET_FLAGS="$(TARGET_FLAGS)" TARGET_CFLAGS="$(TARGET_CFLAGS)" TARGET_LDFLAGS="$(TARGET_LDFLAGS)" TARGET_SHLDFLAGS="$(TARGET_SHLDFLAGS)" DESTDIR="$(PKG_INSTALL_DIR)" PREFIX=/usr install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib,include}
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libluajit* $(1)/usr/lib/
	(cd $(1)/usr/lib ;ln -s libluajit-5.1.so libluajit.so)
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/luajit.pc $(1)/usr/lib/pkgconfig/luajit.pc
endef

define Package/luajit/install
	$(INSTALL_DIR) $(1)/usr/{lib,bin,share}
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libluajit*so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/luajit* $(1)/usr/share/
	(cd $(1)/usr/bin;ln -s luajit-$(PKG_VERSION) luajit )
endef

$(eval $(call BuildPackage,luajit))
