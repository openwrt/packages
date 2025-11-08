#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=azure-uamqp-c
PKG_VERSION:=2021-01-20
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Azure/azure-uamqp-c
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=bf3f62e8a2359e2a6b363502097bfcd87c1dff47
PKG_MIRROR_HASH:=775a9c756ab5ef7273e896ff8e54f8312101116ef17797d64dbc4d504290e5b6

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

# This packages are linked statically
PKG_BUILD_DEPENDS:= \
	macro-utils-c \
	umock-c \
	azure-c-shared-utility

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/azure-uamqp-c
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Azure IoT
  TITLE:=Microsoft Azure IoT SDKs - AMQP library for c
  URL:=https://github.com/Azure/azure-uamqp-c
  DEPENDS:= \
    +libuuid \
    +libopenssl \
    +libcurl
endef

define Package/azure-uamqp-c/description
This is a general purpose C library for AMQP 1.0.
The goals are:
* Compliance with the standard
* Optimizing for low RAM footprint
* Be as portable as possible
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
	$(INSTALL_DIR) $(1)/usr/include/azureiot/azure_uamqp_c
	$(CP) $(PKG_INSTALL_DIR)/usr/include/azureiot/azure_uamqp_c/*.h \
		$(1)/usr/include/azureiot/azure_uamqp_c/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.a \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/cmake/* \
		$(1)/usr/cmake
endef

$(eval $(call BuildPackage,azure-uamqp-c))
