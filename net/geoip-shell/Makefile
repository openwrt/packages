# Copyright 2024 friendly-bits, antonk (antonk.d3v@gmail.com)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=geoip-shell
PKG_VERSION:=0.5
PKG_RELEASE:=2
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=antonk <antonk.d3v@gmail.com>
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=3b56796aea49d7ae1e5ce3de1f5ccfafd36c7f3f
PKG_SOURCE_URL:=https://github.com/friendly-bits/geoip-shell-openwrt.git
PKG_MIRROR_HASH:=2a6cb1996fc7c48f146267e193fe1812addeb228adc5fe16a55341509d4a5353

include $(INCLUDE_DIR)/package.mk

define Package/geoip-shell/Default
	CATEGORY:=Network
	TITLE:=Flexible geoip blocker
	URL:=https://github.com/friendly-bits/geoip-shell
	MAINTAINER:=antonk <antonk.d3v@gmail.com>
	DEPENDS:=+ca-bundle
	PROVIDES:=geoip-shell
	PKGARCH:=all
endef

define Package/geoip-shell
$(call Package/geoip-shell/Default)
	TITLE+= with nftables support
	DEPENDS+= +kmod-nft-core +nftables +firewall4
	DEFAULT_VARIANT:=1
	VARIANT:=nftables
endef

define Package/geoip-shell-iptables
$(call Package/geoip-shell/Default)
	TITLE+= with iptables support
	DEPENDS+= +kmod-ipt-ipset +IPV6:ip6tables +iptables +ipset
	VARIANT:=iptables
	CONFLICTS:=geoip-shell firewall4
endef

define Package/geoip-shell/description/Default
	Flexible geoip blocker with a user-friendly command line interface (currently no LuCi interface).
	For readme, please see
	https://github.com/openwrt/packages/blob/master/net/geoip-shell/OpenWrt-README.md
endef

define Package/geoip-shell/description
$(call Package/geoip-shell/description/Default)
endef

define Package/geoip-shell-iptables/description
$(call Package/geoip-shell/description/Default)
endef

define Package/geoip-shell/postinst/Default
	#!/bin/sh
	rm "/usr/bin/geoip-shell" 2>/dev/null
	ln -s "/usr/bin/geoip-shell-manage.sh" "/usr/bin/geoip-shell"
	[ -s "/etc/geoip-shell/geoip-shell.conf" ] && /usr/bin/geoip-shell configure -z && exit 0
	logger -s -t "geoip-shell" "Please run 'geoip-shell configure' to complete the setup."
	exit 0
endef

define Package/geoip-shell/postinst
$(call Package/geoip-shell/postinst/Default)
endef

define Package/geoip-shell-iptables/postinst
$(call Package/geoip-shell/postinst/Default)
endef

define Package/geoip-shell/prerm/Default
	#!/bin/sh
	sh /usr/lib/geoip-shell/geoip-shell-owrt-uninstall.sh
	exit 0
endef

define Package/geoip-shell/prerm
$(call Package/geoip-shell/prerm/Default)
endef

define Package/geoip-shell-iptables/prerm
$(call Package/geoip-shell/prerm/Default)
endef

define Package/geoip-shell/postrm
	#!/bin/sh
	sleep 1
	echo "Reloading the firewall..."
	fw4 -q reload
	exit 0
endef

define Package/geoip-shell-iptables/postrm
	#!/bin/sh
	sleep 1
	echo "Reloading the firewall..."
	fw3 -q reload
	exit 0
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/geoip-shell/install/Default

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/etc/init.d/geoip-shell-init $(1)/etc/init.d

	$(INSTALL_DIR) $(1)/etc/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/etc/geoip-shell/cca2.list $(1)/etc/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/etc/geoip-shell/geoip-shell.const $(1)/etc/geoip-shell

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-fetch.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-fw-include.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-backup.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-geoinit.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-run.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-mk-fw-include.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-manage.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-apply.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-detect-lan.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/geoip-shell-cronsetup.sh $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-lib-status.sh $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-lib-owrt-common.sh $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-lib-common.sh $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-owrt-uninstall.sh $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-lib-arrays.sh $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-lib-setup.sh $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-lib-uninstall.sh $(1)/usr/lib/geoip-shell

endef


define Package/geoip-shell/install
$(call Package/geoip-shell/install/Default,$(1))
	$(INSTALL_DIR) $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-lib-nft.sh $(1)/usr/lib/geoip-shell

endef


define Package/geoip-shell-iptables/install
$(call Package/geoip-shell/install/Default,$(1))
	$(INSTALL_DIR) $(1)/usr/lib/geoip-shell
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/usr/lib/geoip-shell/geoip-shell-lib-ipt.sh $(1)/usr/lib/geoip-shell

endef

$(eval $(call BuildPackage,geoip-shell))
$(eval $(call BuildPackage,geoip-shell-iptables))


