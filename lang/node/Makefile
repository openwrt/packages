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
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Hirokazu MORIKAWA <morikw2@gmail.com>, Adrian Panella <ianchi74@outlook.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:nodejs:node.js

HOST_BUILD_DEPENDS:=python3/host
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=python3/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_ASLR_PIE:=0

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/node
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Node.js
  TITLE:=Node.js is a platform built on Chrome's JavaScript runtime
  URL:=https://nodejs.org/
  DEPENDS:=@HAS_FPU @(i386||x86_64||arm||aarch64) @BROKEN \
	   +libstdcpp +libopenssl +zlib +libnghttp2 \
	   +libcares +libatomic +NODEJS_ICU_SYSTEM:icu +NODEJS_ICU_SYSTEM:icu-full-data
  ABI_VERSION:=$(NODE_MODULE_VERSION)
endef

define Package/node/description
  Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine. Node.js uses
  an event-driven, non-blocking I/O model that makes it lightweight and efficient. Node.js'
   package ecosystem, npm, is the largest ecosystem of open source libraries in the world.

  *** The following preparations must be made on the host side. ***
      1. gcc 10.1 or higher is required.
      2. To build a 32-bit target, gcc-multilib, g++-multilib are required.
      3. Requires libatomic package. (If necessary, install the 32-bit library at the same time.)
     ex) sudo apt-get install gcc-multilib g++-multilib
endef

define Package/node-npm
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Node.js
  TITLE:=NPM stands for Node Package Manager
  URL:=https://www.npmjs.com/
  DEPENDS:=+node
endef

define Package/node-npm/description
	NPM is the package manager for NodeJS
endef

define Package/node/config
	if PACKAGE_node
	choice
		prompt "i18n features"
		default NODEJS_ICU_SMALL
		help
		 Select i18n features

		config NODEJS_ICU_NONE
			bool "Disable"

		config NODEJS_ICU_SMALL
			bool "small-icu"

		config NODEJS_ICU_SYSTEM
			depends on ARCH_64BIT
			bool "system-icu"
	endchoice
	endif
endef

NODEJS_CPU:=$(subst aarch64,arm64,$(subst x86_64,x64,$(subst i386,ia32,$(ARCH))))

ifneq ($(CONFIG_ARCH_64BIT),y)
FORCE_32BIT:=-m32
endif

MAKE_VARS+= \
	DESTCPU=$(NODEJS_CPU) \
	NO_LOAD='cctest.target.mk embedtest.target.mk node_mksnapshot.target.mk overlapped-checker.target.mk \
		mkcodecache.target.mk tools/v8_gypfiles/torque_base.target.mk tools/v8_gypfiles/v8_init.target.mk' \
	LD_LIBRARY_PATH=$(STAGING_DIR_HOSTPKG)/share/icu/current/lib

HOST_MAKE_VARS+=NO_LOAD='cctest.target.mk embedtest.target.mk overlapped-checker.target.mk'

CONFIGURE_VARS:= \
	CC="$(TARGET_CC) $(TARGET_OPTIMIZATION)" \
	CXX="$(TARGET_CXX) $(TARGET_OPTIMIZATION)" \
	CC_host="$(HOSTCC) $(FORCE_32BIT)" \
	CXX_host="$(HOSTCXX) $(FORCE_32BIT)"

CONFIGURE_ARGS:= \
	--dest-cpu=$(NODEJS_CPU) \
	--dest-os=linux \
	--cross-compiling \
	--shared-zlib \
	--shared-openssl \
	--shared-nghttp2 \
	--shared-cares \
	--with-intl=$(if $(CONFIG_NODEJS_ICU_SMALL),small-icu,$(if $(CONFIG_NODEJS_ICU_SYSTEM),system-icu,none)) \
	$(if $(findstring +neon",$(CONFIG_CPU_TYPE)),--with-arm-fpu=neon) \
	$(if $(findstring +neon-vfpv4",$(CONFIG_CPU_TYPE)),--with-arm-fpu=neon) \
	$(if $(findstring +vfpv4",$(CONFIG_CPU_TYPE)),--with-arm-fpu=vfpv3) \
	$(if $(findstring +vfp",$(CONFIG_CPU_TYPE)),--with-arm-fpu=vfp) \
	$(if $(findstring +vfpv3",$(CONFIG_CPU_TYPE)),--with-arm-fpu=vfpv3) \
	$(if $(findstring +vfpv3-d16",$(CONFIG_CPU_TYPE)),--with-arm-fpu=vfpv3-d16) \
	--prefix=/usr

HOST_CONFIGURE_VARS:=

HOST_CONFIGURE_ARGS:= \
	--dest-os=$(if $(findstring Darwin,$(HOST_OS)),mac,linux) \
	--with-intl=small-icu \
	--prefix=$(STAGING_DIR_HOSTPKG)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
endef

define Package/node/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/node $(1)/usr/bin/
endef

define Package/node-npm/install
	$(INSTALL_DIR) $(1)/usr/lib/node_modules/npm
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/npm/{package.json,LICENSE} \
		$(1)/usr/lib/node_modules/npm/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/npm/README.md \
		$(1)/usr/lib/node_modules/npm/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/npm/{node_modules,bin,lib} \
		$(1)/usr/lib/node_modules/npm/
	$(INSTALL_DIR) $(1)/usr/bin
	$(LN) ../lib/node_modules/npm/bin/npm-cli.js $(1)/usr/bin/npm
	$(LN) ../lib/node_modules/npm/bin/npx-cli.js $(1)/usr/bin/npx
endef

define Host/Install
	rm -f $(1)/bin/npm
	rm -f $(1)/bin/npx
	rm -rf $(1)/lib/node_modules/npm
	rm -f $(1)/bin/corepack
	rm -rf $(1)/lib/node_modules/corepack
	$(call Host/Install/Default)
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,node))
$(eval $(call BuildPackage,node-npm))
