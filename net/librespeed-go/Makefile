# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=librespeed-go
PKG_VERSION:=1.1.5
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/librespeed/speedtest-go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a65bbb94868d9ad73f85950264cb18fafb2ba5cf4788ac67981d78b863ca67c4

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/librespeed/speedtest

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/librespeed-go
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Go backend for LibreSpeed
  URL:=https://github.com/librespeed/speedtest-go
  DEPENDS:=$(GO_ARCH_DEPENDS)
  USERID:=librespeed:librespeed
endef

define Package/librespeed-go/description
  This is a very lightweight speed test implemented in JavaScript,
  using XMLHttpRequest and Web Workers.

  No Flash, No Java, No WebSocket, No Bullshit.
endef

define Package/librespeed-go/conffiles
/etc/librespeed-go
/etc/config/librespeed-go
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	$(CP) $(PKG_BUILD_DIR)/web/assets/example-singleServer-progressBar.html \
		$(PKG_BUILD_DIR)/web/assets/index.html

	$(SED) 's,LibreSpeed Example,LibreSpeed for OpenWrt,g' \
		$(PKG_BUILD_DIR)/web/assets/*.html
endef

define Package/librespeed-go/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/speedtest $(1)/usr/bin/librespeed-go

	$(INSTALL_DIR) $(1)/etc/librespeed-go
	$(CP) $(PKG_BUILD_DIR)/database/mysql/telemetry_mysql.sql $(1)/etc/librespeed-go/
	$(CP) $(PKG_BUILD_DIR)/database/postgresql/telemetry_postgresql.sql $(1)/etc/librespeed-go/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/librespeed-go.config $(1)/etc/config/librespeed-go
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/librespeed-go.init $(1)/etc/init.d/librespeed-go
endef

$(eval $(call GoBinPackage,librespeed-go))
$(eval $(call BuildPackage,librespeed-go))
