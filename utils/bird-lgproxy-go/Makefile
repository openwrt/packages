include $(TOPDIR)/rules.mk

PKG_NAME:=bird-lgproxy-go
PKG_VERSION:=1.3.10
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/xddxdd/bird-lg-go/archive/refs/tags/
PKG_HASH:=493c76519f85396ffb01ec38a8d72b5bfce4a7ceb8d0470efea6a735cf71189a

PKG_BUILD_DIR=$(BUILD_DIR)/bird-lg-go-$(PKG_VERSION)

PKG_MAINTAINER:=Grafcube <grafcube@disroot.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/xddxdd/bird-lg-go/proxy
GO_PKG_BUILD_PKG:=$(GO_PKG)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

GO_PKG_BUILD_VARS += GO111MODULE=auto

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) $(PKG_BUILD_DIR)/proxy/* $(PKG_BUILD_DIR)/
endef

define Package/bird-lgproxy-go
	URL:=https://github.com/xddxdd/bird-lg-go
	DEPENDS:=$(GO_ARCH_DEPENDS)
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=BIRD looking glass proxy in Go
endef

define Package/bird-lgproxy-go/conffiles
	/etc/bird-lg/bird-lgproxy.json
endef

define Package/bird-lgproxy-go/description
	BIRD looking glass in Go, for better maintainability, easier deployment &
	smaller memory footprint
endef

define Package/bird-lgproxy-go/install
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/bird-lg

	$(INSTALL_CONF) $(CURDIR)/files/bird-lgproxy.json $(1)/etc/bird-lg/bird-lgproxy.json

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/bird-lgproxy-go.init $(1)/etc/init.d/bird-lgproxy-go

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/proxy $(1)/usr/bin/bird-lgproxy-go
endef

$(eval $(call BuildPackage,bird-lgproxy-go))
