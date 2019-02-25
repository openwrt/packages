#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=hid
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=0.7.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/node-hid/node-hid/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=964dd4934d1135d3d87ed8ad576e5c8aa45388a22aa58c69f64276c68e1deb06

PKG_BUILD_DEPENDS:=node/host
PKG_NODE_VERSION:=`$(STAGING_DIR_HOSTPKG)/bin/node --version`

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>
PKG_LICENSE:=Custom
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/node-hid
  SUBMENU:=Node.js
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Node.js package to access HID devices
  URL:=https://github.com/node-hid/node-hid
  DEPENDS:=+node +node-npm +libusb-1.0 +hidapi +libstdcpp +libudev-fbsd
endef

define Package/node-hid/description
 Node.js package to access HID devices
endef

CPU:=$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))

EXTRA_CFLAGS+=-I$(STAGING_DIR)/usr/include/libusb-1.0

define Build/Compile
	git init $(PKG_BUILD_DIR)
	cd $(PKG_BUILD_DIR) ; \
	$(MAKE_VARS) \
	$(MAKE_FLAGS) \
	npm_config_arch=$(CONFIG_ARCH) \
	npm_config_nodedir=$(BUILD_DIR)/node-$(PKG_NODE_VERSION)/ \
	npm_config_cache=$(BUILD_DIR)/node-$(PKG_NODE_VERSION)/npm-cache \
	PREFIX="$(PKG_INSTALL_DIR)/usr/" \
	npm install --build-from-source --target_arch=$(CPU) -g \
		`npm pack $(PKG_BUILD_DIR) | tail -n 1`
endef

define Package/node-hid/install
	mkdir -p $(1)/usr/lib/node/node-hid/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/. $(1)/usr/lib/node/
	$(RM) -rf $(1)/usr/lib/node/node-hid/patches \
		  $(1)/usr/lib/node/node-hid/.p* \
		  $(1)/usr/lib/node/node-hid/.quilt* \
		  $(1)/usr/lib/node/node-hid/.built* \
		  $(1)/usr/lib/node/node-hid/.config*
	# Strip PKG_BUILD_DIR from useless metadata inserted by npm install
	# https://github.com/npm/npm/issues/10393
	# https://github.com/npm/npm/issues/12110
	find $(1)/usr/lib/node -name package.json -exec sed -i -e 's,$(PKG_BUILD_DIR),,g' {} +
endef

$(eval $(call BuildPackage,node-hid))

