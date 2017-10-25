#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luai2c
PKG_VERSION:=1.1.2
PKG_RELEASE:=4
PKG_MAINTAINER:=Frank Edelhaeuser <mrpace2@gmail.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=1c25062e95064cda4866243ff6797ef597dd57260da559ca68129aa7a72a9cda
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mrpace2/lua-i2c.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luai2c
	SUBMENU:=Lua
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Lua I2C binding
	URL:=https://github.com/mrpace2/lua-i2c/
	DEPENDS:=+liblua +kmod-i2c-core
	MAINTAINER:=Frank Edelhaeuser <mrpace2@gmail.com>
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
