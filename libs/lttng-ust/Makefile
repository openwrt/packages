#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lttng-ust
PKG_VERSION:=2.10.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://lttng.org/files/$(PKG_NAME)/
PKG_HASH:=9e8420f90d5f963f7aa32bc6d44adc1e491136f687c69ffb7a3075d33b40852b

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1 GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:lttng:ust

PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lttng-ust
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Linux Trace Toolkit: next generation (library)
  URL:=https://lttng.org/
  DEPENDS:= +liburcu +libuuid +librt
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--without-pic

CONFIGURE_VARS += \
	ac_cv_prog_BUILD_GEN_TP_EXAMPLES=no

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lttng $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblttng-ust*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lttng-ust.pc $(1)/usr/lib/pkgconfig/
endef

define Package/lttng-ust/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblttng*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,lttng-ust))
