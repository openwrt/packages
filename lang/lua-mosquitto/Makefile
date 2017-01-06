#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-mosquitto
PKG_VERSION:=0.2
PKG_RELEASE:=2
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/flukso/lua-mosquitto.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)/default
	SUBMENU:=Lua
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=lua-mosquitto
	DEPENDS:=+lua
	MAINTAINER:=Karl Palsson <karlp@remake.is>
endef

define Package/$(PKG_NAME)
	$(call Package/$(PKG_NAME)/default)
	TITLE+= (with SSL support)
	DEPENDS+= +libmosquitto
endef

define Package/$(PKG_NAME)-nossl
	$(call Package/$(PKG_NAME)/default)
	TITLE+= (without SSL support)
	DEPENDS+= +libmosquitto-nossl
endef

define Package/$(PKG_NAME)/default/description
	Lua bindings to libmosquitto
endef

define Package/$(PKG_NAME)/description
	$(call Package/$(PKG_NAME)/default/description)
	This package is built with SSL support
endef

define Package/$(PKG_NAME)-nossl/description
	$(call Package/$(PKG_NAME)/default/description)
	This package is built WITHOUT SSL support.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mosquitto.so $(1)/usr/lib/lua
endef

Package/$(PKG_NAME)-nossl/install = $(Package/$(PKG_NAME)/install)

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-nossl))
