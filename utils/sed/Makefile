#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sed
PKG_VERSION:=4.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_HASH:=7aad73c8839c2bdadca9476f884d2953cdace9567ecd0d90f9959f229d146b40
PKG_MAINTAINER:=Yufei Miao <myf@myf.cloud>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/sed
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libacl
  TITLE:=GNU sed
  URL:=http://www.gnu.org/software/sed/
endef

define Package/sed/description
  GNU sed full version.
  sed (stream editor) is a non-interactive command-line text editor.
endef

define Package/sed/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sed $(1)/bin/
endef

$(eval $(call BuildPackage,sed))
