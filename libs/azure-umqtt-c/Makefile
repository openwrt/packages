#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=azure-umqtt-c
PKG_VERSION:=2021-01-20
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Azure/azure-umqtt-c
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0c369ee8b046906d2666c9c850be1b313012e4a7
PKG_MIRROR_HASH:=c6d9cfe8bb3c7db7dc7e867bb2a0ac5d27303785dc335eeb6e5c834ced3ebb8e

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=openssl \
	curl \
	util-linux \
	umock-c \
	macro-utils-c \
	azure-c-shared-utility

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/azure-umqtt-c
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Azure IoT
  TITLE:= C library for MQTT
  URL:=https://github.com/Azure/azure-umqtt-c
endef

define Package/azure-umqtt-c/description
  azure-umqtt-c is a general purpose library build for MQTT protocol
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
	$(INSTALL_DIR) $(1)/usr/include/azureiot/azure_umqtt_c
	$(CP) $(PKG_INSTALL_DIR)/usr/include/azureiot/azure_umqtt_c/*.h \
		$(1)/usr/include/azureiot/azure_umqtt_c/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.a \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/cmake/* \
		$(1)/usr/cmake
endef

define Package/azure-umqtt-c/install
	${INSTALL_DIR} $(1)/usr/lib
#	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/* \
#		$(1)/usr/lib
endef

$(eval $(call BuildPackage,azure-umqtt-c))
