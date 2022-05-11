# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=cloudreve
PKG_VERSION:=3.5.3
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cloudreve/Cloudreve.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=c43ec528df19d239b06456e78aae3d9852da5cca372c157b62f1f74b03f5cc0d

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host node/host node-yarn/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/cloudreve/Cloudreve/v3
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/pkg/conf.BackendVersion=$(PKG_VERSION) \
	$(GO_PKG)/pkg/conf.LastCommit=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/cloudreve
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Cloud Manager
  TITLE:=A project helps you build your own cloud in minutes
  URL:=https://cloudreve.org
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/cloudreve/description
  Self-deployed file management and sharing system, supports multiple
  storage providers.
endef

define Build/Compile
	( \
		pushd $(PKG_BUILD_DIR)/assets ; \
		yarn install ; \
		yarn run build ; \
		popd ; \
		$(call GoPackage/Build/Compile) ; \
	)
endef

define Package/cloudreve/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/Cloudreve $(1)/usr/bin/cloudreve
endef

$(eval $(call GoBinPackage,cloudreve))
$(eval $(call BuildPackage,cloudreve))
