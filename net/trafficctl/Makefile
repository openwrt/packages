# SPDX-License-Identifier: Apache-2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=trafficctl
PKG_VERSION:=2.1.2
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=
PKG_MAINTAINER:=Denis Iusupov <yusdyr@gmail.com>

include $(INCLUDE_DIR)/package.mk

# hostapd-utils is deliberately not a dependency: it can only be selected
# together with a hostapd/wpad variant, so depending on it would make this
# package unselectable on wired-only builds. The WiFi block helpers check for
# hostapd_cli at run time and fall back to a timed ubus ban
# (block_iface in ctl.uc; trafficctl device reports it as wifi_filter).
# iw stays: it is selectable on every target and only reads station lists.
# firewall4: blocks are rules in its inet fw4 table, so nftables alone is not
# enough.
# kmod-nft-netdev carries CONFIG_NF_TABLES_NETDEV, the nft family of the
# limiter's table (netdev tm_ratelimit); firewall4 does not pull it in.
define Package/trafficctl
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Per-device traffic monitoring and control
  URL:=https://github.com/YusDyr/luci-app-trafficctl
  DEPENDS:=+conntrack +curl +tc +iw +kmod-nft-netdev +firewall4 +ucode +ucode-mod-fs +ucode-mod-uci +ucode-mod-ubus
  PKGARCH:=all
endef

define Package/trafficctl-telegram
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Telegram bot for trafficctl
  URL:=https://github.com/YusDyr/luci-app-trafficctl
  DEPENDS:=+trafficctl +curl
  # Versioned, so the opkg/apk solver never pairs this bot with a trafficctl
  # older than its own release (1.30.x has no trafficctl.uc for it to call).
  EXTRA_DEPENDS:=trafficctl (>=$(PKG_VERSION))
  PKGARCH:=all
endef

define Package/trafficctl/description
  Per-device traffic monitoring (conntrack), rate limiting (nftables),
  traffic shaping (tc/HTB), internet blocking, WiFi MAC filtering, a global
  internet cut, device notifications and a Prometheus exporter. The web
  interface is luci-app-trafficctl, the Telegram bot trafficctl-telegram.
  WiFi MAC filtering needs hostapd-utils, which is optional so the package can
  be installed on wired-only builds. Without it a WiFi block is a temporary
  (one hour) hostapd ban over ubus.
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
	$(INSTALL_BIN) ./files/usr/sbin/trafficctl $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/share/ucode/trafficctl
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/lib.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/net.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/report.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/ctl.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/notify.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/cut.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/portfw.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/history.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/limit.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/shape.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/trafficctl $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/trafficctl-cut $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/trafficctl-history $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/trafficctl-notify $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/80_trafficctl-notify $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/dhcp
	$(INSTALL_DATA) ./files/etc/hotplug.d/dhcp/99-trafficctl-newdevice $(1)/etc/hotplug.d/dhcp/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/99-trafficctl-shapes $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/lib/upgrade/keep.d/trafficctl $(1)/lib/upgrade/keep.d/
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) ./files/www/cgi-bin/trafficctl-metrics $(1)/www/cgi-bin/
endef

