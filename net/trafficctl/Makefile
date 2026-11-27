# SPDX-License-Identifier: Apache-2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=trafficctl
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/YusDyr/luci-app-trafficctl/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=349e2c92e682db71b0ed3f3df9381533920e86dca5383703a4b3bf912e7662e9
PKG_BUILD_DIR:=$(BUILD_DIR)/luci-app-trafficctl-$(PKG_VERSION)

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Denis Iusupov <yusdyr@gmail.com>

include $(INCLUDE_DIR)/package.mk

# The optional parts are packages of their own, so a router carries only what
# it uses: trafficctl-shaper (tc, kmod-sched-core, kmod-ifb), trafficctl-wifi
# (iw, hostapd-utils) and trafficctl-telegram (curl); trafficctl-full pulls in
# all three. shaper, wifi and full hold no files: without a part the core
# checks for its tools at run time, and `trafficctl device` reports shaping
# and wifi_filter.
# hostapd-utils is on trafficctl-wifi, not here: it can only be selected
# together with a hostapd/wpad variant, so a wired-only build leaves out
# trafficctl-wifi instead of the whole package.
# firewall4: blocks are rules in its inet fw4 table, so nftables alone is not
# enough.
# kmod-nft-netdev carries CONFIG_NF_TABLES_NETDEV, the nft family of the
# limiter's table (netdev tm_ratelimit); firewall4 does not pull it in.
define Package/trafficctl
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Per-device traffic monitoring and control
  URL:=https://github.com/YusDyr/luci-app-trafficctl
  DEPENDS:=+conntrack +kmod-nft-netdev +firewall4 +ucode +ucode-mod-fs +ucode-mod-uci +ucode-mod-ubus
  PKGARCH:=all
endef

define Package/trafficctl-shaper
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Traffic shaping (tc/HTB) for trafficctl
  URL:=https://github.com/YusDyr/luci-app-trafficctl
  DEPENDS:=+trafficctl +tc +kmod-sched-core +kmod-ifb
  EXTRA_DEPENDS:=trafficctl (=$(PKG_VERSION)-r$(PKG_RELEASE))
  PKGARCH:=all
endef

define Package/trafficctl-wifi
  SECTION:=net
  CATEGORY:=Network
  TITLE:=WiFi clients and WiFi blocking for trafficctl
  URL:=https://github.com/YusDyr/luci-app-trafficctl
  DEPENDS:=+trafficctl +iw +hostapd-utils
  EXTRA_DEPENDS:=trafficctl (=$(PKG_VERSION)-r$(PKG_RELEASE))
  PKGARCH:=all
endef

define Package/trafficctl-telegram
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Telegram bot for trafficctl
  URL:=https://github.com/YusDyr/luci-app-trafficctl
  DEPENDS:=+trafficctl +curl
  EXTRA_DEPENDS:=trafficctl (=$(PKG_VERSION)-r$(PKG_RELEASE))
  PKGARCH:=all
endef

define Package/trafficctl-full
  SECTION:=net
  CATEGORY:=Network
  TITLE:=trafficctl with every optional part
  URL:=https://github.com/YusDyr/luci-app-trafficctl
  DEPENDS:=+trafficctl +trafficctl-shaper +trafficctl-wifi +trafficctl-telegram
  EXTRA_DEPENDS:=trafficctl (=$(PKG_VERSION)-r$(PKG_RELEASE)), trafficctl-shaper (=$(PKG_VERSION)-r$(PKG_RELEASE)), trafficctl-wifi (=$(PKG_VERSION)-r$(PKG_RELEASE)), trafficctl-telegram (=$(PKG_VERSION)-r$(PKG_RELEASE))
  PKGARCH:=all
endef

define Package/trafficctl/description
  Per-device traffic monitoring (conntrack), rate limiting (nftables),
  internet blocking, a global internet cut, device notifications and a
  Prometheus exporter. Optional parts: trafficctl-shaper (traffic shaping
  with tc/HTB), trafficctl-wifi (WiFi clients and WiFi MAC filtering) and
  trafficctl-telegram (the Telegram bot), or trafficctl-full for all of
  them. The web interface is luci-app-trafficctl. The ntfy, webhook and
  Telegram senders need curl.
endef

define Package/trafficctl-shaper/description
  Traffic shaping for trafficctl: per-device tc/HTB queues on the LAN device
  (download) and an IFB device (upload). Pulls in tc, kmod-sched-core and
  kmod-ifb; holds no files of its own.
endef

define Package/trafficctl-wifi/description
  WiFi support for trafficctl: WiFi clients with band and signal, and WiFi
  MAC filtering through the radio's ACL. Pulls in iw and hostapd-utils;
  holds no files of its own.
endef

define Package/trafficctl-full/description
  trafficctl with every optional part: trafficctl-shaper, trafficctl-wifi
  and trafficctl-telegram. Holds no files of its own; install trafficctl
  and only the parts you need instead for a smaller install.
endef

define Package/trafficctl-telegram/description
  A Telegram bot for trafficctl: device status, and block, WiFi block,
  limit and shape buttons per device. Configured in /etc/config/trafficctl
  (section telegram) or from luci-app-trafficctl.
