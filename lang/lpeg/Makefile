#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lpeg
PKG_VERSION:=0.12.2
PKG_RELEASE:=2
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.inf.puc-rio.br/~roberto/lpeg/
PKG_HASH:=6aad270b91d1b1c6fd75f68e162329a04a644e50e917d55f46cc8384b7120004

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/lpeg
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LPeg
  URL:=http://www.inf.puc-rio.br/~roberto/lpeg/
  DEPENDS:=+lua
endef

define Package/lpeg/description
	LPeg is a new pattern-matching library for Lua, based on Parsing Expression Grammars (PEGs)
endef

define Build/Configure
endef

# add make variable overrides here
MAKE_FLAGS += \
	COPT="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -O2"

define Package/lpeg/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpeg.so $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lpeg))
