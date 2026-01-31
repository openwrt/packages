# SPDX-License-Identifier: MIT
#
# WireGuard Auto-Configuration tool for OpenWrt v1.0.0-rel5
# Maintainer: Alexander Gomez <alexandrgomez@proton.me>
# Repository: https://github.com/alexandrglm/openwrt_wg-autoconf
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wg-autoconf
PKG_VERSION:=1.0.0
PKG_RELEASE:=5
PKG_SOURCE:=wg-autoconf_$(PKG_VERSION)-rel$(PKG_RELEASE)-source.tar.gz
PKG_SOURCE_URL:=https://github.com/alexandrglm/openwrt_wg-autoconf/releases/tag/1.0.0-r5
PKG_HASH:=bd0a2af4ba71cae32aa7ecfbb0b1e4384e1c36e3cd584ff88a4043eb9fcf68f6
PKG_MAINTAINER:=Alexander Gomez <alexandrgomez@proton.me>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/wg-autoconf
	SECTION:=net
	CATEGORY:=Network
	TITLE:=WireGuard Auto-Configuration tool for OpenWrt
	URL:=https://github.com/alexandrglm/openwrt_wg-autoconf
	DEPENDS:=+wireguard-tools
	PKGARCH:=all
endef

define Package/wg-autoconf/description
	WireGuard Auto-Configuration tool for OpenWrt.
	Automates multiple WG VPN interface setup, batch configuration,
	policy-based routing, and cleanup operations.
	Easy and safe WG tunneling manager.
	Documentation: https://github.com/alexandrglm/openwrt_wg-autoconf/README.md
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	[ -d "$(PKG_BUILD_DIR)/wg-autoconf_1.0.0-rel4-source/source" ] && \
		cp -r $(PKG_BUILD_DIR)/wg-autoconf_1.0.0-rel4-source/source/* $(PKG_BUILD_DIR)/ || true
endef

define Build/Compile
endef

define Package/wg-autoconf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wg-autoconf.clean \
		$(1)/usr/bin/wg-autoconf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wg-autoconf_boot_cleanup.source \
		$(1)/etc/init.d/wg-autoconf_boot_cleanup
	$(INSTALL_DIR) $(1)/usr/libexec/wg-autoconf/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wg-autoconf_prerm.source \
		$(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_prerm.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wg-autoconf_preinst.source \
		$(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_preinst.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wg_autoconf_postinst.source \
		$(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_postinst.sh
endef


define Package/wg-autoconf/preinst
#!/bin/sh
/usr/libexec/wg-autoconf/scripts/wg-autoconf_preinst.sh
exit 0
endef

define Package/wg-autoconf/postinst
#!/bin/sh
/usr/libexec/wg-autoconf/scripts/wg-autoconf_postinst.sh
exit 0
endef

define Package/wg-autoconf/prerm
#!/bin/sh
/usr/libexec/wg-autoconf/scripts/wg-autoconf_postinst.sh
exit 0
endef


$(eval $(call BuildPackage,wg-autoconf))
