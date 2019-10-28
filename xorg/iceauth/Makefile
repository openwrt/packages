# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=iceauth
PKG_VERSION:=1.0.8
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://xorg.freedesktop.org/releases/individual/app/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=e6ee213a217265cc76050e4293ea70b98c32dce6505c6421227efbda62ab60c6

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/iceauth
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libice +libx11
  TITLE:=the ICE authority file utility
  URL:=http://xorg.freedesktop.org/
endef

define Package/iceauth/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
endef

$(eval $(call BuildPackage,iceauth))

