# SPDX-License-Identifier: Apache-2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt-presence-agent
PKG_VERSION:=0.2.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/theoabw/openwrt-presence-agent/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=da79dce581a436d92bddcd94375b749f90f98fb16f3b98cc55678219a0c16b7d

PKG_MAINTAINER:=Theo Wilenius <theo@tabw.dev>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE NOTICE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/theoabw/openwrt-presence-agent
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/openwrt-presence-agent
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/openwrt-presence-agent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Event-driven OpenWrt client observation service
  URL:=https://github.com/theoabw/openwrt-presence-agent
  DEPENDS:=$(GO_ARCH_DEPENDS) +ubus +iputils-arping
endef

define Package/openwrt-presence-agent/description
  Publishes authenticated, normalized Wi-Fi and Ethernet client snapshots and
  low-latency connection events for trusted local consumers. DHCP leases supply
  candidate wired addresses; fresh neighbor events or ARP replies confirm wired
  presence.
endef

define Package/openwrt-presence-agent/conffiles
/etc/config/openwrt-presence-agent
/etc/openwrt-presence-agent/
endef

define Package/openwrt-presence-agent/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/openwrt-presence-agent \
		$(1)/usr/bin/openwrt-presence-agent
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/openwrt-presence-agent.config \
		$(1)/etc/config/openwrt-presence-agent
	$(INSTALL_DIR) $(1)/etc/openwrt-presence-agent
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/openwrt-presence-agent.init \
		$(1)/etc/init.d/openwrt-presence-agent
endef

define Package/openwrt-presence-agent/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
umask 077
mkdir -p /etc/openwrt-presence-agent
if [ ! -s /etc/openwrt-presence-agent/token ]; then
	tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 48 > /etc/openwrt-presence-agent/token
fi
chmod 600 /etc/openwrt-presence-agent/token
exit 0
endef

$(eval $(call GoBinPackage,openwrt-presence-agent))
$(eval $(call BuildPackage,openwrt-presence-agent))
