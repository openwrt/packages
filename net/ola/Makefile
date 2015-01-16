#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ola
PKG_VERSION:=0.8.27
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://open-lighting.googlecode.com/files
PKG_SHA1SUM:=e9826752eecb5d011634b0d7cef270a11adc06fb

PKG_FIXUP:=libtool
PKG_INSTALL:=1

PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=protobuf

include $(INCLUDE_DIR)/package.mk

#PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
#define Build/Prepare
#	rm -r $(PKG_BUILD_DIR)
#	mkdir -p $(PKG_BUILD_DIR)
#	$(CP) /home/markus/svn/open-lighting/** $(PKG_BUILD_DIR)/
#endef

define Package/ola
  SECTION:=ola
  CATEGORY:=Open Lighting Architecture
  TITLE:=Open Lighting Architecture Daemon
  URL:=http://code.google.com/p/linux-lighting/
  DEPENDS:=+libartnet +protobuf +libmicrohttpd +libusb-1.0 +libuuid +libstdcpp +libpthread +librt +zlib +libncurses
endef

define Package/ola/description
  OLA (Open Lighting Architecture) is a framework that allows applications to 
  send and receive DMX512, using various hardware devices and 'DMX over IP'
  protocols. It enables software controllers talk to DMX hardware.
endef

define Build/Configure
  $(call Build/Configure/Default,--disable-dependency-tracking --disable-static --disable-slp --disable-root-check --disable-fatal-warnings --disable-unittests)
endef

define Build/InstallDev
	mkdir -p $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ola $(1)/usr/include/
	mkdir -p $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/olad $(1)/usr/include/
	mkdir -p $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

define Package/ola/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/olad
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/olad/*.so* $(1)/usr/lib/olad
	$(INSTALL_DIR) $(1)/usr/share/olad/www
	$(CP) $(PKG_INSTALL_DIR)/usr/share/olad $(1)/usr/share
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/olad.init $(1)/etc/init.d/olad
endef

$(eval $(call BuildPackage,ola))
