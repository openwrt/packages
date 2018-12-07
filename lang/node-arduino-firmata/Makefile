#
# Copyright (C) 2014 Arduino LLC
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=arduino-firmata
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=0.3.4
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/shokai/node-arduino-firmata.git
PKG_MIRROR_HASH:=1aef93dc704ea771b9eab51cb64103533f829aee5b2886ad55d173adf3f11ede
PKG_SOURCE_VERSION:=v0.3.4
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DEPENDS:=node/host
PKG_NODE_VERSION:=`$(STAGING_DIR_HOSTPKG)/bin/node --version`

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk

define Package/node-arduino-firmata
  SUBMENU:=Node.js
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Node.js package to access serial ports for reading and writing
  URL:=https://www.npmjs.org/package/serialport
  DEPENDS:=+node +node-npm +node-serialport
endef

define Package/node-arduino-firmata/description
 Node.js package to access serial ports for reading and writing OR Welcome your robotic JavaScript overlords. Better yet, program them!
endef

define Build/Prepare
	/bin/tar xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components 1
	$(Build/Patch)
endef

EXTRA_LDFLAGS="-L$(TOOLCHAIN_DIR)/lib/ -Wl,-rpath-link $(TOOLCHAIN_DIR)/lib/" \

define Build/Compile
	cd $(PKG_BUILD_DIR) ; \
	$(MAKE_FLAGS) \
	npm_config_arch=$(CONFIG_ARCH) \
	npm_config_nodedir=$(BUILD_DIR)/node-$(PKG_NODE_VERSION)/ \
	npm_config_cache=$(BUILD_DIR)/node-$(PKG_NODE_VERSION)/npm-cache \
	PREFIX="$(PKG_INSTALL_DIR)/usr/" \
	npm install -g `npm pack $(PKG_BUILD_DIR) | tail -n 1`
endef

define Package/node-arduino-firmata/install
	mkdir -p $(1)/usr/lib/node
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/. $(1)/usr/lib/node
	rm -rf  $(1)/usr/lib/node/arduino-firmata/node_modules/serialport/ \
		$(1)/usr/lib/node/arduino-firmata/patches \
		$(1)/usr/lib/node/arduino-firmata/.p* \
		$(1)/usr/lib/node/arduino-firmata/.quilt* \
		$(1)/usr/lib/node/arduino-firmata/.built* \
		$(1)/usr/lib/node/arduino-firmata/.config*
	# Strip PKG_BUILD_DIR from useless metadata inserted by npm install
	# https://github.com/npm/npm/issues/10393
	# https://github.com/npm/npm/issues/12110
	find $(1)/usr/lib/node -name package.json -exec sed -i -e 's,$(PKG_BUILD_DIR),,g' {} +
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,node-arduino-firmata))

