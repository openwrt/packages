#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=azure-uhttp-c
PKG_VERSION:=2021-01-20
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Azure/azure-uhttp-c
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=d286589762e59f0ad2f92f7c5a58f7979b5ab082
PKG_MIRROR_HASH:=9734277922dd9961fc7bd69e4844ddc7669eec675efab78f9f5aa8af19247006

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

define Package/azure-uhttp-c
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Azure IoT
  TITLE:=Microsoft Azure IoT SDKs - HTTP library for c
  URL:=https://github.com/Azure/azure-uhttp-c
endef

define Package/azure-uhttp-c/description
The uhttp provides a platform independent HTTP implementation written in c.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(RM) -rf $(PKG_BUILD_DIR)/deps
endef

CMAKE_BINARY_SUBDIRi:=build_openwrt

CMAKE_OPTIONS:= \
		-Duse_installed_dependencies:bool=ON \
		-Duse_openssl:bool=ON \
		-Dskip_samples:bool=ON

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/azureiot/azure_uhttp_c
	$(CP) $(PKG_INSTALL_DIR)/azureiot/azure_uhttp_c/*.h \
		$(1)/usr/include/azureiot/azure_uhttp_c/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.a \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/cmake/* \
		$(1)/usr/cmake
endef

$(eval $(call BuildPackage,azure-uhttp-c))
