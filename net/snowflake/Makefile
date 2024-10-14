include $(TOPDIR)/rules.mk

PKG_NAME:=snowflake
PKG_VERSION:=2.9.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=7b57423a1b326505999bbd3c96f60d3ef309399d5c16bb47755c39aed2deafbb

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>, Nick Hainke <vincent@systemli.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/v2

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/snowflake/Default
  TITLE:=Snowflake
  URL:=https://snowflake.torproject.org/
  DEPENDS:=$(GO_ARCH_DEPENDS)
  SECTION:=net
  CATEGORY:=Network
  USERID:=snowflake:snowflake
endef

define Package/snowflake-broker
$(call Package/snowflake/Default)
  TITLE+= Broker
endef

define Package/snowflake-client
$(call Package/snowflake/Default)
  TITLE+= Client
endef

define Package/snowflake-probetest
$(call Package/snowflake/Default)
  TITLE+= Probe test
endef

define Package/snowflake-proxy
$(call Package/snowflake/Default)
  TITLE+= Proxy
endef

define Package/snowflake-server
$(call Package/snowflake/Default)
  TITLE+= Server
endef

define Package/snowflake/description/Default
Snowflake is a system that allows people from all over the world to
access censored websites and applications. Similar to how VPNs assist
users in getting around Internet censorship, Snowflake helps you avoid
being noticed by Internet censors by making your Internet activity appear
as though you're using the Internet for a regular video or voice call.
endef

define Package/snowflake-broker/description
$(call Package/snowflake/description/Default)

This package provides the Snowflake broker service.
endef

define Package/snowflake-client/description
$(call Package/snowflake/description/Default)

This package contains the Snowflake client which provides the bridge to TOR.
endef

define Package/snowflake-probetest/description
$(call Package/snowflake/description/Default)

This package provides the Snowflake probe test.
endef

define Package/snowflake-proxy/description
$(call Package/snowflake/description/Default)

This package provides the standalone Snowflake proxy.
endef

define Package/snowflake-server/description
$(call Package/snowflake/description/Default)

This package provides the Snowflake server.
endef

define Package/snowflake-broker/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/broker $(1)/usr/bin/snowflake-broker
endef

define Package/snowflake-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/client $(1)/usr/bin/snowflake-client
endef

define Package/snowflake-probetest/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/probetest $(1)/usr/bin/snowflake-probetest
endef

define Package/snowflake-proxy/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/proxy $(1)/usr/bin/snowflake-proxy
	$(INSTALL_BIN) ./files/snowflake-proxy.init $(1)/etc/init.d/snowflake-proxy
endef

define Package/snowflake-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/server $(1)/usr/bin/snowflake-server
endef

$(eval $(call BuildPackage,snowflake-broker))
$(eval $(call BuildPackage,snowflake-client))
$(eval $(call BuildPackage,snowflake-probetest))
$(eval $(call BuildPackage,snowflake-proxy))
$(eval $(call BuildPackage,snowflake-server))
