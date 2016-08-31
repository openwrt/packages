#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shine
PKG_VERSION:=3.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/savonet/shine/releases/download/$(PKG_VERSION)/
PKG_MD5SUM:=fcad8108335f4b051b303fbdf3fca3fe

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/shine
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Super fast fixed-point MP3 encoder
  URL:=https://github.com/savonet/shine
endef

define Package/shine/description
 savonet/shine is a blazing fast mp3 encoding library implemented in fixed-point
 arithmetic. The library can thus be used to perform super fast mp3 encoding on
 architectures without a FPU, such as armel, etc.. It is also, however, also
 super fast on architectures with a FPU!
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/shine \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libshine.{a,so*} \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/shine.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/shine/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/shineenc $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libshine.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,shine))
