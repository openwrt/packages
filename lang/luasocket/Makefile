#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasocket
PKG_SOURCE_VERSION:=6d5e40c324c84d9c1453ae88e0ad5bdd0a631448
PKG_VERSION:=3.0-rc1-20130909
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_MIRROR_HASH:=d2fa075d8bd026c41e0eb1a634ac2ad8115dee8abb070720e8e91fab51f86ee4
PKG_SOURCE_URL:=https://github.com/diegonehab/luasocket.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luasocket
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LuaSocket
  URL:=http://luasocket.luaforge.net/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
  DEPENDS:=+lua
endef

define Package/luasocket/description
  LuaSocket is the most comprehensive networking support
  library for the Lua language. It provides easy access to
  TCP, UDP, DNS, SMTP, FTP, HTTP, MIME and much more.
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/ \
		LIBDIR="$(TARGET_LDFLAGS)" \
		CC="$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(FPIC)" \
		LD="$(TARGET_CROSS)ld -shared" \
		all
endef


define Package/luasocket/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/{ltn12,mime,socket}.lua $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mime.so.1.0.3 $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/socket.so.3.0-rc1 $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/mime
	ln -sf ../mime.so.1.0.3 $(1)/usr/lib/lua/mime/core.so
	$(INSTALL_DIR) $(1)/usr/lib/lua/socket
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/{ftp,http,smtp,tp,url,headers}.lua $(1)/usr/lib/lua/socket
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/unix.so $(1)/usr/lib/lua/socket
	ln -sf ../socket.so.3.0-rc1 $(1)/usr/lib/lua/socket/core.so
endef

$(eval $(call BuildPackage,luasocket))
