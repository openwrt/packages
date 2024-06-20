#
# Copyright (C) 2019 Lucian Cristain <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=powertop
PKG_VERSION:=2.15
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/fenrus75/powertop
PKG_MIRROR_HASH:=50d98933e9c03acd8e600283dbb7ef08d56e10e09441aaf3880c1b0cb42d28c3

PKG_MAINTAINER:=Lucian Cristain <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf gettext-version
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=gettext-full/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/powertop
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=$(INTL_DEPENDS) +libstdcpp +libpci +libncursesw +libnl-genl
  TITLE:=Power consumption monitor
  URL:=https://01.org/powertop
endef

define Package/powertop/description
 PowerTOP is a Linux tool to diagnose issues with power consumption
 and power management.
endef

TARGET_LDFLAGS += \
	$(if $(INTL_FULL),-lintl)

define Package/powertop/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/powertop \
		$(1)/usr/sbin/
endef

$(eval $(call BuildPackage,powertop))
