#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=node
PKG_VERSION:=22.23.2
PKG_RELEASE:=1
NODE_MODULE_VERSION:=127

NODEJS_HOST_OS:=$(if $(findstring Darwin,$(HOST_OS)),darwin,linux)
NODEJS_HOST_ARCH:=$(if $(filter aarch64 arm64,$(HOST_ARCH)),arm64,$(if $(filter x86_64,$(HOST_ARCH)),x64,))
NODEJS_HOST_LIBC:=$(lastword $(subst -, ,$(GNU_HOST_NAME)))

NODEJS_BIN_SUM_DARWIN_ARM64:=5eff7a9011895aae3f29d06f167b84a62b028a591370c7cafb59103559fd26e1
NODEJS_BIN_SUM_DARWIN_X64:=96dff79f4e19a78715da559ec7cac2028f4985a175ea0c3454625a269c21deb7
NODEJS_BIN_SUM_LINUX_ARM64:=fff4078c5def658577f92c88db7db3bc0072924bfb93fe52c1e744a54e94abb8
NODEJS_BIN_SUM_LINUX_ARM64_MUSL:=86e3f4d05d92c6a4e51b0ce8bab6c22d602d4b8a372743fed302403de5376d4c
NODEJS_BIN_SUM_LINUX_X64:=d60acfe00a2932254bb0ad20e01b0d74397a0875595de719654b214f4b03f307
NODEJS_BIN_SUM_LINUX_X64_MUSL:=2d18b5731055f7efa6c899004909b00ee110e38d3775745f60ec9ccf1f9982e7

# Set from the environment or the make command line to disable prebuilt
# binaries and build Node.js from source instead.
NODE_USE_PREBUILT_BINARIES ?= y
HOST_PREPARED_DEPENDS:=NODE_USE_PREBUILT_BINARIES

NODEJS_BIN_SUM:=$(NODEJS_BIN_SUM_$(call toupper,$(NODEJS_HOST_OS)_$(NODEJS_HOST_ARCH)$(if $(filter musl,$(NODEJS_HOST_LIBC)),_MUSL)))
$(if $(NODEJS_BIN_SUM),,$(warning node: No prebuilt binary for HOST_OS='$(NODEJS_HOST_OS)' HOST_ARCH='$(NODEJS_HOST_ARCH)' HOST_LIBC='$(NODEJS_HOST_LIBC)', falling back to source build))
ifneq ($(NODE_USE_PREBUILT_BINARIES),y)
  NODEJS_BIN_SUM:=
endif

ifneq ($(NODEJS_BIN_SUM),)
  ifeq ($(NODEJS_HOST_LIBC),musl)
    PKG_SOURCE:=node-v$(PKG_VERSION)-$(NODEJS_HOST_OS)-$(NODEJS_HOST_ARCH)-musl.tar.xz
    PKG_SOURCE_URL:=https://unofficial-builds.nodejs.org/download/release/v$(PKG_VERSION)/
  else
    PKG_SOURCE:=node-v$(PKG_VERSION)-$(NODEJS_HOST_OS)-$(NODEJS_HOST_ARCH).tar.xz
    PKG_SOURCE_URL:=https://nodejs.org/download/release/v$(PKG_VERSION)/
  endif
  PKG_HASH:=$(NODEJS_BIN_SUM)
else
  PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.xz
  PKG_SOURCE_URL:=https://nodejs.org/dist/v$(PKG_VERSION)
  PKG_HASH:=bbe768df8d5815d7fa76124052985332452e0a4742d39f32027550d1aab8f6fb
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Hirokazu MORIKAWA <morikw2@gmail.com>, Adrian Panella <ianchi74@outlook.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:nodejs:node.js

HOST_BUILD_DEPENDS:=$(if $(NODEJS_BIN_SUM),,python3/host)
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

define Host/Install/Clean
	-rm -f \
		$(1)/bin/npm \
		$(1)/bin/npx \
		$(1)/bin/corepack
	-rm -rf \
		$(1)/lib/node_modules/npm \
		$(1)/lib/node_modules/corepack
endef

ifneq ($(NODEJS_BIN_SUM),)

HOST_UNPACK:=$(HOST_TAR) -C "$(HOST_BUILD_DIR)" --strip-components=1 -xf "$(DL_DIR)/$(PKG_SOURCE)"

define Host/Patch
	@:
endef

define Host/Configure
	@:
endef

define Host/Compile
	@:
endef

define Host/Install
	$(call Host/Install/Clean,$(1))
	$(INSTALL_DIR) $(1)
	$(CP) $(HOST_BUILD_DIR)/* $(1)/
	mv $(1)/CHANGELOG.md $(1)/LICENSE $(1)/README.md $(1)/lib/node_modules/
endef

else

HOST_MAKE_VARS+=NO_LOAD='cctest.target.mk embedtest.target.mk overlapped-checker.target.mk'

HOST_CONFIGURE_VARS:=
HOST_CONFIGURE_ARGS:= \
	--dest-os=$(if $(findstring Darwin,$(HOST_OS)),mac,linux) \
	--with-intl=small-icu \
	--prefix=$(STAGING_DIR_HOSTPKG)

define Host/Install
	$(call Host/Install/Clean,$(1))
	$(call Host/Install/Default)
endef
endif

$(eval $(call HostBuild))
$(eval $(call BuildPackage,node))
