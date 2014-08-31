#
# Copyright (C) 20013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-bencode
PKG_VERSION:=2.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://bitbucket.org/wilhelmy/lua-bencode
PKG_SOURCE_PROTO:=hg
PKG_SOURCE_VERSION:=500243383cb6acbddd3cf12aee6e4667aab53324
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/lua-bencode
	SUBMENU:=Lua
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=lua-bencode
	URL:=https://bitbucket.org/wilhelmy/lua-bencode
	MAINTAINER:=Lars Gierth <larsg@systemli.org>
	DEPENDS:=+lua
endef

define Package/lua-bencode/description
	This is a module for the lua programming language for decoding and encoding
	bencoded data which can be used to read and write torrent files for bittorrent.
endef

define Build/Configure
endef

define Build/Compile
endef


define Package/lua-bencode/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/bencode.lua $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-bencode))
