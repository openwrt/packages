#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shine
PKG_VERSION:=3.1.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/toots/shine/releases/download/$(PKG_VERSION)/
PKG_HASH:=6c5310bda766b116ed2415d639a27e5e11040e068b4b2db6bd733333e620cb4f

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
  URL:=https://github.com/toots/shine
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
