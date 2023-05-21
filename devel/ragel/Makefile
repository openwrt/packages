#
# Copyright (C) 2023 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ragel
PKG_VERSION:=6.10
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.colm.net/files/ragel/
PKG_SOURCE:=ragel-$(PKG_VERSION).tar.gz
PKG_HASH:=5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f
#PKG_BUILD_DIR:=$(BUILD_DIR)/ragel-$(PKG_VERSION)

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL
PKG_LICENSE_FILES:=COPYING
PKG_HOST_ONLY:=1
#HOST_BUILD_PARALLEL:=1
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/ragel-$(PKG_VERSION)

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/ragel
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=Compiles finite state machines from regular languages into executable code
  DEPENDS:=+libc +libstdcpp
  URL:=https://www.colm.net/open-source/ragel/
  BUILDONLY:=1
endef

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(CXXFLAGS) -std=gnu++98" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/usr/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/ragel/ragel $(STAGING_DIR_HOSTPKG)/usr/bin/ragel
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,ragel))
