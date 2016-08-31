#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=haveged
PKG_VERSION:=1.9.1
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.issihosts.com/$(PKG_NAME) \
	http://pkgs.fedoraproject.org/repo/pkgs/haveged/haveged-1.9.1.tar.gz/015ff58cd10607db0e0de60aeca2f5f8/
PKG_MD5SUM:=015ff58cd10607db0e0de60aeca2f5f8
PKG_LICENSE:=GPLv3

PKG_MAINTAINER:=Hannu Nyman <hannu.nyman@iki.fi>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/haveged/template
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Feeds the kernel entropy pool by timing CPU loops.
  URL:=http://www.issihosts.com/haveged/
endef

define Package/haveged
  $(call Package/haveged/template)
  DEPENDS:=+libhavege
endef

define Package/libhavege
  $(call Package/haveged/template)
  TITLE:=Library for haveged
endef

CONFIGURE_ARGS+= \
      --enable-daemon=yes \
      --enable-threads=no \
      --enable-olt=no

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/src/havege.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libhavege.{a,so*} $(1)/usr/lib/
endef

define Package/haveged/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/haveged.init $(1)/etc/init.d/haveged
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/.libs/haveged $(1)/usr/sbin/
endef

define Package/libhavege/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libhavege.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,haveged))
$(eval $(call BuildPackage,libhavege))
