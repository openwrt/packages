# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xset
PKG_VERSION:=1.2.4
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://xorg.freedesktop.org/releases/individual/app/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=e4fd95280df52a88e9b0abc1fee11dcf0f34fc24041b9f45a247e52df941c957

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xset
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxext +libxmu libxxf86misc
  TITLE:=is the user preference utility for X
  URL:=http://xorg.freedesktop.org/
endef

define Package/xset/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
endef

$(eval $(call BuildPackage,xset))

