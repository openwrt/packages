#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lispmob
PKG_REV:=180aa39d338a00bb532e421de7f8513492cf2e8b
PKG_VERSION:=0.4
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_MIRROR_HASH:=584300e1a59cc976f3599213487ea8425f94300887a51c9804f0292cf2f0c8cc
PKG_SOURCE_URL:=git://github.com/LISPmob/lispmob.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/lispd/default
  MAINTAINER:=Vasileios Lakafosis <lakafv@gmail.com>
  URL:=http://lisp.cisco.com/
endef

define Package/lispd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Locator/ID separation protocol (using TUN)
  URL:=https://github.com/LISPmob
  DEPENDS:= +librt +libopenssl +confuse +kmod-tun +uci @IPV6
  $(call Package/lispd/default)
endef

define Package/lispd/description
  This packet provides support for the Locator-ID Separation Protocol.
endef

MAKE_FLAGS += \
	platform=openwrt

define Package/lispd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lispd/lispd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/openWRT/lispd.uci.example $(1)/etc/config/lispd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openWRT/openwrt.init.script $(1)/etc/init.d/lisp
endef

$(eval $(call BuildPackage,lispd))
