#
# Copyright (C) 2016-2022 eGloo Incorporated
#
# This is free software, licensed under the GNU General Public License v2.

include $(TOPDIR)/rules.mk

PKG_NAME:=netifyd
PKG_RELEASE:=1
PKG_MAINTAINER:=Darryl Sokoloski <darryl@egloo.ca>
PKG_LICENSE:=GPL-3.0-or-later

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_FLAGS:=gc-sections

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.com/netify.ai/public/netify-agent.git
PKG_SOURCE_DATE:=2023-08-10
PKG_SOURCE_VERSION:=v4.4.7
PKG_MIRROR_HASH:=389fb77e4d6920e94ab9c6febd0049ecd3a34c6b073f3dfb7f204775f3389f07

PKG_CONFIG_DEPENDS:= \
	CONFIG_NETIFYD_BUILD_SHARED_LIBRARY \
	CONFIG_NETIFYD_WITH_LOCAL_LIBGCRYPT

include $(INCLUDE_DIR)/package.mk

define Package/netifyd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Netify Agent
  URL:=http://www.netify.ai/
  DEPENDS:=+ca-bundle +libatomic +libcurl +libmnl +libnetfilter-conntrack +libpcap +zlib +libpthread @!USE_UCLIBC
  # Explicitly depend on libstdcpp rather than $(CXX_DEPENDS).  At the moment
  # std::unordered_map is only available via libstdcpp which is required for
  # performance reasons.
  DEPENDS+=+libstdcpp
  DEPENDS+=+NETIFYD_WITH_LOCAL_LIBGCRYPT:libgcrypt
endef

define Package/netifyd/description
The Netify Agent is a deep-packet inspection server which detects network
protocols and applications.  These detections can be saved locally, served over
a UNIX or TCP socket, and/or "pushed" (via HTTP POSTs) to a remote third-party
server.  Flow metadata, network statistics, and detection classifications are
JSON encoded for easy consumption by third-party applications.
endef

define Package/netifyd/config
	source "$(SOURCE)/Config.in"
endef

define Package/netifyd/conffiles
/etc/netifyd.conf
/etc/config/netifyd
/etc/netify.d/agent.uuid
/etc/netify.d/serial.uuid
/etc/netify.d/site.uuid
endef

TARGET_CFLAGS+=-Wno-psabi
TARGET_CXXFLAGS+=-std=c++11 -Wno-psabi

CONFIGURE_ARGS+= \
	$(if $(CONFIG_NETIFYD_BUILD_SHARED_LIBRARY),--enable-shared,--disable-shared) \
	$(if $(CONFIG_NETIFYD_WITH_LOCAL_LIBGCRYPT),--with-local-libgcrypt,--without-local-libgcrypt) \
	--sharedstatedir=/var/run \
	--enable-lean-and-mean \
	--disable-libtcmalloc \
	--disable-jemalloc \
	--without-systemdsystemunitdir \
	--without-tmpfilesdir

# Disable configuration file-watch support (deprecated feature).
# Not to be confused with kernel/system-level inotify support.
CONFIGURE_ARGS+= \
	--disable-inotify

ifneq ($(CONFIG_LIBCURL_ZLIB),y)
CONFIGURE_ARGS+= \
	--without-libcurl-zlib
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/netifyd
	$(CP) $(PKG_INSTALL_DIR)/usr/include/netifyd/*.h $(1)/usr/include/netifyd
	$(INSTALL_DIR) $(1)/usr/include/netifyd/pcap-compat
	$(CP) $(PKG_INSTALL_DIR)/usr/include/netifyd/pcap-compat/*.h $(1)/usr/include/netifyd/pcap-compat
	$(INSTALL_DIR) $(1)/usr/include/netifyd/nlohmann
	$(CP) $(PKG_INSTALL_DIR)/usr/include/netifyd/nlohmann/*.hpp $(1)/usr/include/netifyd/nlohmann
	$(INSTALL_DIR) $(1)/usr/include/netifyd/radix
	$(CP) $(PKG_INSTALL_DIR)/usr/include/netifyd/radix/*.hpp $(1)/usr/include/netifyd/radix
	$(INSTALL_DIR) $(1)/usr/include/ndpi
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ndpi/*.h $(1)/usr/include/ndpi
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetifyd.a $(1)/usr/lib
	$(if $(CONFIG_NETIFYD_BUILD_SHARED_LIBRARY),$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetifyd.so.* $(1)/usr/lib,)
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnetifyd.pc $(1)/usr/lib/pkgconfig
endef

define Package/netifyd/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/deploy/netifyd.conf $(1)/etc
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/netifyd.config $(1)/etc/config/netifyd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netifyd.init $(1)/etc/init.d/netifyd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/netifyd $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(if $(CONFIG_NETIFYD_BUILD_SHARED_LIBRARY),$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetifyd.so.* $(1)/usr/lib,)
	$(INSTALL_DIR) $(1)/etc/netify.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/deploy/netify-apps.conf $(1)/etc/netify.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/deploy/netify-categories.json $(1)/etc/netify.d
	$(INSTALL_DIR) $(1)/usr/share/netifyd
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/deploy/functions.sh $(1)/usr/share/netifyd
endef

$(eval $(call BuildPackage,netifyd))
