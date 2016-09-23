#
# Copyright (C) 2009-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mdk3
PKG_VERSION:=v6
PKG_RELEASE:=2
PKG_MD5SUM:=67705a814ded2a2e6f70522ca0dc6da9

PKG_BUILD_DIR:=$(BUILD_DIR)/mdk3-$(PKG_VERSION)
PKG_SOURCE_URL:=http://mirror2.openwrt.org/sources/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/mdk3
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread
  TITLE:= MDK3
  URL:=http://mirror2.openwrt.org/sources/
  SUBMENU:=wireless
endef

define Package/mdk3/description
  Tool to exploit wireless vulnerabilities
endef

MAKE_FLAGS += \
	$(TARGET_CONFIGURE_OPTS)

define Package/mdk3/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/mdk3 $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,mdk3))
