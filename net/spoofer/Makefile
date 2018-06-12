#
# Copyright (C) 2018 The Regents of the University of California
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=spoofer
PKG_VERSION:=1.3.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.caida.org/projects/spoofer/downloads
PKG_HASH:=2f5076a4ddd749a26eb97f77bd02a6c69cba0f2527fd3ff2ba6d21ec7d3b4914

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

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
# Note: to use standard ssl certs, add "+ca-certificates" to DEPENDS above

define Package/spoofer/description
  The spoofer client is part of a system to measure the Internet's resistance to packets with a spoofed (forged) source IP address.
endef

CONFIGURE_ARGS += \
	--enable-prober \
	--disable-manager \
	$(SPOOFER_CONFIGURE_ARGS)

CONFIGURE_VARS += \
	PROTOC=$(STAGING_DIR_HOSTPKG)/bin/protoc

EXTRA_CXXFLAGS += -std=gnu++14

# If SPOOFER_VPATH is set, use sources in that directory instead of
# downloading from PKG_SOURCE_URL.  (C.f. the openwrt USE_SOURCE_DIR
# mechanism, which seems to incorrectly also apply to dependent packages, and
# writes into the source dir (which is bad if source directory is readonly or
# shared).)
ifdef SPOOFER_VPATH
  SPOOFER_SRC=$(SPOOFER_VPATH)
  CONFIGURE_CMD=$(SPOOFER_VPATH)/configure
  define Download
	: do nothing
  endef
  define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
  endef
else
  SPOOFER_SRC=$(PKG_BUILD_DIR)
endif

define Package/spoofer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/prober/spoofer-prober $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(SPOOFER_SRC)/openwrt-files/initscript $(1)/etc/init.d/spoofer
	$(INSTALL_DIR) $(1)/usr/share/spoofer
	$(INSTALL_DATA) $(SPOOFER_SRC)/gd_bundle.crt $(1)/usr/share/spoofer
endef

$(eval $(call BuildPackage,spoofer))
