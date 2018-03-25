#
# Copyright (C) 2018 Othmar Truniger
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libfmt
PKG_VERSION:=4.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/fmtlib/fmt.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_LICENSE:=BSD-2-Clause
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MIRROR_HASH:=112c964c1537fbc2f3a993f405547fc57b0f3d1524c808006920c53fab42c233

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libfmt
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Small, safe and fast formatting library
  URL:=https://github.com/fmtlib/fmt
endef

define Package/libfmt/description
  fmt is an open-source formatting library for C++.
  It can be used as a safe alternative to printf or as a fast alternative to IOStreams.
endef

define Build/Compile
	+$(MAKE) -C $(PKG_BUILD_DIR) fmt
endef

# nothing to do
define Build/Install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/fmt
	$(CP) $(PKG_BUILD_DIR)/fmt/*.h $(1)/usr/include/fmt/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/fmt/libfmt.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfmt))
