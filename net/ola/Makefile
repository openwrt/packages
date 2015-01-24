#
# Copyright (C) 2006-2011 OpenWrt.org
# Copyright (C) 2015 Christian Beier <dontmind@freeshell.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ola
PKG_VERSION:=0.9.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenLightingProject/ola.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=d949ab88ab2c12d4d94b50a0a0df633d634f08fd
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_LICENSE:=LGPL-2.1+

PKG_FIXUP:=libtool
PKG_INSTALL:=1

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_BUILD_DEPENDS:=protobuf/host ola/host

include $(INCLUDE_DIR)/package.mk


define Package/ola
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Open Lighting Architecture Daemon
  URL:=https://www.openlighting.org/
  MAINTAINER:=Christian Beier <dontmind@freeshell.org>
  DEPENDS:=+protobuf +libusb-1.0 +libuuid +libstdcpp +libpthread +librt +zlib +libncurses +sudo @BROKEN
endef

define Package/ola/description
  OLA (Open Lighting Architecture) is a framework that allows applications to 
  send and receive DMX512, using various hardware devices and 'DMX over IP'
  protocols. It enables software controllers talk to DMX hardware.
endef


include $(INCLUDE_DIR)/host-build.mk

# When building the host part, disable as much as possible to speed up
# the configure step and avoid missing host dependencies.
# Stolen from http://git.buildroot.net/buildroot/commit/?id=66056a5179ef49f2ec10ba5d7fbd1a58863d1350
define Host/Configure
   $(call Host/Configure/Default,\
	--disable-all-plugins \
	--disable-slp \
	--disable-osc \
	--disable-uart \
	--disable-libusb \
	--disable-libftdi \
	--disable-http  \
	--disable-examples \
	--disable-unittests \
	--disable-doxygen-html \
	--disable-doxygen-doc)
endef

# only build the ola_protoc thingy
define Host/Compile
	cd $(HOST_BUILD_DIR); \
	    $(MAKE) protoc/ola_protoc
endef

# only need ola_protoc
define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/bin
	$(CP) $(HOST_BUILD_DIR)/protoc/ola_protoc $(STAGING_DIR_HOST)/bin/
endef

$(eval $(call HostBuild))



define Build/Configure
  $(call Build/Configure/Default,\
	--disable-dependency-tracking \
	--disable-static \
	--disable-fatal-warnings \
	--disable-unittests \
	--disable-http  \
	--with-ola-protoc=$(STAGING_DIR_HOST)/bin/ola_protoc)
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
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/olad.init $(1)/etc/init.d/olad
	$(INSTALL_DIR) $(1)/usr/share/ola/pids
	$(CP) $(PKG_INSTALL_DIR)/usr/share/ola/pids/* $(1)/usr/share/ola/pids
endef

define Package/ola/postinst
#!/bin/sh

# make sure the conf dir exists and is writeable by the group olad uses
mkdir -p /etc/ola
chgrp nogroup /etc/ola
chmod 775 $(1)/etc/ola

exit 0
endef


$(eval $(call BuildPackage,ola))
