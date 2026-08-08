# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Jia Liu <support@51sdwan.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=51sdwan
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/21hkcloud/51sdwan-openwrt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=7ea02e94f369aa906eec6b2a89e8e0f406ea1e9ae80864bee4bc87e6ea5db675

PKG_MAINTAINER:=Jia Liu <support@51sdwan.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=core/LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/51sdwan
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=51SDWAN OpenWrt edge agent
  URL:=https://www.51sdwan.com/en/openwrt
  PKGARCH:=all
  DEPENDS:=+ca-bundle +curl +ip-full +jshn +jsonfilter +kmod-wireguard +rpcd +wireguard-tools
endef

define Package/51sdwan/description
  Enrolls an OpenWrt router into the existing 51SDWAN control plane and
  manages its WireGuard tunnel, routing policy, heartbeat and reconnects.
endef

define Build/Compile
endef

define Package/51sdwan/conffiles
/etc/config/51sdwan
endef

define Package/51sdwan/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/core/files/etc/config/51sdwan $(1)/etc/config/51sdwan
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/files/etc/init.d/51sdwan $(1)/etc/init.d/51sdwan
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/files/etc/hotplug.d/iface/95-51sdwan $(1)/etc/hotplug.d/iface/95-51sdwan
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/files/etc/uci-defaults/90-51sdwan $(1)/etc/uci-defaults/90-51sdwan
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/files/usr/bin/51sdwanctl $(1)/usr/bin/51sdwanctl
	$(INSTALL_DIR) $(1)/usr/lib/51sdwan
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/core/files/usr/lib/51sdwan/common.sh $(1)/usr/lib/51sdwan/common.sh
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/files/usr/libexec/rpcd/51sdwan-rpcd $(1)/usr/libexec/rpcd/51sdwan
	$(INSTALL_DIR) $(1)/usr/libexec/51sdwan
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/files/usr/libexec/51sdwan/login-worker $(1)/usr/libexec/51sdwan/login-worker
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/files/usr/sbin/51sdwan-agent $(1)/usr/sbin/51sdwan-agent
endef

define Package/51sdwan/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	enabled="$$(uci -q get 51sdwan.main.enabled)"
	case "$${enabled}" in 1|on|true|yes|enabled)
		/etc/init.d/51sdwan enable >/dev/null 2>&1 || true
		/etc/init.d/51sdwan start >/dev/null 2>&1 || true
	;; esac
}
exit 0
endef

define Package/51sdwan/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	action="$${1:-remove}"
	/etc/init.d/51sdwan stop >/dev/null 2>&1 || true
	[ "$${action}" = upgrade ] || /etc/init.d/51sdwan disable >/dev/null 2>&1 || true
	/usr/bin/51sdwanctl disconnect >/dev/null 2>&1 || true
	if [ "$${action}" != upgrade ]; then
		changed=0
		for section in 51sdwan sdwan51_peer; do
			if uci -q get "network.$${section}" >/dev/null; then
				uci -q delete "network.$${section}"
				changed=1
			fi
		done
		[ "$${changed}" = 0 ] || uci -q commit network
		changed=0
		for section in sdwan51_zone sdwan51_forwarding sdwan51_block_ipv6; do
			if uci -q get "firewall.$${section}" >/dev/null; then
				uci -q delete "firewall.$${section}"
				changed=1
			fi
		done
		if [ "$${changed}" = 1 ]; then
			uci -q commit firewall
			/etc/init.d/firewall reload >/dev/null 2>&1 || true
		fi
	fi
}
exit 0
endef

define Package/51sdwan/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	case "$${1:-remove}" in
		upgrade) ;;
		*) rm -rf /etc/51sdwan /etc/config/51sdwan ;;
	esac
	rm -rf /tmp/51sdwan /tmp/51sdwan-login /tmp/51sdwan-login.lock
	/etc/init.d/rpcd restart >/dev/null 2>&1 || true
}
exit 0
endef

$(eval $(call BuildPackage,51sdwan))
