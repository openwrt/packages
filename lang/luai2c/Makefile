#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luai2c
PKG_VERSION:=1.0.0
PKG_RELEASE:=2
PKG_MAINTAINER:=Frank Edelhaeuser <fedel@users.sourceforge.net>

PKG_SOURCE_NAME:=i2c-lua
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_SOURCE_NAME)
PKG_MD5SUM:=7098577f101410b201cd43a7467e408d


include $(INCLUDE_DIR)/package.mk

define Package/luai2c
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua I2C binding
  URL:=http://sourceforge.net/projects/i2c-lua/
  DEPENDS:=+liblua +kmod-i2c-core
  MAINTAINER:=Frank Edelhaeuser <fedel@users.sourceforge.net>
endef

define Package/luai2c/description
	This is the Lua binding for I2C. It provides access to I2C slaves supported by the kernel.
endef

define Package/luai2c/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/i2c.so $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/i2c
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/examples/* $(1)/usr/lib/lua/i2c
endef

$(eval $(call BuildPackage,luai2c))
