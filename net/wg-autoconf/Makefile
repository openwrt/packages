# SPDX-License-Identifier: MIT
#
# WireGuard Auto-Configuration tool for OpenWrt v1.0.0-r6
# Maintainer: Alexander Gomez <alexandrgomez@proton.me>
# Repository: https://github.com/alexandrglm/openwrt_wg-autoconf
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wg-autoconf
PKG_VERSION:=1.0.0
PKG_RELEASE:=6
PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION)-r$(PKG_RELEASE)-source.tar.gz
PKG_SOURCE_URL:=https://github.com/alexandrglm/openwrt_wg-autoconf/releases/download/1.0.0-r6/
PKG_HASH:=650d9e219979c3a0768352fdee92260cb129bad43b0594a659c1b2867e7cd174
PKG_MAINTAINER:=Alexander Gomez <alexandrgomez@proton.me>
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/bin/wg-autoconf.clean \
		$(1)/usr/bin/wg-autoconf

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/etc/init.d/wg-autoconf_boot_cleanup.source \
		$(1)/etc/init.d/wg-autoconf_boot_cleanup

	$(INSTALL_DIR) $(1)/usr/libexec/wg-autoconf/scripts
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/libexec/wg-autoconf/lifecyle/wg-autoconf_prerm.source \
		$(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_prerm.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/libexec/wg-autoconf/lifecyle/wg-autoconf_preinst.source \
		$(1)/usr/libexec/wg-autoconf/scripts/wg-autoconf_preinst.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/usr/libexec/wg-autoconf/lifecyle/wg-autoconf_postinst.source \
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
/usr/libexec/wg-autoconf/scripts/wg-autoconf_prerm.sh
exit 0
endef

$(eval $(call BuildPackage,wg-autoconf))
