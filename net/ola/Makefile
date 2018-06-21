#
# Copyright (C) 2006-2015 OpenWrt.org
# Copyright (C) 2015-2017 Christian Beier <dontmind@freeshell.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ola
PKG_VERSION:=0.10.6
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenLightingProject/ola.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=6e57342c414a72cdd721e8df5bc7967e17459647
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=c1f36eaedcd9711e42fd362ff84d8e66eb40bc6af97de77129a5074d05fb9936
PKG_LICENSE:=LGPL-2.1+

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
  DEPENDS:=+protobuf +libusb-1.0 +libuuid +libstdcpp +libpthread +librt +zlib +libncurses +liblo +libmicrohttpd
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
	--disable-libftdi \
	--disable-http  \
	--disable-examples \
	--disable-unittests \
	--disable-doxygen-html \
	--disable-doxygen-doc

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
