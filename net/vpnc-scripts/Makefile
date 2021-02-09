#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vpnc-scripts
PKG_SOURCE_DATE:=2021-02-07
PKG_SOURCE_VERSION:=32462c47750112c825c2524c2e98f6d17eadc87b
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.com/openconnect/vpnc-scripts
PKG_MIRROR_HASH:=4919fc94522d016213cc8a40047e50cfba825c3478e5fa7c340a6f67be9b082d

PKG_MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/vpnc-scripts
  SECTION:=net
  CATEGORY:=Network
  TITLE:=VPN configuration script for vpnc and OpenConnect
  SUBMENU:=VPN
  PKGARCH:=all
endef

define Package/vpnc-scripts/description
	This package contains the vpnc-script which is used by vpnc
	and OpenConnect to configure the tunnel interface.
endef

define Build/Compile
endef

define Package/vpnc-scripts/install
	$(INSTALL_DIR) $(1)/lib/netifd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/vpnc-script $(1)/lib/netifd/
endef

$(eval $(call BuildPackage,vpnc-scripts))
