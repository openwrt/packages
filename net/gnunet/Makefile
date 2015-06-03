#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnunet
PKG_SOURCE_VERSION:=35856
PKG_VERSION:=0.10.1-svn$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

# ToDo:
#  - build packages using templates and lists
#  - break-out transports
#    -> get rid of microhttpd and gnurl dependency for gns and vpn
#       requires upstream to split config files
#  - break-out {peer,name,data}store
#  - building and package mysql or postgresql storage backends
#  - package testing stuff

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://gnunet.org/svn/gnunet/
PKG_SOURCE_PROTO:=svn

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS+= \
	--disable-rpath \
	--with-extractor=$(STAGING_DIR)/usr \
	--with-gnutls=$(STAGING_DIR)/usr \
	--with-libgnurl=$(STAGING_DIR)/usr \
	--with-libunistring-prefix=$(STAGING_DIR)/usr \
	--with-ltdl \
	--with-microhttpd=$(STAGING_DIR)/usr \
	--without-mysql \
	--without-postgresql

# ToDo: request upstream to provide --with-pulseaudio=...
TARGET_LDFLAGS+= -Wl,-rpath-link=$(STAGING_DIR)/usr/lib/pulseaudio

define Package/gnunet
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet is peer-to-peer framework focusing on security
  DEPENDS:=+ca-certificates +libgnurl +libgnutls +libidn +libltdl \
           +libmicrohttpd +libunistring +librt
  URL:=https://www.gnunet.org/
  USERID:=gnunet=400:gnunet=400
  MENU:=1
endef

