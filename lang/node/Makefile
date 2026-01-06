#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=node
PKG_VERSION:=22.14.0
PKG_RELEASE:=1
NODE_MODULE_VERSION:=127

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://nodejs.org/dist/v$(PKG_VERSION)
PKG_HASH:=6c4e31ed5702dc45cfd8c435af56a36a474427e1bd7afe74c346136060beba8a
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)
NODEJS_BIN_SUM:=9d942932535988091034dc94cc5f42b6dc8784d6366df3a36c4c9ccb3996f0c2
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Hirokazu MORIKAWA <morikw2@gmail.com>, Adrian Panella <ianchi74@outlook.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:nodejs:node.js

HOST_BUILD_DEPENDS:=python3/host
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/node
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Node.js
  TITLE:=Node.js is a platform built on Chrome's JavaScript runtime
  URL:=https://nodejs.org/
  ABI_VERSION:=$(NODE_MODULE_VERSION)
  BUILDONLY:=1
endef

define Package/node/description
  Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine. Node.js uses
  an event-driven, non-blocking I/O model that makes it lightweight and efficient. Node.js'
   package ecosystem, npm, is the largest ecosystem of open source libraries in the world.
endef

HOST_MAKE_VARS+=NO_LOAD='cctest.target.mk embedtest.target.mk overlapped-checker.target.mk'

HOST_CONFIGURE_VARS:=
HOST_CONFIGURE_ARGS:= \
	--dest-os=$(if $(findstring Darwin,$(HOST_OS)),mac,linux) \
	--with-intl=small-icu \
	--prefix=$(STAGING_DIR_HOSTPKG)

ifeq ($(HOST_ARCH),x86_64)

NODEJS_BIN:=node-v$(PKG_VERSION)-linux-x64.tar.gz

define Download/nodebin
	URL:=https://nodejs.org/download/release/v$(PKG_VERSION)/
	FILE:=$(NODEJS_BIN)
	HASH:=$(NODEJS_BIN_SUM)
endef

define Host/Prepare
	$(eval $(call Download,nodebin))
endef

define Host/Configure
	# nothing to do
endef

define Host/Compile
	# nothing to do
endef

define Host/Install
	rm -f $(1)/bin/npm
	rm -f $(1)/bin/npx
	rm -rf $(1)/lib/node_modules/npm
	rm -f $(1)/bin/corepack
	rm -rf $(1)/lib/node_modules/corepack
	$(TAR) xvf $(DL_DIR)/$(NODEJS_BIN) -C $(1) --strip-components=1
	mv $(1)/{CHANGELOG.md,LICENSE,README.md} $(1)/lib/node_modules/
endef

else
define Host/Install
	rm -f $(1)/bin/npm
	rm -f $(1)/bin/npx
	rm -rf $(1)/lib/node_modules/npm
	rm -f $(1)/bin/corepack
	rm -rf $(1)/lib/node_modules/corepack
	$(call Host/Install/Default)
endef
endif

$(eval $(call HostBuild))
$(eval $(call BuildPackage,node))
