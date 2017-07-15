#
# Copyright (C) 2016 ?
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=i2c-bus
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NPM_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://registry.npmjs.org/$(PKG_NPM_NAME)/-/
#PKG_MD5SUM:=ce80e05074149dbb47f1e393b66be776 -for npm package "i2c", currently not working with node 4.4, waiting fork
PKG_MD5SUM:=a92cbe965257c16c7c64dc11884171b9

PKG_BUILD_DEPENDS:=node/host
PKG_NODE_VERSION:=4.4.4

PKG_MAINTAINER:=
PKG_LICENSE:=Custom
PKG_LICENSE_FILE:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/node-i2c-bus
  DEPENDS:=+node
  SUBMENU:=Node.js
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Node.js package to access i2c-bus for reading and writing
  URL:=https://www.npmjs.org/package/i2c-bus
endef

define Package/node-i2c-bus/description
 Node.js package to access i2c-bus for reading and writing OR Welcome your robotic JavaScript overlords. Better yet, program them!
endef

define Build/Prepare
	/bin/tar xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components 1
	$(Build/Patch)
endef

CPU:=$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))

EXTRA_LDFLAGS="-L$(TOOLCHAIN_DIR)/lib/ -Wl,-rpath-link $(TOOLCHAIN_DIR)/lib/" \

define Build/Compile
	$(MAKE_FLAGS) \
	npm_config_arch=$(CONFIG_ARCH) \
	npm_config_nodedir=$(BUILD_DIR)/node-v$(PKG_NODE_VERSION)/ \
	npm_config_cache=$(BUILD_DIR)/node-v$(PKG_NODE_VERSION)/npm-cache \
	PREFIX="$(PKG_INSTALL_DIR)/usr/" \
	$(STAGING_DIR)/host/bin/npm install --build-from-source --target_arch=$(CPU) -g $(PKG_BUILD_DIR)
endef

define Package/node-i2c-bus/install
	mkdir -p $(1)/usr/lib/node/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/* $(1)/usr/lib/node/
endef

$(eval $(call BuildPackage,node-i2c-bus))
