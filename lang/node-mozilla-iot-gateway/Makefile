#
# Copyright (C) 2018 Sartura Ltd.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=mozilla-iot-gateway
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=0.3.1
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mozilla-iot/gateway.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=ba05bc3e93c36768244df922434e7132c2dae85a1ff9e3213beea087a4844d11

PKG_BUILD_DEPENDS:=node/host openzwave
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(BUILD_DIR)/$(PKG_NAME)/ipkg-install

URSA_VERSION:=0.9.4
URSA_SOURCE:=ursa-$(URSA_VERSION).tgz
URSA_SUBDIR:=ursa-$(URSA_VERSION)
URSA_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(URSA_SUBDIR)
URSA_TGZ:=$(BUILD_DIR)/$(PKG_NAME)/$(URSA_SOURCE)

PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/node-mozilla-iot-gateway
  SUBMENU:=Node.js
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Things Gateway by Mozilla
  URL:=https://iot.mozilla.org/gateway/
  DEPENDS:=+node +node-npm +libopenzwave +python +openssl-util
endef

define Package/node-mozilla-iot-gateway/description
  Build Your Own Web of Things Gateway. The "Web of Things" (WoT) is the
  idea of taking the lessons learned from the World Wide Web and applying
  them to IoT. It's about creating a decentralized Internet of Things by
  giving Things URLs on the web to make them linkable and discoverable,
  and defining a standard data model and APIs to make them interoperable.
endef

define Download/ursa
  FILE:=$(URSA_SOURCE)
  URL:=https://registry.yarnpkg.com/ursa/-/$(FILE)
  HASH:=65516fc99958011572ef26ef02a3c84a004e47aabfd5b8aa46abb10481ae7153
endef
$(eval $(call Download,ursa))

define Build/Prepare
	$(PKG_UNPACK)
	$(Build/Patch)
	$(RM) -r "$(URSA_BUILD_DIR)" "$(BUILD_DIR)/$(PKG_NAME)/package"
	( \
	  cd $(PKG_BUILD_DIR)/.. && \
	  $(TAR) -xzf $(DL_DIR)/$(URSA_SOURCE) && \
	  mv package $(URSA_SUBDIR) \
	)
	cat ./files/ursa.patch | ( cd $(URSA_BUILD_DIR) && patch -p1 )
	cat ./files/gateway.patch | ( cd $(PKG_BUILD_DIR) && patch -p1 )
	sed -i -e 's!@@URSA_TGZ@@!$(URSA_TGZ)!' $(PKG_BUILD_DIR)/package.json
	( \
	  cd $(PKG_BUILD_DIR)/.. && \
	  tar -czf $(PKG_SOURCE) $(PKG_NAME)-$(PKG_VERSION); \
	  tar -czf $(URSA_SOURCE) $(URSA_SUBDIR) \
	)
endef

EXTRA_CFLAGS += -Wno-error=format-security
CPU:=$(subst powerpc,ppc,$(subst aarch64,arm64,$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))))

define Build/Compile
	$(MAKE_VARS) \
	$(MAKE_FLAGS) \
	npm_config_arch=$(CONFIG_ARCH) \
	npm_config_nodedir=$(STAGING_DIR)/usr/ \
	npm_config_cache=$(TMP_DIR)/npm-cache \
	npm_config_tmp=$(TMP_DIR)/npm-tmp \
	PREFIX="$(PKG_INSTALL_DIR)/usr/" \
	$(STAGING_DIR_HOSTPKG)/bin/npm install --build-from-source --target_arch=$(CPU) -g \
		$(PKG_BUILD_DIR)/../$(PKG_SOURCE)
endef

define Build/Clean
	$(RM) -r "$(BUILD_DIR)/$(PKG_NAME)/"
endef

define Package/node-mozilla-iot-gateway/install
	$(INSTALL_DIR) $(1)/opt/mozilla-iot/gateway
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/things-gateway/* $(1)/opt/mozilla-iot/gateway
	$(STAGING_DIR_HOSTPKG)/bin/npm --prefix=$(1)/opt/mozilla-iot/gateway install $(1)/opt/mozilla-iot/gateway
	$(LN) ../constants.js $(1)/opt/mozilla-iot/gateway/src/addons/addon-constants.js
	$(LN) /tmp/mozilla-iot/gateway/run-app.log $(1)/opt/mozilla-iot/gateway/run-app.log

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mozilla-iot-gateway.init $(1)/etc/init.d/mozilla-iot-gateway
endef

$(eval $(call BuildPackage,node-mozilla-iot-gateway))