# The config holds the Telegram bot token and the metrics token, so it must not
# be world-readable.
#
# Services follow their uci flag, so the state after an install or an upgrade
# is the state after the next reboot. rc.d is never disabled here:
# default_postinst enables every init script on a fresh install, and each
# service checks its flag before it starts. A running history sampler is
# restarted so that it picks up the upgraded scripts.
#
# Guarded on IPKG_INSTROOT: when it is set the package is being unpacked into
# an image being built, where there are no running services to talk to.
define Package/trafficctl/postinst
#!/bin/sh
chmod 0600 "$${IPKG_INSTROOT}/etc/config/trafficctl" 2>/dev/null || true
if [ -z "$${IPKG_INSTROOT}" ]; then
	nft delete table inet trafficctl_mon 2>/dev/null || true
	# Releases up to 1.30.1 gave the cut keeper START=95, so rc.d may
	# still link it for boot. It is started on demand only.
	rm -f /etc/rc.d/S95trafficctl-cut /etc/rc.d/K10trafficctl-cut
	if [ -f /var/run/trafficctl/cut.state ] && [ -x /etc/init.d/trafficctl-cut ]; then
		/etc/init.d/trafficctl-cut restart 2>/dev/null || true
	fi
	# A luci-app-trafficctl up to 1.30.x depends on any trafficctl, so this
	# package can be upgraded on its own. That web interface has no ucode
	# plugin in /usr/share/rpcd/ucode, and its exec plugin sources
	# trafficctl-fw.sh, which 2.0.0 removed, so every page fails.
	if [ ! -e /usr/share/rpcd/ucode/luci.trafficctl.uc ] &&
	   grep -q 'trafficctl-fw.sh' /usr/libexec/rpcd/luci.trafficctl 2>/dev/null; then
		_m="The installed luci-app-trafficctl predates trafficctl 2.0.0 and does not work with it: upgrade luci-app-trafficctl too (opkg upgrade luci-app-trafficctl, or apk upgrade luci-app-trafficctl) unless this run already does"
		echo "$$_m"
		logger -t trafficctl "$$_m" 2>/dev/null || true
	fi
	# The Telegram options of releases up to 1.30.x move to the notification
	# senders (once: only while the 'notify' section is missing).
	if [ -x /usr/sbin/trafficctl ]; then
		/usr/sbin/trafficctl notify migrate >/dev/null 2>&1 || true
	fi
	# A bot of a release up to 1.30.x lost its files to trafficctl-telegram
	# with this upgrade. Without that package it would run on until the next
	# reboot (and scan for devices, which the watcher took over), and rc.d
	# would keep links to a missing init script.
	if [ ! -e /etc/init.d/trafficctl-telegram ]; then
		ubus call service delete '{"name":"trafficctl-telegram"}' >/dev/null 2>&1 || true
		rm -f /etc/rc.d/S99trafficctl-telegram /etc/rc.d/K10trafficctl-telegram
		# Headless (no luci-app-trafficctl to pull it in): say so where
		# the operator will look.
		if [ "$$(uci -q get trafficctl.telegram.enabled)" = "1" ]; then
			logger -t trafficctl "The Telegram bot is stopped: it is the package trafficctl-telegram now; install it (opkg install trafficctl-telegram, or apk add trafficctl-telegram) to run it again" 2>/dev/null || true
		fi
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
	# Every saved block, limit, shape and port control goes back in force, as
	# the `ifup lan` hook does. Up to 1.30.x each shape added removed the u32
	# filters of the others, so only the last one was in force, and an upgrade
	# from there left the rest unshaped until the next reboot. TCTL_NOTIFY=0:
	# nothing new is applied, so no notification per device.
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

# Restarted, not started: a bot of a release up to 1.30.x runs the device
# scan itself, which the notification watcher took over. The flag rule is
# trafficctl's (above). trafficctl's postinst has run by now: the package
# manager configures a dependency first, so the Telegram options of 1.30.x
# have already moved to the notification senders.
define Package/trafficctl-telegram/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ] && [ -x /etc/init.d/trafficctl-telegram ] && [ "$$(uci -q get trafficctl.telegram.enabled)" = "1" ]; then
	/etc/init.d/trafficctl-telegram enable 2>/dev/null || true
	/etc/init.d/trafficctl-telegram restart 2>/dev/null || true
fi
exit 0
endef

define Package/trafficctl-telegram/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ] && [ -x /etc/init.d/trafficctl-telegram ]; then
	/etc/init.d/trafficctl-telegram stop 2>/dev/null || true
	/etc/init.d/trafficctl-telegram disable 2>/dev/null || true
fi
exit 0
endef

define Package/trafficctl-telegram/install
	$(INSTALL_DIR) $(1)/usr/share/ucode/trafficctl
	$(INSTALL_DATA) ./files/usr/share/ucode/trafficctl/telegram.uc $(1)/usr/share/ucode/trafficctl/
	$(INSTALL_DIR) $(1)/usr/libexec/trafficctl
	$(INSTALL_BIN) ./files/usr/libexec/trafficctl/trafficctl-telegram.uc $(1)/usr/libexec/trafficctl/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/trafficctl-telegram $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,trafficctl))
$(eval $(call BuildPackage,trafficctl-telegram))
