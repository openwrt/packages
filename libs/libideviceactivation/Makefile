#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libideviceactivation
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/libideviceactivation.git
PKG_SOURCE_DATE:=2025-07-14
PKG_SOURCE_VERSION:=a9c143443c71ecbd186ad22e2c5082dfa8808467
PKG_MIRROR_HASH:=b4ce681049a1700d14ebe91f9a73e3593e95767415e7a831530c90d6cc312ea5

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LESSER
PKG_CPE_ID:=cpe:/a:libimobiledevice:libideviceactivation

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libideviceactivation/Default
  TITLE:=Manage the activation of Apple iOS devices
  URL:=https://www.libimobiledevice.org/
  SUBMENU:=libimobiledevice
endef

define Package/libideviceactivation/Default/description
  A library to manage the activation process of Apple iOS devices.
  This project provides an interface to activate and deactivate iOS devices
  by talking to Apple's webservice alongside a command-line utility named
  ideviceactivation.
  - Status: Implements complete activation and deactivation process
  - Compatibility: Supports legacy and latest activation webservice APIs
  - Utility: Provides ideviceactivation utility for command-line usage
  - Interactive: Requests user input if the activation process uses forms
  - Cross-Platform: Tested on Linux, macOS, Windows and Android platforms
endef

define Package/libideviceactivation
  $(call Package/libideviceactivation/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libcurl +libimobiledevice +usbmuxd
  LICENSE:=LGPL-2.1-or-later
  LICENSE_FILES:=COPYING.LESSER
endef

define Package/libideviceactivation/description
  $(call Package/libideviceactivation/Default/description)
endef

define Package/libideviceactivation-utils
  $(call Package/libideviceactivation/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libideviceactivation
  LICENSE:=GPL-3.0-or-later
  ICENSE_FILES:=COPYING
endef

define Package/libideviceactivation-utils/description
  $(call Package/libideviceactivation/Default/description)
  This package contains the libideviceactivation utilities.
endef

CONFIGURE_ARGS += \
	PACKAGE_VERSION=$(PKG_VERSION)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libideviceactivation.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libideviceactivation-1.0.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libideviceactivation-1.0.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libideviceactivation/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libideviceactivation-1.0.so.* $(1)/usr/lib/
endef

define Package/libideviceactivation-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ideviceactivation $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libideviceactivation))
$(eval $(call BuildPackage,libideviceactivation-utils))
