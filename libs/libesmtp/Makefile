#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libesmtp
PKG_VERSION:=1.1.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>
PKG_LICENSE:=LGPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libesmtp/libESMTP/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=32bc3614ca12d21c7d933f32d43410e8744b6f91fdca7732da9877a385e4e6c3
PKG_BUILD_DIR:=$(BUILD_DIR)/libESMTP-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=meson/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/libesmtp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A Library for Posting Electronic Mail
  URL:=https://libesmtp.github.io/
  DEPENDS:=+libpthread +libopenssl
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libesmtp.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/esmtp-plugins-6.2.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/esmtp-plugins-6.2.0/sasl-crammd5.so $(1)/usr/lib/esmtp-plugins-6.2.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/esmtp-plugins-6.2.0/sasl-login.so $(1)/usr/lib/esmtp-plugins-6.2.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/esmtp-plugins-6.2.0/sasl-ntlm.so $(1)/usr/lib/esmtp-plugins-6.2.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/esmtp-plugins-6.2.0/sasl-plain.so $(1)/usr/lib/esmtp-plugins-6.2.0
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libesmtp-1.0.pc $(1)/usr/lib/pkgconfig
endef

define Package/libesmtp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libesmtp.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/esmtp-plugins-6.2.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/esmtp-plugins-6.2.0/sasl-crammd5.so $(1)/usr/lib/esmtp-plugins-6.2.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/esmtp-plugins-6.2.0/sasl-login.so $(1)/usr/lib/esmtp-plugins-6.2.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/esmtp-plugins-6.2.0/sasl-ntlm.so $(1)/usr/lib/esmtp-plugins-6.2.0
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/esmtp-plugins-6.2.0/sasl-plain.so $(1)/usr/lib/esmtp-plugins-6.2.0
endef

$(eval $(call BuildPackage,libesmtp))
