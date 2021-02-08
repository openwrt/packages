#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=umock-c
PKG_VERSION:=2020-03-04
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Azure/umock-c
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=504193e65d1c2f6eb50c15357167600a296df7ff
PKG_MIRROR_HASH:=3dea373328c43323dd2cb1425d2adc3aea5fd7486cd6ad9825f681bdf2bf1b4e

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/umock-c
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Azure IoT
  TITLE:=Microsoft Azure IoT SDKs - mocking library for c
  URL:=https://github.com/Azure/umock-c
  DEPENDS:=+macro-utils-c
endef

define Package/umock-c/description
This library is a C mocking library that exposes APIs to allow:
* defining mock functions,
* recording expected calls
* comparing expected calls with actual calls.

On top of the basic functionality, additional convenience features like
modifiers on expected calls are provided.
endef


define Build/Prepare
	$(call Build/Prepare/Default)
	$(RM) -rf $(PKG_BUILD_DIR)/deps
endef

CMAKE_BINARY_SUBDIR:=build_openwrt

CMAKE_OPTIONS:= \
		-Duse_installed_dependencies:bool=ON \
		-Drun_unittests:bool=OFF

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/umock_c
	$(CP) $(PKG_INSTALL_DIR)/usr/include/umock_c/*.h \
			$(1)/usr/include/umock_c/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.a \
			$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/cmake/umock_c* \
		$(1)/usr/cmake
endef

$(eval $(call BuildPackage,umock-c))
