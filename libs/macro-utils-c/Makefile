#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=macro-utils-c
PKG_VERSION:=2019-09-23
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Azure/macro-utils-c
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=5926caf4e42e98e730e6d03395788205649a3ada
PKG_MIRROR_HASH:=ed10f1047476f0a7f89bf10eb833a39bfefea5d232539e0d1db72b717ff39865

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/macro-utils-c
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Azure IoT
  TITLE:=Microsoft Azure IoT SDKs - macro utils for c
  URL:=https://github.com/Azure/macro-utils-c
endef

define Package/macro-utils-c/description
A C header file that contains a multitude of very useful C macros.
endef

CMAKE_BINARY_SUBDIR:=build_openwrt

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/azure_macro_utils
	$(CP) $(PKG_INSTALL_DIR)/usr/include/azure_macro_utils/*.h \
		$(1)/usr/include/azure_macro_utils/

	$(INSTALL_DIR) $(1)/usr/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/cmake/*.cmake \
		$(1)/usr/cmake/
endef

$(eval $(call BuildPackage,macro-utils-c))
