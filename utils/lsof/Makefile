#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lsof
PKG_VERSION:=4.86
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION)+dfsg.orig.tar.gz
PKG_SOURCE_URL:=http://ftp2.de.debian.org/debian/pool/main/l/lsof
PKG_MD5SUM:=23420509564a897b76055f9d84d19068
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)+dfsg.orig
PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=Unique
PKG_LICENSE_FILES:=00README

include $(INCLUDE_DIR)/package.mk

TARGET_LDFLAGS += $(LIBRPC)

define Package/lsof
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=$(LIBRPC_DEPENDS)
  TITLE:=LiSt Open Files - a diagnostic tool
  URL:=http://people.freebsd.org/~abe/
endef

define Build/Configure
	cd $(PKG_BUILD_DIR); \
		LINUX_CLIB="-DGLIBCV=2" \
		LSOF_CC="$(TARGET_CC)" \
		LSOF_INCLUDE="-I$(STAGING_DIR)/usr/include" \
		LSOF_VSTR="$(LINUX_VERSION)" \
		LSOF_CFGF="$(TARGET_CFLAGS)" \
		LSOF_CFGL="$(TARGET_LDFLAGS)" \
		LSOF_AR="$(TARGET_CROSS)ar cr" \
		LSOF_RANLIB="$(TARGET_CROSS)ranlib" \
		./Configure -n linux
endef

define Build/Compile	
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Package/lsof/install	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lsof $(1)/usr/bin
endef

$(eval $(call BuildPackage,lsof))
