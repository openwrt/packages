#
# Copyright (C) 2014 Arduino LLC
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=serialport
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=6.1.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NPM_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://registry.npmjs.org/$(PKG_NPM_NAME)/-/
PKG_HASH:=b58c326d217fb0af1639e4ea834d9fca4be16934c486499e2ddac6e52b8dd560

PKG_BUILD_DEPENDS:=node/host
PKG_NODE_VERSION:=`$(STAGING_DIR_HOSTPKG)/bin/node --version`

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>
PKG_LICENSE:=Custom
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/node-serialport
  SUBMENU:=Node.js
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Node.js package to access serial ports for reading and writing
  URL:=https://www.npmjs.org/package/serialport
  DEPENDS:=+node +node-npm
endef

define Package/node-serialport/description
 Node.js package to access serial ports for reading and writing OR Welcome your robotic JavaScript overlords. Better yet, program them!
endef

define Build/Prepare
	/bin/tar xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components 1
	$(Build/Patch)
endef

CPU:=$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))

EXTRA_LDFLAGS="-L$(TOOLCHAIN_DIR)/lib/ -Wl,-rpath-link $(TOOLCHAIN_DIR)/lib/" \

define Build/Compile
	cd $(PKG_BUILD_DIR) ; \
	$(MAKE_FLAGS) \
	npm_config_arch=$(CONFIG_ARCH) \
	npm_config_nodedir=$(BUILD_DIR)/node-$(PKG_NODE_VERSION)/ \
	npm_config_cache=$(BUILD_DIR)/node-$(PKG_NODE_VERSION)/npm-cache \
	PREFIX="$(PKG_INSTALL_DIR)/usr/" \
	npm install --build-from-source --target_arch=$(CPU) -g \
		`npm pack $(PKG_BUILD_DIR) | tail -n 1`
endef

define Package/node-serialport/install
	mkdir -p $(1)/usr/lib/node/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/* $(1)/usr/lib/node/
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

$(eval $(call BuildPackage,node-serialport))

