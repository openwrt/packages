#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hdparm
PKG_VERSION:=9.50
PKG_RELEASE:=1
PKG_USE_MIPS16:=0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_MD5SUM:=d380062ad6c4b40076736efbb640f1f5
PKG_MAINTAINER:=Richard Kunze <richard.kunze@web.de>
PKG_LICENSE:=BSD-Style Open Source License

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS+=-D_GNU_SOURCE

define Package/hdparm
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Disc
  TITLE:=Hard disk drive configuration utilitity
  URL:=http://sourceforge.net/projects/hdparm/
endef

define Package/hdparm/description
 get/set SATA/IDE device parameters
endef

define Package/hdparm/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/sbin
endef

$(eval $(call BuildPackage,hdparm))
