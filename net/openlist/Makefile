# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023-2025 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=openlist
PKG_VERSION:=4.1.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/OpenListTeam/OpenList/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f1b92628be09ba181decc46423c3e0624b78aedfcd28590990a46ba03d75e5e4
PKG_BUILD_DIR:=$(BUILD_DIR)/OpenList-$(PKG_VERSION)

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host fuse
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/OpenListTeam/OpenList/v4
GO_PKG_LDFLAGS_X = \
	$(GO_PKG)/internal/conf.Version=$(PKG_VERSION) \
	$(GO_PKG)/internal/conf.WebVersion=$(WEB_VERSION)
ifeq ($(filter aarch64 x86_64, $(ARCH)),)
  GO_PKG_EXCLUDES:=drivers/lark
endif

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/openlist
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A file list program that supports multiple storage
  URL:=https://docs.oplist.org
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  PROVIDES:=alist
endef

define Package/openlist/description
  A file list program that supports multiple storage, and supports
  web browsing and webdav, powered by gin and Solidjs, fork of AList.
endef

define Package/openlist/conffiles
/etc/openlist/
/etc/config/openlist
endef

WEB_VERSION:=4.1.7
WEB_FILE:=$(PKG_NAME)-frontend-dist-v$(WEB_VERSION).tar.gz
define Download/openlist-web
	URL:=https://github.com/OpenListTeam/OpenList-Frontend/releases/download/v$(WEB_VERSION)/
	URL_FILE:=$(WEB_FILE)
	FILE:=$(WEB_FILE)
	HASH:=82b54356ec168d8cd407f5f2c773271dfc65faa0640578feba6aca50bbb5b6f9
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	( \
		mkdir -p $(PKG_BUILD_DIR)/public/dist ; \
		libdeflate-gzip -dc $(DL_DIR)/$(WEB_FILE) | $(HOST_TAR) -C $(PKG_BUILD_DIR)/public/dist $(TAR_OPTIONS) ; \
	)
endef

ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Package/openlist/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/OpenList $(1)/usr/bin/openlist

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/openlist.config $(1)/etc/config/openlist
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/openlist.init $(1)/etc/init.d/openlist
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(CURDIR)/files/openlist.uci $(1)/etc/uci-defaults/99-migrate-openlist
endef

$(eval $(call Download,openlist-web))
$(eval $(call GoBinPackage,openlist))
$(eval $(call BuildPackage,openlist))
