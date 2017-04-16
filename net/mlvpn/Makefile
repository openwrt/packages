#
# Copyright (C) 2017 Zhong Jianxin <azuwis@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=mlvpn
PKG_VERSION:=2.3.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/zehome/MLVPN.git
PKG_SOURCE_VERSION:=6f13423b8108f46edb9f230deee20e3741abe64c
PKG_MIRROR_HASH:=e77916143162ffa050bc07482264f726b0c03a8fa9e07bb594a3759f512830cd

PKG_MAINTAINER:=Zhong Jianxin <azuwis@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENCE

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/mlvpn
  TITLE:=Multi-Link Virtual Public Network
  SECTION:=net
  CATEGORY:=Network
  URL:=https://zehome.github.io/MLVPN/
  SUBMENU:=VPN
  MENU:=1
  DEPENDS:=+kmod-tun +libev +libpcap +libsodium
endef

define Package/mlvpn/description
  Multi-Link Virtual Public Network
  Bond your internet links to increase bandwidth (unlimited).
  Secure your internet connection by actively monitoring your links and removing the faulty ones, without loosing your TCP connections.
  Secure your internet connection to the aggregation server using strong cryptography.
  Scriptable automation and monitoring.
endef

define Package/mlvpn/conffiles
/etc/mlvpn/
endef

define Package/mlvpn/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/etc/init.d \
		$(1)/etc/mlvpn \

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mlvpn $(1)/usr/sbin/
	install -m0700 files/mlvpn-updown $(1)/usr/sbin/
	$(INSTALL_BIN) files/mlvpn.init $(1)/etc/init.d/mlvpn
endef

$(eval $(call BuildPackage,mlvpn))
