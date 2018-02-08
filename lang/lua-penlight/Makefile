#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-penlight
PKG_VERSION:=1.5.4
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/stevedonovan/Penlight
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=cd9f25981b12022b66180a3b8df46840be1b3e2a857b8d9909b2d5601be0ead4
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_CONFIG_DEPENDS := \
	CONFIG_PENLIGHT_PATHS \
	CONFIG_PENLIGHT_APPLICATION \
	CONFIG_PENLIGHT_STRING \
	CONFIG_PENLIGHT_TABLE \
	CONFIG_PENLIGHT_ITERATORS

include $(INCLUDE_DIR)/package.mk

define Package/lua-penlight/config
  source "$(SOURCE)/Config.in"
endef

define Package/lua-penlight
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Penlight
  URL:=http://stevedonovan.github.io/Penlight/api/manual/01-introduction.md.html
  DEPENDS:=+luafilesystem
  MAINTAINER:=Karl Palsson <karlp@etactica.com>
endef

define Package/lua-penlight/description
  It is often said of Lua that it does not include batteries.
  Penlight is the batteries.
endef

define Build/Compile
	echo "Nothing to compile, pure lua package"
endef

define Package/lua-penlight/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
ifeq ($(filter-out n, $(CONFIG_PENLIGHT_PATHS) $(CONFIG_PENLIGHT_APPLICATION) $(CONFIG_PENLIGHT_STRING) $(CONFIG_PENLIGHT_TABLE) $(CONFIG_PENLIGHT_ITERATORS)),)
	$(CP) $(PKG_BUILD_DIR)/lua/pl $(1)/usr/lib/lua
endif
ifeq ($(CONFIG_PENLIGHT_PATHS),y)
	# Core files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/path.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/dir.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/file.lua $(1)/usr/lib/lua
	# Dependencies
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/utils.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/compat.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/operator.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/tablex.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/types.lua $(1)/usr/lib/lua
endif
ifeq ($(CONFIG_PENLIGHT_APPLICATION),y)
	# Core files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/app.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/lapp.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/config.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/strict.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/utils.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/compat.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/types.lua $(1)/usr/lib/lua
	# Dependencies
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/path.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/sip.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/operator.lua $(1)/usr/lib/lua
endif
ifeq ($(CONFIG_PENLIGHT_STRING),y)
	# Core files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/utils.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/stringx.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/stringio.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/lexer.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/text.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/template.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/sip.lua $(1)/usr/lib/lua
	# Additional files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/luabalanced.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/url.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/xml.lua $(1)/usr/lib/lua
	# Dependencies
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/compat.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/operator.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/types.lua $(1)/usr/lib/lua
endif
ifeq ($(CONFIG_PENLIGHT_TABLE),y)
	# Core files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/tablex.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/pretty.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/List.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/Map.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/Set.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/OrderedMap.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/data.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/array2d.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/permute.lua $(1)/usr/lib/lua
	# Additional files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/MultiMap.lua $(1)/usr/lib/lua
	# Dependencies
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/utils.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/types.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/compat.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/operator.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/lexer.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/stringx.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/class.lua $(1)/usr/lib/lua
endif
ifeq ($(CONFIG_PENLIGHT_ITERATORS),y)
	# Core files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/seq.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/class.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/func.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/utils.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/comprehension.lua $(1)/usr/lib/lua
	# Additional files
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/Date.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/input.lua $(1)/usr/lib/lua
	# Dependencies
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/types.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/compat.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/operator.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/tablex.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/luabalanced.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/pl/stringx.lua $(1)/usr/lib/lua
endif
endef

$(eval $(call BuildPackage,lua-penlight))
