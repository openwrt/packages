include $(TOPDIR)/rules.mk

PKG_NAME:=fwblack
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_SOURCE:=fw-black-luci-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/EdgeBites/fw-black-luci/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2b011a8203de2ea10c955fbd817c5e3b9b222bbe8c04b3f5da211e036886abcd

PKG_MAINTAINER:=Calin Vlad <calin@edgebites.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/fwblack
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall
  TITLE:=DNS-based nftables blocklist daemon
  URL:=https://github.com/EdgeBites/fw-black-luci
  DEPENDS:=+nftables +firewall4
  PKGARCH:=all
endef

define Package/fwblack/description
  Blocks unwanted domains/trackers at the router by watching active
  connections, reverse-resolving them, and dropping TCP 80/443 toward
  matches. nftables set-based, dual-stack, procd-managed, UCI-configured.
endef

define Package/fwblack/conffiles
/etc/config/fwblack
/etc/fwblack/blocklist.cfg
endef

define Package/fwblack/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/sbin/fw-black $(1)/usr/sbin/fw-black

	$(INSTALL_DIR) $(1)/usr/libexec/fwblack
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/libexec/fwblack/ips.sh $(1)/usr/libexec/fwblack/ips.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/libexec/fwblack/resips.sh $(1)/usr/libexec/fwblack/resips.sh

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/fwblack $(1)/etc/init.d/fwblack

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/etc/config/fwblack $(1)/etc/config/fwblack

	$(INSTALL_DIR) $(1)/etc/fwblack
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/etc/fwblack/blocklist.cfg $(1)/etc/fwblack/blocklist.cfg

	$(INSTALL_DIR) $(1)/usr/share/nftables.d/ruleset-post
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/usr/share/nftables.d/ruleset-post/fwblack.nft $(1)/usr/share/nftables.d/ruleset-post/fwblack.nft

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/uci-defaults/99-fwblack $(1)/etc/uci-defaults/99-fwblack

	$(INSTALL_DIR) $(1)/etc/sysupgrade.conf.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/etc/sysupgrade.conf.d/fwblack $(1)/etc/sysupgrade.conf.d/fwblack
endef

define Package/fwblack/postinst
#!/bin/sh
# Migrate legacy /etc/fw.black layout on first install/upgrade.
# (Keep in sync with files/etc/uci-defaults/99-fwblack.)
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/fw.black/blocklist.cfg ] && [ ! -e /etc/fwblack/.migrated ]; then
		mkdir -p /etc/fwblack
		if [ ! -f /etc/fwblack/blocklist.cfg ]; then
			cp /etc/fw.black/blocklist.cfg /etc/fwblack/blocklist.cfg
		elif ! cmp -s /etc/fw.black/blocklist.cfg /etc/fwblack/blocklist.cfg 2>/dev/null; then
			cp /etc/fwblack/blocklist.cfg /etc/fwblack/blocklist.cfg.ppkg-default
			cp /etc/fw.black/blocklist.cfg /etc/fwblack/blocklist.cfg
		fi
		touch /etc/fwblack/.migrated
	fi
	# Remove legacy fw4 include if it shadows the packaged one.
	if [ -f /etc/nftables.d/ruleset-post/fwblack.nft ]; then
		rm -f /etc/nftables.d/ruleset-post/fwblack.nft
	fi
	/etc/init.d/fwblack enable 2>/dev/null || true
fi
exit 0
endef

define Package/fwblack/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/fwblack stop 2>/dev/null || true
	/etc/init.d/fwblack disable 2>/dev/null || true
	nft delete table inet fwblack 2>/dev/null || true
fi
exit 0
endef

$(eval $(call BuildPackage,fwblack))
