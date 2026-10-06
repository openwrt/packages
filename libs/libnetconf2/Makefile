#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnetconf2
PKG_VERSION:=4.4.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/CESNET/libnetconf2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ee52910da3e09f7cfb00f980ec7adb66b792373278b28ec43476934cb123112b

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DENABLE_PAM=OFF

define Package/libnetconf2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=NETCONF library
  URL:=https://github.com/CESNET/libnetconf2
  DEPENDS:=+libyang +libcurl +libssh +libopenssl +libpthread
endef

define Package/libnetconf2/description
 libnetconf2 is the NETCONF library in C intended for building NETCONF clients and servers.

 libnetconf2 provides basic functions to connect NETCONF client and server to each other via
 SSH, to send and receive NETCONF messages. NETCONF datastore implementation is not included.
endef

define Package/libnetconf2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetconf2.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/etc/netconf2/modules
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/yang/modules/libnetconf2/*.yang 		$(1)/etc/netconf2/modules/
endef

$(eval $(call BuildPackage,libnetconf2))
