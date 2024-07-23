# Copyright (C) 2023 Findlay Feng <i@fengch.me>

include $(TOPDIR)/rules.mk

PKG_NAME:=hysteria
PKG_VERSION:=2.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/apernet/hysteria/tar.gz/app/v$(PKG_VERSION)?
PKG_HASH:=78afca9c9c3f2c1a89c2356c66e70489bba74d3b4ede42f4194d179a09959d8c

GO_PKG:=github.com/apernet/hysteria

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Findlay Feng <i@fengch.me>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-values.mk

GO_PKG_BUILD_PKG=$(GO_PKG)/app/v2
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG_BUILD_PKG)/cmd.appDate=$(shell date -u '+%F.%T') \
	$(GO_PKG_BUILD_PKG)/cmd.appVersion=v$(PKG_VERSION) \
	$(GO_PKG_BUILD_PKG)/cmd.appCommit=app/v$(PKG_VERSION) \
	$(GO_PKG_BUILD_PKG)/cmd.appPlatform=linux \
	$(GO_PKG_BUILD_PKG)/cmd.appType=release \
	$(GO_PKG_BUILD_PKG)/cmd.appArch=$(GO_ARCH)

GO_INCLUDE_DIR?=$(TOPDIR)/feeds/packages/lang/golang
include $(GO_INCLUDE_DIR)/golang-package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=Hysteria is a powerful, lightning fast and censorship resistant proxy.
	URL:=https://hysteria.network
endef

define Package/$(PKG_NAME)-configs
	$(call Package/$(PKG_NAME))
	TITLE:=configs
	DEPENDS:=$(PKG_NAME)
	USERID:=hysteria=102:hysteria=102
endef

define Package/$(PKG_NAME)-serverd
	$(call Package/$(PKG_NAME))
	TITLE:=server init scripts
	DEPENDS:=$(PKG_NAME) +$(PKG_NAME)-configs
endef

define Package/$(PKG_NAME)-clientd
	$(call Package/$(PKG_NAME))
	TITLE:=client init scripts
	DEPENDS:=$(PKG_NAME) +$(PKG_NAME)-configs \
		+kmod-nft-tproxy +kmod-nft-socket \
		+dnsmasq-full
endef

define Package/$(PKG_NAME)/description
	Hysteria is a powerful, lightning fast and censorship resistant proxy.
	And probably the cutest, too.
	Powered by a customized QUIC protocol, Hysteria is designed to deliver
	unparalleled performance over unreliable and lossy networks.
endef

define Package/$(PKG_NAME)-configs/description
	$(call Package/$(PKG_NAME)/description)
endef

define Package/$(PKG_NAME)-serverd/description
	$(call Package/$(PKG_NAME)/description)
endef

define Package/$(PKG_NAME)-clientd/description
	$(call Package/$(PKG_NAME)/description)
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/sysctl.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/app $(1)/usr/bin/$(PKG_NAME)

	$(INSTALL_CONF) ./files/sysctl-hysteria.conf $(1)/etc/sysctl.d/11-$(PKG_NAME).conf
endef

define Package/$(PKG_NAME)-configs/install
	$(INSTALL_DIR) \
		$(1)/etc/config \
		$(1)/etc/capabilities

	$(INSTALL_CONF) ./files/hysteria.json $(1)/etc/capabilities/$(PKG_NAME).json
	$(INSTALL_CONF) ./files/hysteria.config $(1)/etc/config/$(PKG_NAME)
endef

define Package/$(PKG_NAME)-serverd/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/etc/$(PKG_NAME)

	$(INSTALL_BIN) ./files/hysteria-serverd.init $(1)/etc/init.d/$(PKG_NAME)-serverd
	$(INSTALL_DATA) ./files/configs/server.yaml $(1)/etc/$(PKG_NAME)/
endef

define Package/$(PKG_NAME)-clientd/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/usr/share/$(PKG_NAME)/bin \
		$(1)/etc/$(PKG_NAME)

	$(INSTALL_BIN) ./files/hysteria.init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_BIN) ./files/bin/hysteria-tproxy.sh $(1)/usr/share/$(PKG_NAME)/bin/set-tproxy
	$(INSTALL_DATA) ./files/configs/client.yaml $(1)/etc/$(PKG_NAME)/
endef

define Package/$(PKG_NAME)-configs/conffiles
/etc/config/$(PKG_NAME)
endef

define Package/$(PKG_NAME)-serverd/conffiles
/etc/${PKG_NAME}/
endef

define Package/$(PKG_NAME)-clientd/conffiles
/etc/${PKG_NAME}/
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-configs))
$(eval $(call BuildPackage,$(PKG_NAME)-serverd))
$(eval $(call BuildPackage,$(PKG_NAME)-clientd))
