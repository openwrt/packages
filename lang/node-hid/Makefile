#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=hid
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=0.5.1
PKG_RELEASE:=6

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/node-hid/node-hid.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=35d830b7810c87d32484d0a346621568c4849441
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=125f752d491ac10d32bab0f0d660f6f150c6a9a168b2b56bfddc2cb1d65166fc

PKG_BUILD_DEPENDS:=node/host
PKG_NODE_VERSION:=4.4.5

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>
PKG_LICENSE:=Custom
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/node-hid
  DEPENDS:=+node +node-npm
  SUBMENU:=Node.js
  SECTION:=lang
  CATEGORY:=Languages
  DEPENDS:=+libusb-1.0 +hidapi +libstdcpp
  TITLE:=Node.js package to access HID devices
  URL:=https://github.com/node-hid/node-hid
endef

define Package/node-hid/description
 Node.js package to access HID devices
endef

CPU:=$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))

EXTRA_CFLAGS+=-I$(STAGING_DIR)/usr/include/libusb-1.0

define Build/Compile
	git init $(PKG_BUILD_DIR)
	$(MAKE_VARS) \
	$(MAKE_FLAGS) \
	npm_config_arch=$(CONFIG_ARCH) \
	npm_config_nodedir=$(STAGING_DIR_HOSTPKG)/ \
	npm_config_cache=$(STAGING_DIR_HOSTPKG)/share/node/npm-cache \
	PREFIX="$(PKG_INSTALL_DIR)/usr/" \
	npm install --build-from-source --target_arch=$(CPU) -g $(PKG_BUILD_DIR)
endef

define Package/node-hid/install
	mkdir -p $(1)/usr/lib/node/node-hid/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/* $(1)/usr/lib/node/
endef

$(eval $(call BuildPackage,node-hid))

