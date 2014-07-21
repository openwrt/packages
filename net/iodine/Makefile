#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iodine
PKG_VERSION:=0.6.0-rc1
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://code.kryo.se/iodine/
PKG_MD5SUM:=a15bb4faba020d217016fde6e231074a

include $(INCLUDE_DIR)/package.mk

define Package/iodine/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall Tunnel
  DEPENDS:= +kmod-tun +zlib
  TITLE:=IP over DNS tunneling
  URL:=http://code.kryo.se/iodine/
endef

define Package/iodine
  $(call Package/iodine/Default)
  TITLE+= client version
endef

define Package/iodine/description
 iodine client version
endef

define Package/iodined
  $(call Package/iodine/Default)
  TITLE+= server version
endef

define Package/iodined/description
 iodine server version
endef

define Build/Configure
endef

define Package/iodine/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/iodine $(1)/usr/sbin
endef

define Package/iodined/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/iodined.init $(1)/etc/init.d/iodined
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/iodined.config $(1)/etc/config/iodined
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/iodined $(1)/usr/sbin
endef

define Package/iodined/conffiles
/etc/config/iodined
endef

$(eval $(call BuildPackage,iodine))
$(eval $(call BuildPackage,iodined))
