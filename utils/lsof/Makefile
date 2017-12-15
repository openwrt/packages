#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lsof
PKG_VERSION:=4.89
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://www.mirrorservice.org/sites/lsof.itap.purdue.edu/pub/tools/unix/lsof/ ftp://sunsite.ualberta.ca/pub/Mirror/lsof/ ftp://ftp.fu-berlin.de/pub/unix/tools/lsof
PKG_HASH:=81ac2fc5fdc944793baf41a14002b6deb5a29096b387744e28f8c30a360a3718
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)
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

ifneq ($(CONFIG_IPV6),n)
  LINUX_CLIB_IPV6=-DHASIPv6
else
  LINUX_CLIB_IPV6=
endif

define Build/Prepare
	$(PKG_UNPACK)
	(cd $(PKG_BUILD_DIR) && tar -xf $(PKG_NAME)_$(PKG_VERSION)_src.tar && mv $(PKG_NAME)_$(PKG_VERSION)_src/* .)
	$(Build/Patch)
endef

define Build/Configure
	cd $(PKG_BUILD_DIR); \
		LINUX_CLIB="-DGLIBCV=2 $(LINUX_CLIB_IPV6)" \
		LSOF_CC="$(TARGET_CC)" \
		LSOF_VSTR="$(LINUX_VERSION)" \
		LSOF_CFGF="$(TARGET_CFLAGS)" \
		LSOF_CFGL="$(TARGET_LDFLAGS)" \
		LSOF_AR="$(TARGET_CROSS)ar cr" \
		LSOF_RANLIB="$(TARGET_CROSS)ranlib" \
		./Configure -n linux
endef

define Build/Compile	
	LSOF_HOST="none" \
	LSOF_LOGNAME="none" \
	LSOF_SYSINFO="none" \
	LSOF_USER="none" \
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Package/lsof/install	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lsof $(1)/usr/bin
endef

$(eval $(call BuildPackage,lsof))
