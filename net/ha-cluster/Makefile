# SPDX-License-Identifier: MIT
# Copyright (c) 2025-2026 Pierre Gaufillet <pierre.gaufillet@bergamote.eu>

include $(TOPDIR)/rules.mk

PKG_NAME:=ha-cluster
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Pierre Gaufillet <pierre.gaufillet@bergamote.eu>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/ha-cluster
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=High Availability Cluster Management
  DEPENDS:=+keepalived
  PKGARCH:=all
endef

define Package/ha-cluster/description
  UCI-based HA cluster orchestration for OpenWrt.
  Coordinates keepalived (VRRP), owsync (config sync), and lease-sync
  (DHCP sync) to provide seamless failover for routers.
  owsync and lease-sync are optional and detected at runtime.
endef

define Package/ha-cluster/conffiles
/etc/config/ha-cluster
/etc/ha-cluster/service_states
endef

define Build/Compile
	# Nothing to compile - shell scripts only
endef

define Package/ha-cluster/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ha-cluster.config $(1)/etc/config/ha-cluster

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ha-cluster.init $(1)/etc/init.d/ha-cluster

	$(INSTALL_DIR) $(1)/usr/lib/ha-cluster
	$(INSTALL_BIN) ./files/ha-cluster.sh $(1)/usr/lib/ha-cluster/

endef

define Package/ha-cluster/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ha-cluster stop >/dev/null 2>&1
	/etc/init.d/ha-cluster disable >/dev/null 2>&1
fi
exit 0
endef

define Package/ha-cluster/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	/etc/init.d/ha-cluster enable
}
exit 0
endef

$(eval $(call BuildPackage,ha-cluster))
