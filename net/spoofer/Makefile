#
# Copyright (C) 2019 The Regents of the University of California
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=spoofer
PKG_VERSION:=1.4.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.caida.org/projects/spoofer/downloads
PKG_HASH:=994555b360a095f0e9baed2469ef26bd29610af155ce58b3984d2f1616a74526

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_USE_MIPS16:=0
HOST_BUILD_DEPENDS:=protobuf/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

$(eval $(call HostBuild))

define Package/spoofer
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Measure your ISP's resistance to spoofed IP packets
  URL:=https://spoofer.caida.org/
  MAINTAINER:=Ken Keys <spoofer-info@caida.org>
  DEPENDS:=+protobuf-lite +libpcap +libpthread +libopenssl
endef

define Package/spoofer/description
The spoofer client is part of a system to measure the Internet's
resistance to packets with a spoofed (forged) source IP address.

This package comes bundled with a small certificate file that allows
secure communication with the spoofer server without depending on
the large ca-certificates package.  But if the server's private
certificate ever changes, it will be necessary to either install the
ca-certificates package or install an updated version of this package
that has a newer bundled certificate.

endef

CONFIGURE_ARGS += \
	--enable-prober \
	--disable-manager

CONFIGURE_VARS += \
	PROTOC=$(STAGING_DIR_HOSTPKG)/bin/protoc

EXTRA_CXXFLAGS += -std=gnu++14

SPOOFER_SRC=$(PKG_BUILD_DIR)

define Package/spoofer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/prober/spoofer-prober $(1)/usr/bin
	$(INSTALL_BIN) $(SPOOFER_SRC)/openwrt-files/spoofer $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(SPOOFER_SRC)/openwrt-files/initscript $(1)/etc/init.d/spoofer
	$(INSTALL_DIR) $(1)/usr/share/spoofer
	$(INSTALL_DATA) $(SPOOFER_SRC)/gd_bundle.crt $(1)/usr/share/spoofer
	$(INSTALL_DATA) $(SPOOFER_SRC)/openwrt-files/spoofer-lib.sh $(1)/usr/share/spoofer
endef

$(eval $(call BuildPackage,spoofer))
