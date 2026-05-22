# SPDX-License-Identifier: MIT
include $(TOPDIR)/rules.mk

PKG_NAME:=wg-autoconf
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/alexandrglm/openwrt_wg-autoconf/releases/download/$(PKG_VERSION)/
PKG_HASH:=7d71570784ca0d935325b401636f36d86319f3ddcb0f568364e5dfb7e688dfcb

PKG_MAINTAINER:=Alexander Gomez <alexandrglm@proton.me>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/wg-autoconf
	SECTION:=net
	CATEGORY:=Network
	TITLE:=WireGuard Auto-Configuration tool
	URL:=https://github.com/alexandrglm/openwrt_wg-autoconf
	DEPENDS:=+wireguard-tools
	PKGARCH:=all
endef

define Package/wg-autoconf/description
	CLI tool for handling (multiple) WireGuard setups, with
	batch configs, policy-based routing, and cleanup operations.
	Easy and safe WireGuard-VPN tunneling manager for OpenWrt.
	DOC: https://github.com/alexandrglm/openwrt_wg-autoconf
endef

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
endef

define Package/wg-autoconf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/bin/wg-autoconf.clean $(1)/usr/bin/wg-autoconf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/etc/init.d/wg-autoconf_boot_cleanup.clean $(1)/etc/init.d/wg-autoconf_boot_cleanup
	$(INSTALL_DIR) $(1)/usr/libexec/wg-autoconf/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/libexec/wg-autoconf/lifecyle/wg-autoconf_prerm.clean $(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_prerm.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/libexec/wg-autoconf/lifecyle/wg-autoconf_preinst.clean $(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_preinst.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/libexec/wg-autoconf/lifecyle/wg-autoconf_postinst.clean $(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_postinst.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/libexec/wg-autoconf/lifecyle/wg-autoconf_postupgrade.clean $(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_postupgrade.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/libexec/wg-autoconf/states.clean $(1)/usr/libexec/wg-autoconf/states
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
/usr/libexec/wg-autoconf/scripts/wg-autoconf_prerm.sh
exit 0
endef

$(eval $(call BuildPackage,wg-autoconf))
