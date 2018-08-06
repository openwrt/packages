#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lispmob
PKG_VERSION:=0.5.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/LISPmob/lispmob/tar.gz/$(PKG_VERSION)?
PKG_HASH:=aa51574fac4f70848541eb400a1347aec7b7b6f447b4a08add7b257a1441d4aa

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
  URL:=https://github.com/LISPmob/lispmob
  DEPENDS:= +librt +libopenssl +confuse +kmod-tun +uci @IPV6
  $(call Package/lispd/default)
endef

define Package/lispd/description
  This packet provides support for the Locator-ID Separation Protocol.
endef

TARGET_CFLAGS += -DBSD #compile fix

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
