#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=procps-ng3
PKG_VERSION:=3.3.17
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/procps-$(PKG_VERSION)
PKG_SOURCE:=procps-ng-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/procps-ng
PKG_HASH:=4518b3e7aafd34ec07d0063d250fd474999b20b200218c3ae56f5d2113f141b4

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING COPYING.LIB
PKG_CPE_ID:=cpe:/a:procps-ng_project:procps-ng

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/procps-ng3
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+libncurses
	TITLE:=procps-ng old compatibility library
	URL:=https://gitlab.com/procps-ng/procps
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	echo "$(PKG_VERSION)" > "$(PKG_BUILD_DIR)/.tarball-version"
endef

define Package/procps-ng3/description
	Compatibility library of old 3.x version of procps-ng utilities.
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \

define Package/procps-ng3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libprocps.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,procps-ng3))
