#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=slide-switch
PKG_VERSION:=0.9.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jefferyto/openwrt-slide-switch.git
PKG_SOURCE_VERSION:=9171c2ea9cc9cbfb6f27b7bc25a535c8c35ee534
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/slide-switch
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+jshn +jsonfilter
	TITLE:=Translate switch position changes into normal button presses
	URL:=https://github.com/jefferyto/openwrt-slide-switch
endef

define Package/slide-switch/description
slide-switch translates slide switch position changes into normal button
presses and releases for OpenWrt / LEDE devices.
endef

CONFIGURE_ARGS += --with-platform=$(BOARD)

define Package/slide-switch/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/button
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/hotplug.d/button/50-slide-switch $(1)/etc/hotplug.d/button
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/etc/init.d/zzz-slide-switch $(1)/etc/init.d
	if [ -d $(PKG_INSTALL_DIR)/usr/lib/slide-switch ]; then \
		$(INSTALL_DIR) $(1)/usr/lib/slide-switch; \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/slide-switch/* $(1)/usr/lib/slide-switch; \
	fi
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/sbin/slide-switch $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/share/slide-switch
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/slide-switch/functions.sh $(1)/usr/share/slide-switch
endef

$(eval $(call BuildPackage,slide-switch))
