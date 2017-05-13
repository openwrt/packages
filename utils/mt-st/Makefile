#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mt-st
PKG_VERSION:=1.1
PKG_RELEASE:=1

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.ibiblio.org/pub/Linux/system/backup/
PKG_MD5SUM:=fdd5f5ec673c9f630a102ceff7612774

PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/mt-st
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Magnetic tape control tools for Linux SCSI tapes
  URL:=http://ftp.ibiblio.org/pub/Linux/system/backup/
  MAINTAINER:=Giuseppe Magnotta <giuseppe.magnotta@gmail.com>
endef

define Package/mt-st/description
	Includes a mt-like program supporting additional commands using ioctls
	specific to  the Linux SCSI tape driver (up to kernel 2.6.26), and the program
	stinit to define the SCSI tape devices in system startup scripts.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		CC="$(TARGET_CC)"
endef

define Package/mt-st/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mt $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/stinit $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mt-st))
