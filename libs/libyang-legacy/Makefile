#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libyang-legacy
PKG_VERSION:=3.13.6
PKG_RELEASE:=1

PKG_SOURCE:=libyang-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/CESNET/libyang/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=5cd5018f39c830f97d70616c003990287ce5e820ae2792763a49e2a1f63af8d6

PKG_BUILD_DIR:=$(BUILD_DIR)/libyang-$(PKG_VERSION)

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:cesnet:libyang

CMAKE_INSTALL:=1
CMAKE_BINARY_SUBDIR:=build

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libyang-legacy
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=YANG data modeling language library (legacy v3 ABI)
  URL:=https://github.com/CESNET/libyang
  DEPENDS:=+libpcre2 +libpthread +libxxhash
endef

define Package/libyang-legacy/description
  libyang-legacy ships the libyang 3.x runtime (libyang.so.3) for binaries
  still linked against the legacy ABI. It is install-time co-installable
  with libyang 5.x (libyang.so.5), whose SONAME differs.

  Build-time consumers should point CMAKE_PREFIX_PATH (or PKG_CONFIG_PATH)
  at $$$$(STAGING_DIR)/usr/lib/libyang-legacy so that the legacy headers,
  library and pkg-config file are picked up in preference to libyang 5.x.
endef

# Staged under a self-contained /usr/lib/libyang-legacy prefix, with a
# sysroot-relative .pc prefix so pkg-config does not double-prepend.
define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/libyang-legacy/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libyang \
		$(1)/usr/lib/libyang-legacy/include/
	$(INSTALL_DIR) $(1)/usr/lib/libyang-legacy/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyang.so* \
		$(1)/usr/lib/libyang-legacy/lib/
	$(INSTALL_DIR) $(1)/usr/lib/libyang-legacy/lib/pkgconfig
	sed -e 's|^prefix=.*|prefix=/usr/lib/libyang-legacy|' \
	    -e 's|^libdir=.*|libdir=$${prefix}/lib|' \
	    -e 's|^includedir=.*|includedir=$${prefix}/include|' \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libyang.pc \
		> $(1)/usr/lib/libyang-legacy/lib/pkgconfig/libyang.pc
endef

define Package/libyang-legacy/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyang.so.3* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libyang-legacy))
