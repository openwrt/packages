#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netperf
PKG_VERSION:=2.7.0
PKG_RELEASE:=3
PKG_LICENSE:=Custom

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/HewlettPackard/netperf
PKG_MIRROR_HASH:=fa46ffc25a00c925167d96e4c57131b5b650ea725b12b69ff6feabec759b271d

PKG_CPE_ID:=cpe:/a:netperf:netperf

include $(INCLUDE_DIR)/package.mk

define Package/netperf
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Network performance measurement tool
  URL:=https://github.com/HewlettPackard/netperf
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
endef

TARGET_CFLAGS+=-std=gnu89

CONFIGURE_ARGS += --enable-demo

define Package/netperf/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netserver.init $(1)/etc/init.d/netserver
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/netperf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/netserver $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/arr_script $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/packet_byte_script $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/sctp_stream_script $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/snapshot_script $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/tcp_range_script $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/tcp_rr_script $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/tcp_stream_script $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/udp_rr_script $(1)/lib/netperf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/udp_stream_script $(1)/lib/netperf
endef

$(eval $(call BuildPackage,netperf))
