# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2025-2026 Pierre Gaufillet <pierre.gaufillet@bergamote.eu>

include $(TOPDIR)/rules.mk

PKG_NAME:=lease-sync
PKG_VERSION:=1.2.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/pgaufillet/lease-sync/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d1ceb38c2dbff538d50ecd6980931bef3541ee2071901c544ea1110deed2ce2d

PKG_MAINTAINER:=Pierre Gaufillet <pierre.gaufillet@bergamote.eu>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lease-sync
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=DHCP Lease Synchronization Daemon
  URL:=https://github.com/pgaufillet/lease-sync
  DEPENDS:=+libubus +libubox +libopenssl +dnsmasq
endef

define Package/lease-sync/description
  High-availability DHCP lease synchronization daemon for dnsmasq.
  Enables active/active HA clusters by synchronizing DHCP leases
  between multiple dnsmasq instances via ubus and UDP.
endef

define Package/lease-sync/conffiles
/etc/config/lease-sync
/etc/lease-sync/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/daemon \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS="-lubus -lubox -lssl -lcrypto" \
		STATEDIR="/etc/lease-sync"
endef

define Package/lease-sync/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/daemon/lease-sync $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/lease-sync.init $(1)/etc/init.d/lease-sync

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/lease-sync.config $(1)/etc/config/lease-sync

	$(INSTALL_DIR) $(1)/etc/lease-sync

	$(INSTALL_DIR) $(1)/etc/hotplug.d/dhcp
	$(INSTALL_BIN) ./files/lease-sync.hotplug $(1)/etc/hotplug.d/dhcp/50-lease-sync

endef

define Package/lease-sync/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/lease-sync stop >/dev/null 2>&1
	/etc/init.d/lease-sync disable >/dev/null 2>&1
fi
exit 0
endef

define Package/lease-sync/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	echo "NOTE: Restart dnsmasq to activate the DHCP hotplug handler:"
	echo "  /etc/init.d/dnsmasq restart"
}
exit 0
endef

$(eval $(call BuildPackage,lease-sync))
