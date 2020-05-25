#
# Copyright (C) 2006-2015 OpenWrt.org
# Copyright (C) 2015-2017 Christian Beier <dontmind@freeshell.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ola
PKG_VERSION:=0.10.7
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/OpenLightingProject/ola/tar.gz/$(PKG_VERSION)?
PKG_HASH:=95b5e99775f700a9cdf6e2219eccfc8c037fa8841f87cb00344359c4b8c7bf26

PKG_LICENSE:=LGPL-2.1-or-later

PKG_FIXUP:=libtool

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

HOST_BUILD_DEPENDS:=protobuf/host
PKG_BUILD_DEPENDS:=ola/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/ola
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Open Lighting Architecture Daemon
  URL:=https://www.openlighting.org/
  MAINTAINER:=Christian Beier <dontmind@freeshell.org>
  DEPENDS:=+protobuf +libftdi1 +libusb-1.0 +libuuid +libstdcpp +libpthread +librt +zlib +libncurses +liblo +libmicrohttpd
endef

define Package/ola/description
  OLA (Open Lighting Architecture) is a framework that allows applications to
  send and receive DMX512, using various hardware devices and 'DMX over IP'
  protocols. It enables software controllers talk to DMX hardware.
endef

CONFIGURE_ARGS += \
	--disable-dependency-tracking \
	--disable-static \
	--disable-fatal-warnings \
	--disable-unittests \
	--without-dns-sd \
	--with-ola-protoc-plugin=$(STAGING_DIR_HOSTPKG)/bin/ola_protoc_plugin

HOST_CONFIGURE_ARGS += \
	--disable-all-plugins \
	--disable-slp \
	--disable-osc \
	--disable-uart \
	--disable-libusb \
	--disable-http  \
	--disable-examples \
	--disable-unittests \
	--disable-doxygen-html \
	--disable-doxygen-doc

HOST_CPPFLAGS += \
	-std=gnu++11

# only build the ola_protoc thingy
define Host/Compile
	cd $(HOST_BUILD_DIR); \
		$(MAKE) protoc/ola_protoc_plugin
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(CP) $(HOST_BUILD_DIR)/protoc/ola_protoc_plugin $(STAGING_DIR_HOSTPKG)/bin
endef


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ola $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/olad $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
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

	$(INSTALL_DIR) $(1)/usr/share/olad/www
	$(CP) $(PKG_INSTALL_DIR)/usr/share/olad/www/* $(1)/usr/share/olad/www
endef

define Package/ola/postinst
#!/bin/sh

# make sure the conf dir exists and is writeable by the group olad uses
mkdir -p $${IPKG_INSTROOT}/etc/ola
chgrp nogroup $${IPKG_INSTROOT}/etc/ola
chmod 775 $${IPKG_INSTROOT}/etc/ola
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,ola))
