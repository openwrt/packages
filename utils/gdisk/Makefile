#
# Copyright (C) 2016 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gdisk
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

PKG_SOURCE:=gptfdisk-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/gptfdisk
PKG_MD5SUM:=d7f3d306b083123bcc6f5941efade586
PKG_SOURCE_SUBDIR:=gptfdisk-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/gdisk
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=disc
  DEPENDS:=+libstdcpp +popt +libuuid
  TITLE:=Partition utility that supports GPT
  URL:=http://www.rodsbooks.com/gdisk
  MAINTAINER:=Daniel Engberg <daniel.engberg.lists@pyret.net>
endef

define Package/gdisk/description
 Partition table manipulation utility with GPT support
endef

define Package/gdisk/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gdisk $(1)/sbin/
endef

$(eval $(call BuildPackage,gdisk))