endef

# Only list files that ship in the package and may be user-edited.
# shapes.json / telegram_known.json are runtime state created by scripts; they
# survive sysupgrade via /lib/upgrade/keep.d/trafficctl instead.
define Package/trafficctl/conffiles
/etc/config/trafficctl
endef

define Build/Compile
endef

define Package/trafficctl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafficctl/files/usr/sbin/trafficctl $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/share/ucode/trafficctl
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/lib.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/net.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/report.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/ctl.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/notify.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/cut.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/portfw.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/history.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/limit.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/shape.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/trafficctl/files/etc/config/trafficctl $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafficctl/files/etc/init.d/trafficctl-cut $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafficctl/files/etc/init.d/trafficctl-history $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafficctl/files/etc/init.d/trafficctl-notify $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafficctl/files/etc/uci-defaults/80_trafficctl-notify $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/dhcp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/etc/hotplug.d/dhcp/99-trafficctl-newdevice $(1)/etc/hotplug.d/dhcp/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/etc/hotplug.d/iface/99-trafficctl-shapes $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/lib/upgrade/keep.d/trafficctl $(1)/lib/upgrade/keep.d/
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafficctl/files/www/cgi-bin/trafficctl-metrics $(1)/www/cgi-bin/
endef

# Services follow their uci flag, so the state after an install or an upgrade
# is the state after the next reboot. rc.d is never disabled here:
# default_postinst enables every init script on a fresh install, and each
# service checks its flag before it starts. Running services are restarted so
# that they pick up the upgraded scripts.
#
# Guarded on IPKG_INSTROOT: when it is set the package is being unpacked into
# an image being built, where there are no running services to talk to.
define Package/trafficctl/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /var/run/trafficctl/cut.state ] && [ -x /etc/init.d/trafficctl-cut ]; then
		/etc/init.d/trafficctl-cut restart 2>/dev/null || true
	fi
	# The watcher decides for itself whether anything wants the scan.
	if [ -x /etc/init.d/trafficctl-notify ]; then
		/etc/init.d/trafficctl-notify enable 2>/dev/null || true
		/etc/init.d/trafficctl-notify restart 2>/dev/null || true
	fi
	if [ -x /etc/init.d/trafficctl-history ]; then
		if [ "$$(uci -q get trafficctl.history.enabled)" = "1" ]; then
			/etc/init.d/trafficctl-history enable 2>/dev/null || true
		fi
		if /etc/init.d/trafficctl-history enabled; then
			/etc/init.d/trafficctl-history restart 2>/dev/null || true
		fi
	fi
	# Every saved block, limit, shape and port control is applied again by the
	# upgraded code, as the `ifup lan` hook does. TCTL_NOTIFY=0: nothing new is
	# applied, so no notification per device.
	if [ -x /usr/sbin/trafficctl ]; then
		TCTL_NOTIFY=0 /usr/sbin/trafficctl restore >/dev/null 2>&1 || true
	fi
	if [ -f /usr/share/rpcd/ucode/luci.trafficctl.uc ]; then
		/etc/init.d/rpcd reload 2>/dev/null || true
	fi
fi
exit 0
endef

# Fail open on removal. A global internet cut left engaged by a package that is
# going away is a lockout with no UI left to undo it: the drop rule would sit
# in nftables with nothing on the router admitting to owning it. The release
# needs ucode and every module to load, so its effect is then made sure of
# without them: no state for a keeper to re-assert from, and no table.
define Package/trafficctl/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/usr/sbin/trafficctl cut release >/dev/null 2>&1 || true
	rm -f /var/run/trafficctl/cut.state /etc/trafficctl/cut.state
	nft delete table inet tctl_cut 2>/dev/null || true
fi
exit 0
endef

# The flag rule is trafficctl's (above): the bot runs only when it is enabled.
define Package/trafficctl-telegram/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ] && [ -x /etc/init.d/trafficctl-telegram ] && [ "$$(uci -q get trafficctl.telegram.enabled)" = "1" ]; then
	/etc/init.d/trafficctl-telegram enable 2>/dev/null || true
	/etc/init.d/trafficctl-telegram restart 2>/dev/null || true
fi
exit 0
endef

define Package/trafficctl-telegram/install
	$(INSTALL_DIR) $(1)/usr/share/ucode/trafficctl
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/trafficctl/files/usr/share/ucode/trafficctl/telegram.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DIR) $(1)/usr/libexec/trafficctl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafficctl/files/usr/libexec/trafficctl/trafficctl-telegram.uc $(1)/usr/libexec/trafficctl/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafficctl/files/etc/init.d/trafficctl-telegram $(1)/etc/init.d/
endef

define Package/trafficctl-shaper/install
	true
endef

define Package/trafficctl-wifi/install
	true
endef

define Package/trafficctl-full/install
	true
endef

$(eval $(call BuildPackage,trafficctl))
$(eval $(call BuildPackage,trafficctl-shaper))
$(eval $(call BuildPackage,trafficctl-wifi))
$(eval $(call BuildPackage,trafficctl-telegram))
$(eval $(call BuildPackage,trafficctl-full))
