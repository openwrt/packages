include $(TOPDIR)/rules.mk

PKG_NAME:=qbee-agent
PKG_VERSION:=2025.34
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/qbee-io/qbee-agent.git
PKG_SOURCE_VERSION:=e1c6ced58a7d5714ba413695a105177da0d5dd3a
PKG_MIRROR_HASH:=c27f89de3456d63af575e234d919cea916f892779e56f34b6a80659d5daa7d7e

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jon Henrik Bjørnstad <jonhenrik@qbee.io>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

GO_PKG:=go.qbee.io/agent
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/app.Version=$(PKG_VERSION) \
	$(GO_PKG)/app.Commit=$(PKG_SOURCE_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/qbee-agent
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=qbee.io fleet management agent
  URL:=https://qbee.io
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/qbee-agent/description
  qbee.io is a SaaS provided fleet management solution. This package
  provides the agent that runs on the device and communicates with
  the qbee.io server.
endef

define Package/qbee-agent/install
	$(INSTALL_DIR) $(1)/etc/qbee/ppkeys
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/share/ssl/ca.cert $(1)/etc/qbee/ppkeys/ca.cert

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/agent $(1)/usr/bin/qbee-agent

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/qbee-agent.init $(1)/etc/init.d/qbee-agent
endef

$(eval $(call BuildPackage,qbee-agent))
