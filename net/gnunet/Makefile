#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnunet
PKG_SOURCE_VERSION:=35937
PKG_VERSION:=0.10.1-svn$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

# ToDo:
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

define Package/gnunet/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet
  URL:=https://www.gnunet.org/
endef

define Package/gnunet
$(call Package/gnunet/Default)
  TITLE+= - a peer-to-peer framework focusing on security
  DEPENDS:=+ca-certificates +libgnurl +libgnutls +libidn +libltdl \
           +libmicrohttpd +libunistring +librt
  USERID:=gnunet=400:gnunet=400
  MENU:=1
endef

define Package/gnunet/description
 GNUnet is a peer-to-peer framework focusing on security. The first and
 primary application for GNUnet is anonymous file-sharing.  GNUnet is
 currently developed by a worldwide group of independent free software
 developers.  GNUnet is a GNU package (http://www.gnu.org/).

 This is an ALPHA release.  There are known and significant bugs as
 well as many missing features in this release.

 This package provides the core components of GNUnet including the
 CADET routing engine, a DHT implementation and most transports as well
 as their helpers.
endef

define BuildComponent
  define Package/gnunet-$(1)
    $$(call Package/gnunet/Default)
    TITLE+= $(2)
    DEPENDS:=gnunet $(DEPENDS_$(1))
    $(if $(3),DEFAULT:=y if PACKAGE_gnunet)
    $(if $(USERID_$(1)),USERID:=$(USERID_$(1)))
  endef

  define Package/gnunet-$(1)/install
	( if [ "$(BIN_$(1))" ]; then \
		$(INSTALL_DIR) $$(1)/usr/bin ; \
		for bin in $(BIN_$(1)); do \
			$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$$$$$bin $$(1)/usr/bin/ ; \
		done \
	fi )

	( if [ "$(LIB_$(1))" ]; then \
		$(INSTALL_DIR) $$(1)/usr/lib ; \
		for lib in $(LIB_$(1)); do \
			$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$$$$$lib.so* $$(1)/usr/lib/ ; \
		done \
	fi )

	( if [ "$(PLUGIN_$(1))" ]; then \
		$(INSTALL_DIR) $$(1)/usr/lib/gnunet ; \
		for plug in $(PLUGIN_$(1)); do \
			$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$$$$$plug*.so $$(1)/usr/lib/gnunet ; \
		done \
	fi )

	( if [ "$(LIBEXEC_$(1))" ]; then \
		$(INSTALL_DIR) $$(1)/usr/lib/gnunet/libexec ; \
		for lex in $(LIBEXEC_$(1)); do \
			$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$$$$$lex $$(1)/usr/lib/gnunet/libexec ; \
		done \
	fi )

	( if [ "$(CONF_$(1))" ]; then \
		$(INSTALL_DIR) $$(1)/usr/share/gnunet/config.d ; \
		for conf in $(CONF_$(1)); do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$$$$$conf.conf $$(1)/usr/share/gnunet/config.d ; \
		done \
	fi )
  endef

  $$(eval $$(call BuildPackage,gnunet-$(1)))
endef

define Package/gnunet/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet/config.d $(1)/usr/share/gnunet/hellos

	( for bin in arm ats core config ecc identity nat-server nse \
	    peerinfo peerstore revocation scalarproduct statistics transport uri; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$bin $(1)/usr/bin/ ; \
	done )

	( for lib in arm ats block cadet core datacache dht \
	    dns dnsparser dnsstub fragmentation friends hello identity nat nse \
	    peerinfo peerstore regexblock regex revocation scalarproduct set \
	    statistics transport util; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$lib.so* $(1)/usr/lib/ ; \
	done )

	( for plug in ats_proportional block_dht block_regex datacache_heap  \
	    transport_http_client transport_http_server \
	    transport_https_client transport_https_server \
	    transport_tcp transport_udp transport_unix transport_wlan; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$plug*.so $(1)/usr/lib/gnunet ; \
	done )

	( for lex in daemon-hostlist daemon-topology helper-nat-client \
	    helper-nat-server service-arm service-ats service-cadet \
	    service-core service-dht service-identity service-nse \
	    service-peerinfo service-peerstore service-regex \
	    service-revocation service-scalarproduct-alice \
	    service-scalarproduct-bob service-set service-statistics \
	    service-transport; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$lex $(1)/usr/lib/gnunet/libexec ; \
	done )

	( for conf in arm ats cadet core datacache dht hostlist identity \
	    nat nse peerinfo peerstore regex revocation scalarproduct \
	    set statistics topology transport util; do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$conf.conf $(1)/usr/share/gnunet/config.d ; \
	done )

	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/hellos/* $(1)/usr/share/gnunet/hellos
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/gnunet.init $(1)/etc/init.d/gnunet
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gnunet $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{la,so}* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gnunet/*.h $(1)/usr/include/gnunet
endef

DEPENDS_conversation:=+gnunet-gns +libgst1app +libgst1audio +libgstreamer1 +glib2 +pulseaudio-daemon +libopus +libogg
BIN_conversation:=conversation conversation-test
LIB_conversation:=conversation microphone speaker
PLUGIN_conversation:=gnsrecord_conversation
LIBEXEC_conversation:=helper-audio-playback helper-audio-record
CONF_conversation:=conversation

DEPENDS_experiments:=+libglpk
PLUGIN_experiments:=ats_mlp ats_ril

DEPENDS_fs:=+gnunet-storage +libextractor
BIN_fs:=auto-share directory download download-manager.scm fs publish unindex search
LIB_fs:=fs
PLUGIN_fs:=block_fs
LIB_EXEC_fs:=helper-fs-publish service-fs
CONF_fs:=fs

DEPENDS_gns:=+gnunet-vpn
USERID_gns:=gnunetdns=401:gnunetdns=401
BIN_gns:=gns gns-import.sh namecache namestore resolver
LIB_gns:=gns gnsrecord namecache namestore
PLUGIN_gns:=block_dns block_gns gnsrecord_dns gnsrecord_gns
LIBEXEC_gns:=dns2gns gns-proxy helper-dns namestore-fcfsd service-dns service-gns service-namecache service-namestore service-resolver
CONF_gns:=dns gns namecache namestore resolver

DEPENDS_storage:=+gnunet-gns +libsqlite3
BIN_storage:=datastore
LIB_storage:=datastore
PLUGIN_storage:=datacache_sqlite datastore_heap datastore_sqlite namecache_sqlite namestore_sqlite peerstore_sqlite
LIBEXEC_storage:=daemon-latency-logger service-datastore
CONF_storage:=datastore

DEPENDS_transport-bluetooth:=+bluez-libs
PLUGIN_transport-bluetooth:=transport_bluetooth
LIBEXEC_transport-bluetooth:=helper-transport-bluetooth

DEPENDS_utils:=+certtool +openssl-util
BIN_utils:=config gns-import.sh gns-proxy-setup-ca transport-certificate-creation

DEPENDS_vpn:=+kmod-tun
LIB_vpn:=tun vpn
LIBEXEC_vpn:=daemon-exit daemon-pt helper-exit helper-vpn service-vpn
CONF_vpn:=exit pt vpn

$(eval $(call BuildPackage,gnunet))
$(eval $(call BuildComponent,conversation,conversation component,))
$(eval $(call BuildComponent,experiments,experimental components,))
$(eval $(call BuildComponent,fs,file-sharing components,))
$(eval $(call BuildComponent,gns,name resolution components,y))
$(eval $(call BuildComponent,storage,storage components,))
$(eval $(call BuildComponent,transport-bluetooth,bluetooth transport,))
$(eval $(call BuildComponent,utils,administration utililties,))
$(eval $(call BuildComponent,vpn,vpn components,y))
