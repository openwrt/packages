# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=alist
PKG_VERSION:=3.30.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/alist-org/alist/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=68831d5177cdbae3ab294ce4263b4221c0ff687a72dd48a844d533ccb13c3efb

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/alist-org/alist/v3
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/internal/conf.Version=$(PKG_VERSION) \
	$(GO_PKG)/internal/conf.WebVersion=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/alist
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A file list program that supports multiple storage
  URL:=https://alist.nn.ci
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +fuse-utils
endef

define Package/alist/description
  A file list program that supports multiple storage, and supports
  web browsing and webdav, powered by gin and Solidjs.
endef

define Package/alist/conffiles
/etc/alist/
/etc/config/alist
endef

WEB_VERSION:=3.30.0
WEB_FILE:=$(PKG_NAME)-web-$(WEB_VERSION).tar.gz
define Download/alist-web
	URL:=https://github.com/alist-org/alist-web/releases/download/$(WEB_VERSION)/
	URL_FILE:=dist.tar.gz
	FILE:=$(WEB_FILE)
	HASH:=04e160efc6e7169103cd424a39de0f1720e769aacc49dc0a2fcc3f1fcc6d0fee
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	( \
		mkdir -p $(PKG_BUILD_DIR)/public ; \
		gzip -dc $(DL_DIR)/$(WEB_FILE) | $(HOST_TAR) -C $(PKG_BUILD_DIR)/public $(TAR_OPTIONS) ; \
	)
endef

ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Package/alist/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/alist $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/alist.config $(1)/etc/config/alist
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/alist.init $(1)/etc/init.d/alist
endef

$(eval $(call Download,alist-web))
$(eval $(call GoBinPackage,alist))
$(eval $(call BuildPackage,alist))
