include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=gun
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=0.2020.1237
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NPM_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://registry.npmjs.org/$(PKG_NPM_NAME)/-/$(PKG_NPM_NAME)-$(PKG_VERSION).tgz
PKG_HASH:=e798917f66a7195a9d620a7c4de3bdc331d32c83

PKG_HOST_ONLY:=1
PKG_BUILD_DEPENDS:=node/host
HOST_BUILD_PARALLEL:=1

HOST_BUILD_DEPENDS:=node/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_MAINTAINER:=Mark Nadal <@marknadal>, Jonathan Bryant <bryant.jonathan.42@gmail.com>
PKG_LICENSE:=Zlib,MIT,Apache
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/gun
  SECTION:=base
  CATEGORY:=Lib
  TITLE:=GunDB
  URL:=https://gun.eco
  DEPENDS:=+node +node-npm
  BUILDONLY:=1
endef
 
define Package/gun/description
  GunDB allows NAT traversal for WAN graphs
  and caching for requests from within NAT.
endef

define Package/gun/config
	source "$(SOURCE)/files/index.js"
endef
 
TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

HOSTTMPNPM:=$(shell mktemp -u XXXXXXXXXX)

HOST_NPM_FLAGS=$(HOST_MAKE_VARS) \
	$(HOST_MAKE_FLAGS) \
	npm_config_arch=$(NODEJS_CPU) \
	npm_config_target_arch=$(NODEJS_CPU) \
	npm_config_build_from_source=true \
	npm_config_nodedir=$(STAGING_DIR)/usr/ \
	npm_config_prefix=$(HOST_INSTALL_DIR)/usr/ \
	npm_config_cache=$(TMP_DIR)/npm-cache-$(HOSTTMPNPM) \
	npm_config_tmp=$(TMP_DIR)/npm-tmp-$(HOSTTMPNPM)

define Host/Compile
	$(HOST_NPM_FLAGS) npm i -g --production $(HOST_BUILD_DIR)
	$(HOST_NPM_FLAGS) npm i --production --prefix=$(HOST_BUILD_DIR) --target_arch=$(NODEJS_CPU) --prefer-dedupe
	rm -rf $(TMP_DIR)/npm-tmp-$(HOSTTMPNPM)
	rm -rf $(TMP_DIR)/npm-cache-$(HOSTTMPNPM)
endef

define Host/Install
	$(INSTALL_DIR) $(1)/lib/node_modules/$(PKG_NPM_NAME)
	$(CP) $(HOST_INSTALL_DIR)/usr/lib/node_modules/$(PKG_NPM_NAME)/{package.json,LICENSE} \
		$(1)/lib/node_modules/$(PKG_NPM_NAME)/
	$(CP) $(HOST_INSTALL_DIR)/usr/lib/node_modules/$(PKG_NPM_NAME)/{src,lib,sea} \
		$(1)/lib/node_modules/$(PKG_NPM_NAME)/
	$(CP) $(HOST_INSTALL_DIR)/usr/lib/node_modules/$(PKG_NPM_NAME)/{types,gun.d.ts,index.d.js,sea.d.js} \
		$(1)/lib/node_modules/$(PKG_NPM_NAME)/
	$(CP) $(HOST_INSTALL_DIR)/usr/lib/node_modules/$(PKG_NPM_NAME)/{as.js,axe.js,gun.js,index.js,nts.js,sea.js} \
		$(1)/lib/node_modules/$(PKG_NPM_NAME)/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,gun))