#
# Copyright (C) 2007-2018 OpenWrt.org
# Copyright (C) 2018 Rosy Song <rosysong@rosinson.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eject
PKG_VERSION:=2.1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION)+deb1+cvs20081104.orig.tar.gz
PKG_SOURCE_URL:=http://http.debian.net/debian/pool/main/e/eject
PKG_HASH:=f5c457b92d7bfc20924ebdc8515661222b40e036eae6e2fada4220d47884e9c1
PKG_MAINTAINER:=Rosy Song <rosysong@rosinson.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)+deb1+cvs20081104
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/eject
  SUBMENU:=Disc
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Eject utility
  DEPENDS:=+sg3_utils
  URL:=http://man7.org/linux/man-pages/man1/eject.1.html
endef

define Package/eject/description
	This little program will eject CD-ROMs (assuming your drive supports the
	CDROMEJECT ioctl). It also allows setting the autoeject feature. On
	supported ATAPI/IDE multi-disc CD-ROM changers, it allows changing the
	active disc. You can also use eject to properly disconnect external 
	mass-storage devices like digital cameras or portable music players.
endef

define Package/eject/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,eject))
