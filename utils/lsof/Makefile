#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lsof
PKG_VERSION:=4.91
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://www.mirrorservice.org/sites/lsof.itap.purdue.edu/pub/tools/unix/lsof/ ftp://ftp.fu-berlin.de/pub/unix/tools/lsof
PKG_HASH:=c9da946a525fbf82ff80090b6d1879c38df090556f3fe0e6d782cb44172450a3
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)

PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=Unique
PKG_LICENSE_FILES:=00README

include $(INCLUDE_DIR)/package.mk

define Package/lsof
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libtirpc
  TITLE:=LiSt Open Files - a diagnostic tool
  URL:=http://people.freebsd.org/~abe/
endef

ifneq ($(CONFIG_IPV6),n)
  LINUX_CLIB_IPV6=-DHASIPv6
else
  LINUX_CLIB_IPV6=
endif

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/tirpc
TARGET_LDFLAGS += -ltirpc

define Build/Prepare
	$(PKG_UNPACK)
	(cd $(PKG_BUILD_DIR) && tar -xf $(PKG_NAME)_$(PKG_VERSION)_src.tar && mv $(PKG_NAME)_$(PKG_VERSION)_src/* .)
	$(Build/Patch)
endef

define Build/Configure
	$(SED) 's/rpc\/rpc/\/tirpc\/rpc\/rpc/g' $(PKG_BUILD_DIR)/Configure
	cd $(PKG_BUILD_DIR); \
		LINUX_CLIB="-DGLIBCV=2 $(LINUX_CLIB_IPV6)" \
		LSOF_CC="$(TARGET_CC)" \
		LSOF_VSTR="$(LINUX_VERSION)" \
		LSOF_CFGF="$(TARGET_CFLAGS)" \
		LSOF_CFGL="$(TARGET_LDFLAGS)" \
		LSOF_AR="$(TARGET_CROSS)ar cr" \
		LSOF_RANLIB="$(TARGET_CROSS)ranlib" \
		LSOF_INCLUDE="$(STAGING_DIR)/usr/include" \
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
