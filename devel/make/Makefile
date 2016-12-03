#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=make
PKG_VERSION:=4.2.1
PKG_RELEASE:=2

PKG_SOURCE_URL:=@GNU/make
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_MD5SUM:=15b012617e7c44c0ed482721629577ac
PKG_MAINTAINER:=Heinrich Schuchardt <xypron.glpk@gmx.de>
PKG_LICENSE:=GPL-3.0+

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/make
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=make
  URL:=https://www.gnu.org/software/make/
endef

define Package/make/description
  The Make package contains a tool to create executables from source files.
endef

define Package/make/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/make $(1)/usr/bin/
endef

# provide gnumake.h at build time for other packages
define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/gnumake.h $(1)/usr/include/
endef

$(eval $(call BuildPackage,make))
