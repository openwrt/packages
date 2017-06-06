#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=efibootmgr
PKG_VERSION:=14
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/rhinstaller/efibootmgr/releases/download/$(PKG_VERSION)/ \
	http://mirror.opencompute.org/onie/
PKG_HASH:=377ec16484414b80afd1b8a586153d7ef55ccf048638080101d49b7c77f37ad8

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Curt Brune <curt@cumulusnetworks.com>
PKG_LICENSE:=GPLv2+

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/efibootmgr
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+efivar +gettext
  TITLE:=Tool to manipulate EFI Boot Manager
  URL:=https://github.com/rhinstaller/efibootmgr
endef

CONFIGURE_ARGS +=
TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/efivar
TARGET_LDFLAGS +=
CONFIGURE_VARS +=
MAKE_FLAGS +=

define Package/efibootmgr/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/efibootmgr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,efibootmgr))
