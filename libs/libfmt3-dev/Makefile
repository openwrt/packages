#
# Copyright (C) 2014-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libfmt3-dev
PKG_VERSION:=3.0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/fmtlib/fmt.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_LICENSE:=BSD-2-Clause
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libfmt3-dev
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Small, safe and fast formatting library
  URL:=https://github.com/fmtlib/fmt
endef

define Package/libfmt3-dev/description
  fmt is an open-source formatting library for C++.
  It can be used as a safe alternative to printf or as a fast alternative to IOStreams.
endef

define Build/Compile
	+$(MAKE) -C $(PKG_BUILD_DIR) fmt
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/fmt
	$(CP) $(PKG_BUILD_DIR)/fmt/format.h $(1)/usr/include/fmt/
	$(CP) $(PKG_BUILD_DIR)/fmt/ostream.h $(1)/usr/include/fmt/
	$(CP) $(PKG_BUILD_DIR)/fmt/posix.h $(1)/usr/include/fmt/
	$(CP) $(PKG_BUILD_DIR)/fmt/time.h $(1)/usr/include/fmt/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/fmt/libfmt.a $(1)/usr/lib/
endef

define Build/Install
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/include/fmt
	$(CP) $(PKG_BUILD_DIR)/fmt/format.h $(PKG_INSTALL_DIR)/usr/include/fmt/
	$(CP) $(PKG_BUILD_DIR)/fmt/ostream.h $(PKG_INSTALL_DIR)/usr/include/fmt/
	$(CP) $(PKG_BUILD_DIR)/fmt/posix.h $(PKG_INSTALL_DIR)/usr/include/fmt/
	$(CP) $(PKG_BUILD_DIR)/fmt/time.h $(PKG_INSTALL_DIR)/usr/include/fmt/
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/fmt/libfmt.a $(PKG_INSTALL_DIR)/usr/lib/
endef

define Package/libfmt3-dev/install
	$(INSTALL_DIR) $(1)/usr/include/fmt
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fmt/* $(1)/usr/include/fmt/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfmt.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfmt3-dev))