define Package/gnunet/description
 GNUnet is peer-to-peer framework focusing on security.  The first and
 primary application for GNUnet is anonymous file-sharing.  GNUnet is
 currently developed by a worldwide group of independent free software
 developers.  GNUnet is a GNU package (http://www.gnu.org/).

 This is an ALPHA release.  There are known and significant bugs as
 well as many missing features in this release.

 This package provides the core components of GNUnet including the
 CADET routing engine, a DHT implementation and most transports as well
 as their helpers.
endef

define Package/gnunet-conversation
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet conversation components
  DEPENDS:=gnunet +gnunet-gns +libgst1app +libgst1audio \
           +libgstreamer1 +glib2 +pulseaudio-daemon +libopus +libogg
endef

define Package/gnunet-experiments
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet experimental components
  DEPENDS:=gnunet +libglpk
endef

define Package/gnunet-fs
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet file-sharing components
  DEPENDS:=gnunet +gnunet-storage +libextractor
endef

define Package/gnunet-gns
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet GNS components
  USERID:=gnunetdns=401:gnunetdns=401
  DEPENDS:=gnunet +gnunet-vpn
  DEFAULT:=y
endef

define Package/gnunet-storage
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet storage components
  DEPENDS:=gnunet +gnunet-gns +libsqlite3
endef

define Package/gnunet-transport-bluetooth
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet bluetooth transport
  DEPENDS:=gnunet +bluez-libs
endef

define Package/gnunet-utils
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet administration utilities
  DEPENDS:=gnunet +certtool +openssl-util
endef

define Package/gnunet-vpn
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet VPN components
  DEPENDS:=gnunet +kmod-tun
  DEFAULT:=y
endef

define Package/gnunet/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet/config.d $(1)/usr/share/gnunet/hellos

	( for bin in arm ats core ecc identity nat-server nse \
	    peerinfo revocation scalarproduct transport uri; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$bin $(1)/usr/bin/ ; \
	done )

	( for lib in arm ats block cadet core datacache dht \
	    dns dnsparser dnsstub fragmentation friends hello identity nat nse \
	    peerinfo regexblock regex revocation scalarproduct set \
	    statistics transport util; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$lib.so* $(1)/usr/lib/ ; \
	done )

	( for plug in ats_proportional block_dht block_regex \
	    transport_http_client transport_http_server \
	    transport_https_client transport_https_server \
	    transport_tcp transport_udp transport_unix transport_wlan; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$plug*.so $(1)/usr/lib/gnunet ; \
	done )

	( for lex in daemon-hostlist daemon-topology helper-nat-client \
	    helper-nat-server service-arm service-ats service-cadet \
	    service-core service-dht service-identity service-nse \
	    service-peerinfo service-regex service-revocation \
	    service-scalarproduct-alice service-scalarproduct-bob \
	    service-set service-statistics service-transport; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$lex $(1)/usr/lib/gnunet/libexec ; \
	done )

	( for conf in arm ats cadet core datacache dht hostlist \
	    identity nat nse peerinfo regex revocation scalarproduct \
	    set statistics topology transport util; do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$conf.conf $(1)/usr/share/gnunet/config.d ; \
	done )

	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/hellos/* $(1)/usr/share/gnunet/hellos
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/gnunet.init $(1)/etc/init.d/gnunet
endef

define Package/gnunet-conversation/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet/config.d
	( for bin in conversation conversation-test; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$bin $(1)/usr/bin/ ; \
	done )
	( for lib in conversation microphone speaker; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$lib.so* $(1)/usr/lib/ ; \
	done )
	( for plug in gnsrecord_conversation; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$plug*.so $(1)/usr/lib/gnunet ; \
	done )
	( for lex in helper-audio-playback helper-audio-record; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$lex $(1)/usr/lib/gnunet/libexec ; \
	done )
	( for conf in conversation; do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$conf.conf $(1)/usr/share/gnunet/config.d ; \
	done )
endef

define Package/gnunet-experiments/install
	$(INSTALL_DIR) $(1)/usr/lib/gnunet/libexec
	( for plug in ats_mlp ats_ril; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$plug*.so $(1)/usr/lib/gnunet ; \
	done )
endef

define Package/gnunet-fs/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet/config.d
	( for bin in auto-share directory download download-manager.scm fs publish unindex; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$bin $(1)/usr/bin/ ; \
	done )
	( for lib in fs; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$lib.so* $(1)/usr/lib/ ; \
	done )
	( for plug in block_fs datacache_heap datacache_sqlite; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$plug*.so $(1)/usr/lib/gnunet ; \
	done )
	( for lex in helper-fs-publish service-fs; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$lex $(1)/usr/lib/gnunet/libexec ; \
	done )
	( for conf in fs; do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$conf.conf $(1)/usr/share/gnunet/config.d ; \
	done )
endef

define Package/gnunet-gns/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet/config.d
	( for bin in gns namecache resolver; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$bin $(1)/usr/bin/ ; \
	done )
	( for lib in gns gnsrecord namecache namestore; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$lib.so* $(1)/usr/lib/ ; \
	done )
	( for plug in block_dns block_gns gnsrecord_dns gnsrecord_gns; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$plug*.so $(1)/usr/lib/gnunet ; \
	done )
	( for lex in dns2gns gns-proxy helper-dns service-dns \
	    service-gns service-namecache service-resolver; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$lex $(1)/usr/lib/gnunet/libexec ; \
	done )
	( for conf in dns gns namecache resolver; do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$conf.conf $(1)/usr/share/gnunet/config.d ; \
	done )
endef

define Package/gnunet-storage/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet/config.d
	( for bin in datastore peerstore; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$bin $(1)/usr/bin/ ; \
	done )
	( for lib in datastore peerstore; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$lib.so* $(1)/usr/lib/ ; \
	done )
	( for plug in datastore_heap datastore_sqlite namecache_sqlite namestore_sqlite; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$plug*.so $(1)/usr/lib/gnunet ; \
	done )
	( for lex in daemon-latency-logger namestore-fcfsd service-datastore service-peerstore; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$lex $(1)/usr/lib/gnunet/libexec ; \
	done )
	( for conf in datastore peerstore; do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$conf.conf $(1)/usr/share/gnunet/config.d ; \
	done )
endef

define Package/gnunet-transport-bluetooth/install
	$(INSTALL_DIR) $(1)/usr/lib/gnunet/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_transport_bluetooth.so $(1)/usr/lib/gnunet
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-helper-transport-bluetooth $(1)/usr/lib/gnunet/libexec
endef

define Package/gnunet-utils/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	( for bin in config gns-import.sh gns-proxy-setup-ca \
	    transport-certificate-creation; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$bin $(1)/usr/bin/ ; \
	done )
endef

define Package/gnunet-vpn/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet/config.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-vpn $(1)/usr/bin/
	( for lib in tun vpn; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$lib.so* $(1)/usr/lib/ ; \
	done )
	( for lex in daemon-exit daemon-pt helper-exit  helper-vpn service-vpn; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$lex $(1)/usr/lib/gnunet/libexec ; \
	done )
	( for conf in exit pt vpn; do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$conf.conf $(1)/usr/share/gnunet/config.d ; \
	done )
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gnunet $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{la,so}* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gnunet/*.h $(1)/usr/include/gnunet
endef

$(eval $(call BuildPackage,gnunet))
$(eval $(call BuildPackage,gnunet-conversation))
$(eval $(call BuildPackage,gnunet-experiments))
$(eval $(call BuildPackage,gnunet-fs))
$(eval $(call BuildPackage,gnunet-gns))
$(eval $(call BuildPackage,gnunet-storage))
$(eval $(call BuildPackage,gnunet-transport-bluetooth))
$(eval $(call BuildPackage,gnunet-utils))
$(eval $(call BuildPackage,gnunet-vpn))
