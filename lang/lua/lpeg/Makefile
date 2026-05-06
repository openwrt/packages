#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lpeg
PKG_VERSION:=1.1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.inf.puc-rio.br/~roberto/lpeg/
PKG_HASH:=4b155d67d2246c1ffa7ad7bc466c1ea899bbc40fef0257cc9c03cecbaed4352a

include $(INCLUDE_DIR)/package.mk

define Package/lpeg
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Pattern-matching library for Lua
  URL:=http://www.inf.puc-rio.br/~roberto/lpeg/
  DEPENDS:=+lua
endef

define Package/lpeg/description
  LPeg is a pattern-matching library for Lua based on Parsing Expression Grammars (PEGs).
endef

MAKE_FLAGS += \
	COPT="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -O2"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpeg.so $(1)/usr/lib/lua
endef

define Package/lpeg/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lpeg.so $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lpeg))
