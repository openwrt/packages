#
# Copyright (C) 2018 Sartura Ltd.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=mozilla-iot-gateway
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=0.8.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mozilla-iot/gateway/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f407732b9c1d020aa79e9d0b12f1b97e82691d6f58def2df067f790f4f640e30

PKG_BUILD_DEPENDS:=node/host openzwave

PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/node-mozilla-iot-gateway
  SUBMENU:=Node.js
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=WebThings Gateway by Mozilla
  URL:=https://iot.mozilla.org/gateway/
  DEPENDS:= +libpthread +node +node-npm +libopenzwave +openzwave-config +python +python3-light +python3-pip +openssl-util
  DEPENDS+= +MOIT_enable-plugin-support:git-http
  MENU:=1
endef

define Package/node-mozilla-iot-gateway/description
  Build Your Own Web of Things Gateway. The "Web of Things" (WoT) is the
  idea of taking the lessons learned from the World Wide Web and applying
  them to IoT. It's about creating a decentralized Internet of Things by
  giving Things URLs on the web to make them linkable and discoverable,
  and defining a standard data model and APIs to make them interoperable.
endef

define Package/node-mozilla-iot-gateway/config
  source "$(SOURCE)/Config.in"
endef

CPU:=$(subst powerpc,ppc,$(subst aarch64,arm64,$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))))

TARGET_CFLAGS+=$(FPIC)

define Build/Compile
	$(MAKE_VARS) \
	$(MAKE_FLAGS) \
	npm_config_arch=$(CONFIG_ARCH) \
	npm_config_nodedir=$(STAGING_DIR)/usr/ \
	npm_config_cache=$(TMP_DIR)/npm-cache \
	npm_config_tmp=$(TMP_DIR)/npm-tmp \
	PREFIX="$(PKG_INSTALL_DIR)/usr/" \
	$(STAGING_DIR_HOSTPKG)/bin/npm install --build-from-source --target_arch=$(CPU) -g $(DL_DIR)/$(PKG_SOURCE)
endef

define Package/node-mozilla-iot-gateway/install
	$(INSTALL_DIR) $(1)/opt/mozilla-iot/gateway/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/webthings-gateway/* $(1)/opt/mozilla-iot/gateway
	$(STAGING_DIR_HOSTPKG)/bin/npm --prefix=$(1)/opt/mozilla-iot/gateway install $(1)/opt/mozilla-iot/gateway

	# Clean up of old build files that confuse OpenWrt's dependency checker
	$(RM) -r $(1)/opt/mozilla-iot/gateway/node_modules/sqlite3/lib/binding/node-v57-linux-x64
	$(RM) -r $(1)/opt/mozilla-iot/gateway/node_modules/ursa/build/Release/ursaNative.node
	$(RM) -r $(1)/opt/mozilla-iot/gateway/node_modules/ursa/build/Release/obj.target/ursaNative.node

	$(INSTALL_DIR) $(1)/opt/mozilla-iot/gateway/node_modules/sqlite3/lib/binding/node-v57-linux-$(CPU)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/webthings-gateway/node_modules/sqlite3/lib/binding/node-v57-linux-$(CPU)/node_sqlite3.node \
		$(1)/opt/mozilla-iot/gateway/node_modules/sqlite3/lib/binding/node-v57-linux-$(CPU)/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mozilla-iot-gateway.init $(1)/etc/init.d/mozilla-iot-gateway
endef

$(eval $(call BuildPackage,node-mozilla-iot-gateway))
