#
# Copyright (C) 2011 OpenWrt.org, bmx6.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=bmx6


PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://git.bmx6.net/bmx6.git
PKG_REV:=c3ef7d76292a765c5e578bd4113030dc34ee3b9a

PKG_VERSION:=r2011031602

#PKG_RELEASE:=1
#PKG_INSTALL:=1  # this tries to install straight to /usr/sbin/bmx6

PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk


TARGET_CFLAGS += $(FPIC)

#-DNO_TRAFFIC_DUMP -DNO_DYN_PLUGIN -DNO_DEBUG_DUMP -DNO_DEBUG_ALL -DNO_DEBUG_TRACK -DNO_DEBUG_SYS

MAKE_ARGS += \
	EXTRA_CFLAGS="$(TARGET_CFLAGS) -I. -I$(STAGING_DIR)/usr/include -DNO_DEBUG_ALL -DNO_DEBUG_DUMP" \
	EXTRA_LDFLAGS="-L$(STAGING_DIR)/usr/lib " \
	REVISION_VERSION="$(PKG_REV)" \
	CC="$(TARGET_CC)" \
	INSTALL_DIR="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/true" \
	build_all


define Package/bmx6/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=BMX6 layer 3 routing daemon
  URL:=http://bmx6.net/
  MAINTAINER:=Axel Neumann <neumann@cgws.de>
endef

define Package/bmx6/description
BMX6 layer 3 routing daemon supporting IPv4, IPv6, and IPv4 over IPv6 -  http://www.bmx6.net
endef

define Package/bmx6
  $(call Package/bmx6/Default)
  MENU:=1
endef

define Package/bmx6-uci-config
  $(call Package/bmx6/Default)
  DEPENDS:=bmx6 +libuci
  TITLE:=configuration plugin based on uci (recommended!)
endef




define Build/Configure
	mkdir -p $(PKG_INSTALL_DIR)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_ARGS)
endef


define Package/bmx6/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bmx6 $(1)/usr/sbin/bmx6
endef


define Package/bmx6-uci-config/conffiles
/etc/config/bmx6
endef


define Package/bmx6-uci-config/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmx6_uci_config/bmx6_config.so $(1)/usr/lib/bmx6_config.so
	$(INSTALL_BIN) ./files/etc/init.d/bmx6 $(1)/etc/init.d/bmx6
	$(INSTALL_DATA) ./files/etc/config/bmx6 $(1)/etc/config/bmx6
endef


$(eval $(call BuildPackage,bmx6))
$(eval $(call BuildPackage,bmx6-uci-config))

