#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnetconf2
PKG_VERSION:=0.12-r1
PKG_RELEASE:=3

PKG_LICENSE:=BSD-3-Clause
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/CESNET/libnetconf2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=86269d3f1bc85bb17d8823d214f9a676ee3b14ee18a0b87a230380df8503e8f5

CMAKE_INSTALL:=1

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libnetconf2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=NETCONF library
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:= +libyang +libssh +libopenssl +libpthread
endef

define Package/libnetconf2/description
 libnetconf2 is the NETCONF library in C intended for building NETCONF clients and servers.

 libnetconf2 provides basic functions to connect NETCONF client and server to each other via
 SSH, to send and receive NETCONF messages. NETCONF datastore implementation is not included.
endef

CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX:PATH=/usr \
	-DCMAKE_BUILD_TYPE:STRING=Release

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libnetconf2
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libnetconf2/*.h $(1)/usr/include/libnetconf2/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetconf2.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/include/libnetconf2
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/include/libnetconf2/* $(1)/usr/include/libnetconf2/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnetconf2.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libnetconf2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetconf2.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/share/libnetconf2
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/libnetconf2/*.yin $(1)/usr/share/libnetconf2/
endef

$(eval $(call BuildPackage,libnetconf2))
