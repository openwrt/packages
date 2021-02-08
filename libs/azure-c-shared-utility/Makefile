#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=azure-c-shared-utility
PKG_VERSION:=2020-03-04
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Azure/azure-c-shared-utility
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=ef6ebf91a2e3530275050f0f789bab9f744c45e9
PKG_MIRROR_HASH:=6e49bdcacb3abd04cde91bd7b560e1a92fab8632e0399f0815de478d6eb2ccd9

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

# This packages are linked statically
PKG_BUILD_DEPENDS:= \
	macro-utils-c \
	umock-c

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/azure-c-shared-utility
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Azure IoT
  TITLE:=Microsoft Azure IoT SDKs - util library for c
  URL:=https://github.com/Azure/azure-c-shared-utility
  DEPENDS:= \
    +libuuid \
    +libopenssl \
    +libcurl
endef

define Package/azure-c-shared-utility/description
This shared utility library is a C library providing common functionality for
basic tasks (like string, list manipulation, IO, etc.).
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(RM) -rf $(PKG_BUILD_DIR)/deps
endef

CMAKE_BINARY_SUBDIR:=build_openwrt

CMAKE_OPTIONS:= \
		-Duse_installed_dependencies:bool=ON \
		-Drun_unittests:bool=OFF \
		-Dbuild_as_dynamic:bool=ON \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/azureiot/azure_c_shared_utility
	$(CP) $(PKG_INSTALL_DIR)/usr/include/azureiot/azure_c_shared_utility/*.h \
		$(1)/usr/include/azureiot/azure_c_shared_utility/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/cmake/* \
		$(1)/usr/cmake
endef

define Package/azure-c-shared-utility/install
	${INSTALL_DIR} $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/*.so \
		$(1)/usr/lib
endef

$(eval $(call BuildPackage,azure-c-shared-utility))
