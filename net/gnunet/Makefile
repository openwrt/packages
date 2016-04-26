#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnunet
PKG_SOURCE_VERSION:=37051
PKG_VERSION:=0.10.1-svn$(PKG_SOURCE_VERSION)
PKG_RELEASE:=2

# ToDo:
#  - break-out {peer,name,data}store for each backend
#  - package testing stuff

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://gnunet.org/svn/gnunet/
PKG_SOURCE_PROTO:=svn

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=gettext-version
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

CONFIGURE_ARGS+= \
	--with-libiconv-prefix="$(ICONV_PREFIX)" \
	--with-libintl-prefix="$(INTL_PREFIX)" \
	--with-ltdl \
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-mysql),--with-mysql="$(STAGING_DIR)/usr",--without-mysql) \
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-pgsql),--with-postgresql="$(STAGING_DIR)/usr/bin/pg_config",--without-postgresql) \
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-sqlite),--with-sqlite="$(STAGING_DIR)/usr",--without-sqlite) \
	--enable-experimental \
	--with-extractor=$(STAGING_DIR)/usr \
	--with-gnutls=$(STAGING_DIR)/usr \
	--with-libgnurl=$(STAGING_DIR)/usr \
	--with-libunistring-prefix=$(STAGING_DIR)/usr \
	--with-microhttpd=$(STAGING_DIR)/usr

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
           +libmicrohttpd +libunistring +librt $(ICONV_DEPENDS) $(INTL_DEPENDS)
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
 CADET routing engine, a DHT implementation and basic transports as
 well as their helpers.
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

	( for bin in arm ats cadet core config ecc identity nat nat-server nse \
	    peerinfo revocation scalarproduct statistics transport uri; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-$$$$bin $(1)/usr/bin/ ; \
	done )

	( for lib in arm ats block cadet core datacache dht \
	    dns dnsparser dnsstub fragmentation friends hello identity nat nse \
	    peerinfo regexblock regex revocation scalarproduct set \
	    statistics transport util; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnunet$$$$lib.so* $(1)/usr/lib/ ; \
	done )

	( for plug in ats_proportional block_dht block_regex datacache_heap  \
	    transport_tcp transport_udp transport_unix; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_$$$$plug*.so $(1)/usr/lib/gnunet ; \
	done )

	( for lex in daemon-hostlist daemon-topology helper-nat-client \
	    helper-nat-server service-arm service-ats service-cadet \
	    service-core service-dht service-identity service-nse \
	    service-peerinfo service-regex \
	    service-revocation service-scalarproduct-alice \
	    service-scalarproduct-bob service-scalarproduct-ecc-alice \
	    service-scalarproduct-ecc-bob service-set service-statistics \
	    service-transport; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/gnunet-$$$$lex $(1)/usr/lib/gnunet/libexec ; \
	done )

	( for conf in arm ats cadet core datacache dht hostlist identity \
	    nat nse peerinfo regex revocation scalarproduct \
	    set statistics topology transport util; do \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/$$$$conf.conf $(1)/usr/share/gnunet/config.d ; \
	done )

	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/hellos/* $(1)/usr/share/gnunet/hellos
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/gnunet.init $(1)/etc/init.d/gnunet
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/gnunet.upgrade $(1)/lib/upgrade/keep.d/gnunet
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/gnunet.defaults $(1)/etc/uci-defaults/gnunet
	$(INSTALL_BIN) ./files/gnunet-dns.fw $(1)/usr/lib/gnunet/libexec/gnunet-dns.fw
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/gnunet-proto.sh $(1)/lib/netifd/proto
endef

define Package/gnunet/conffiles
/etc/config/gnunet
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
LIBEXEC_conversation:=helper-audio-playback helper-audio-record service-conversation
CONF_conversation:=conversation

DEPENDS_transport-http_client:=+libgnurl
PLUGIN_transport-http_client:=transport_http_client transport_https_client

DEPENDS_transport-http_server:=+libmicrohttpd
PLUGIN_transport-http_server:=transport_http_server transport_https_server

PLUGIN_transport-wlan:=transport_wlan
LIBEXEC_transport-wlan:=helper-transport-wlan

DEPENDS_experiments:=+libglpk
PLUGIN_experiments:=ats_mlp ats_ril
LIBEXEC_experiments:=service-dht-whanau service-dht-xvine

# BIN_dv:=dv
LIB_dv:=dv
PLUGIN_dv:=transport_dv
LIBEXEC_dv:=service-dv
CONF_dv:=dv

DEPENDS_fs:=+gnunet-datastore +gnunet-peerstore +libextractor
BIN_fs:=auto-share directory download download-manager.scm fs publish unindex search
LIB_fs:=fs
PLUGIN_fs:=block_fs
LIBEXEC_fs:=helper-fs-publish service-fs
CONF_fs:=fs

DEPENDS_gns:=+gnunet-vpn +iptables-mod-extra
USERID_gns:=gnunet=400:gnunetdns=401
BIN_gns:=gns gns-import.sh namecache namestore resolver
LIB_gns:=gns gnsrecord namecache namestore
PLUGIN_gns:=block_dns block_gns gnsrecord_dns gnsrecord_gns
LIBEXEC_gns:=dns2gns gns-proxy helper-dns namestore-fcfsd service-dns service-gns service-namecache service-namestore service-resolver
CONF_gns:=dns gns namecache namestore resolver

DEPENDS_datastore:=+gnunet-gns +libsqlite3
BIN_datastore:=datastore
LIB_datastore:=datastore
PLUGIN_datastore:=datastore_heap
LIBEXEC_datastore:=daemon-latency-logger service-datastore
CONF_datastore:=datastore

BIN_peerstore:=peerstore
LIB_peerstore:=peerstore
LIBEXEC_peerstore:=service-peerstore
CONF_peerstore:=peerstore

DEPENDS_flat:=+gnunet-gns
PLUGIN_flat:=namecache_flat namestore_flat

DEPENDS_mysql:=+gnunet-gns +gnunet-datastore +libmysqlclient
LIB_mysql:=mysql
PLUGIN_mysql:=datastore_mysql

DEPENDS_pgsql:=+gnunet-gns +gnunet-datastore +libpq
LIB_pgsql:=postgres pq
PLUGIN_pgsql:=datacache_postgres datastore_postgres namecache_postgres namestore_postgres

DEPENDS_rest:=+gnunet-gns +gnunet-social +jansson
LIB_rest:=rest
PLUGIN_rest:=rest_gns rest_identity rest_identity_provider rest_namestore
LIBEXEC_rest:=rest-server
CONF_rest:=rest

BIN_rps:=rps
LIB_rps:=rps
LIBEXEC_rps:=service-rps
CONF_rps:=rps

DEPENDS_social:=+gnunet-sqlite +jansson
BIN_social:=identity-token multicast
LIB_social:=consensus identityprovider multicast psyc psycstore psycutil secretsharing social
PLUGIN_social:=psycstore_sqlite
LIBEXEC_social:=service-consensus service-evil-consensus service-identity-provider service-multicast service-psyc service-psycstore service-secretsharing service-social
CONF_social:=consensus multicast psyc psycstore secretsharing social

DEPENDS_sqlite:=+gnunet-gns +gnunet-datastore +gnunet-peerstore +libsqlite3
PLUGIN_sqlite:=datacache_sqlite datastore_sqlite namecache_sqlite namestore_sqlite peerstore_sqlite

DEPENDS_transport-bluetooth:=+bluez-libs
PLUGIN_transport-bluetooth:=transport_bluetooth
LIBEXEC_transport-bluetooth:=helper-transport-bluetooth

DEPENDS_utils:=+certtool +openssl-util
BIN_utils:=gns-proxy-setup-ca transport-certificate-creation scrypt

DEPENDS_vpn:=+kmod-tun +iptables
BIN_vpn:=vpn
LIB_vpn:=tun vpn
LIBEXEC_vpn:=daemon-exit daemon-pt helper-exit helper-vpn service-vpn
CONF_vpn:=exit pt vpn

define PostInstFixSUIDPerms
  define Package/$(1)/postinst
  #!/bin/sh
  [ -e /usr/share/gnunet/.permfix ] && rm /usr/share/gnunet/.permfix
  endef
endef

define Package/gnunet-gns/postinst
#!/bin/sh

[ -e /usr/share/gnunet/.permfix ] && rm /usr/share/gnunet/.permfix

uci -q batch <<EOF
del network.gnunetdns
set network.gnunetdns=interface
set network.gnunetdns.ifname='gnunet-dns'
set network.gnunetdns.proto='gnunet'

del network.gndnsrtt
set network.gndnsrtt=route
set network.gndnsrtt.interface='gnunetdns'
set network.gndnsrtt.table='53'
set network.gndnsrtt.target='0.0.0.0/0'

del network.gndnsrl
set network.gndnsrl=rule
set network.gndnsrl.mark='0x8260035'
set network.gndnsrl.lookup='53'

commit network

del firewall.gnunetdns
set firewall.gnunetdns=zone
set firewall.gnunetdns.name='gnunetdns'
set firewall.gnunetdns.network='gnunetdns'
set firewall.gnunetdns.input='ACCEPT'
set firewall.gnunetdns.output='ACCEPT'
set firewall.gnunetdns.forward='ACCEPT'

del firewall.gndnsinc
set firewall.gndnsinc=include
set firewall.gndnsinc.path='/usr/lib/gnunet/libexec/gnunet-dns.fw'

commit firewall
EOF

endef

define Package/gnunet-gns/prerm
#!/bin/sh

uci -q batch <<EOF
del network.gnunetdns
del network.gndnsrtt
del network.gndnsrl
commit network

del firewall.gnunetdns
del firewall.gndnsinc
commit firewall
EOF

endef


define Package/gnunet-vpn/postinst
#!/bin/sh

[ -e /usr/share/gnunet/.permfix ] && rm /usr/share/gnunet/.permfix

uci -q batch <<EOF
del network.gnunetvpn
set network.gnunetvpn=interface
set network.gnunetvpn.ifname='vpn-gnunet'
set network.gnunetvpn.proto='gnunet'

del network.gnunetexit
set network.gnunetexit=interface
set network.gnunetexit.ifname='exit-gnunet'
set network.gnunetexit.proto='gnunet'

commit network

del firewall.gnunetvpn
set firewall.gnunetvpn=zone
set firewall.gnunetvpn.name='gnunetvpn'
set firewall.gnunetvpn.network='gnunetvpn'
set firewall.gnunetvpn.input='ACCEPT'
set firewall.gnunetvpn.output='ACCEPT'
set firewall.gnunetvpn.forward='REJECT'

del firewall.gnunetexit
set firewall.gnunetexit=zone
set firewall.gnunetexit.name='gnunetexit'
set firewall.gnunetexit.network='gnunetexit'
set firewall.gnunetexit.input='ACCEPT'
set firewall.gnunetexit.output='ACCEPT'
set firewall.gnunetexit.forward='REJECT'

del firewall.gnexitfwd
set firewall.gnexitfwd=forwarding
set firewall.gnexitfwd.src='gnunetexit'
set firewall.gnexitfwd.dest='wan'

commit firewall
EOF

endef

define Package/gnunet-vpn/prerm
#!/bin/sh

uci -q batch <<EOF
del network.gnunetvpn
del network.gnunetexit
del firewall.gnunetvpn
del firewall.gnunetexit
del firewall.gnexitfwd
EOF

endef

$(eval $(call BuildPackage,gnunet))
$(eval $(call PostInstFixSUIDPerms,gnunet))
$(eval $(call BuildComponent,conversation,conversation component,))
$(eval $(call BuildComponent,datastore,data storage components,))
$(eval $(call BuildComponent,dv,distance-vector routing component,))
$(eval $(call BuildComponent,experiments,experimental components,))
$(eval $(call BuildComponent,flat,flat storage backends,))
$(eval $(call BuildComponent,fs,file-sharing components,))
$(eval $(call BuildComponent,gns,name resolution components,y))
$(eval $(call BuildComponent,mysql,mySQL datastore backend,))
$(eval $(call BuildComponent,pgsql,PostgreSQL storage backends,))
$(eval $(call BuildComponent,peerstore,peerstore local persistency component,))
$(eval $(call BuildComponent,rest,REST interface,))
$(eval $(call BuildComponent,rps,RPS routing component,))
$(eval $(call BuildComponent,social,social components,))
$(eval $(call BuildComponent,sqlite,libsqlite3 storage backends,y))
$(eval $(call BuildComponent,transport-bluetooth,bluetooth transport,))
$(eval $(call PostInstFixSUIDPerms,gnunet-transport-bluetooth))
$(eval $(call BuildComponent,transport-http_client,HTTP/HTTPS client transport,y))
$(eval $(call BuildComponent,transport-http_server,HTTP/HTTPS server transport,))
$(eval $(call BuildComponent,transport-wlan,WLAN transport,))
$(eval $(call PostInstFixSUIDPerms,gnunet-transport-wlan))
$(eval $(call BuildComponent,utils,administration utililties,))
$(eval $(call BuildComponent,vpn,vpn components,y))
