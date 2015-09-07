#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=strongswan
PKG_VERSION:=5.3.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://download.strongswan.org/ http://download2.strongswan.org/
PKG_MD5SUM:=5a25f3d1c31a77ef44d14a2e7b3eaad0
PKG_LICENSE:=GPL-2.0+
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>

PKG_MOD_AVAILABLE:= \
	addrblock \
	aes \
	af-alg \
	agent \
	attr \
	attr-sql \
	blowfish \
	ccm \
	cmac \
	constraints \
	coupling \
	ctr \
	curl \
	des \
	dhcp \
	dnskey \
	duplicheck \
	eap-identity \
	eap-md5 \
	eap-mschapv2 \
	eap-radius \
	eap-tls \
	farp \
	fips-prf \
	gcm \
	gcrypt \
	gmp \
	ha \
	hmac \
	kernel-libipsec \
	kernel-netlink \
	ldap \
	led \
	load-tester \
	nonce \
	md4 \
	md5 \
	mysql \
	openssl \
	pem \
	pgp \
	pkcs1 \
	pkcs7 \
	pkcs8 \
	pkcs11 \
	pkcs12 \
	pubkey \
	random \
	rc2 \
	resolve \
	revocation \
	sha1 \
	sha2 \
	smp \
	socket-default \
	socket-dynamic \
	sql \
	sqlite \
	sshkey \
	stroke \
	test-vectors \
	unity \
	uci \
	updown \
	whitelist \
	x509 \
	xauth-eap \
	xauth-generic \
	xcbc

PKG_CONFIG_DEPENDS:= \
	CONFIG_STRONGSWAN_ROUTING_TABLE \
	CONFIG_STRONGSWAN_ROUTING_TABLE_PRIO \
	$(patsubst %,CONFIG_PACKAGE_strongswan-mod-%,$(PKG_MOD_AVAILABLE)) \

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/strongswan/Default
  SUBMENU:=VPN
  SECTION:=net
  CATEGORY:=Network
  TITLE:=StrongSwan
  URL:=http://www.strongswan.org/
endef

define Package/strongswan/description/Default
 StrongSwan is an OpenSource IPsec implementation for the Linux operating system.
endef

define Package/strongswan
$(call Package/strongswan/Default)
  DEPENDS:= +libpthread +ip \
	+kmod-crypto-authenc \
	+kmod-ipsec +kmod-ipsec4 +IPV6:kmod-ipsec6 \
	+kmod-ipt-ipsec +iptables-mod-ipsec
endef

define Package/strongswan/config
  source "$(SOURCE)/Config.in"
endef

define Package/strongswan/description
$(call Package/strongswan/description/Default)
 This package contains shared libraries and scripts.
endef

define Package/strongswan-full
$(call Package/strongswan/Default)
  TITLE+= (full)
  DEPENDS:= +strongswan \
	+strongswan-charon \
	+strongswan-mod-addrblock \
	+strongswan-mod-aes \
	+strongswan-mod-af-alg \
	+strongswan-mod-agent \
	+strongswan-mod-attr \
	+strongswan-mod-attr-sql \
	+strongswan-mod-blowfish \
	+strongswan-mod-ccm \
	+strongswan-mod-cmac \
	+strongswan-mod-constraints \
	+strongswan-mod-coupling \
	+strongswan-mod-ctr \
	+strongswan-mod-curl \
	+strongswan-mod-des \
	+strongswan-mod-dhcp \
	+strongswan-mod-dnskey \
	+strongswan-mod-duplicheck \
	+strongswan-mod-eap-identity \
	+strongswan-mod-eap-md5 \
	+strongswan-mod-eap-mschapv2 \
	+strongswan-mod-eap-radius \
	+strongswan-mod-eap-tls \
	+strongswan-mod-farp \
	+strongswan-mod-fips-prf \
	+strongswan-mod-gcm \
	+strongswan-mod-gcrypt \
	+strongswan-mod-gmp \
	+strongswan-mod-ha \
	+strongswan-mod-hmac \
	+strongswan-mod-kernel-netlink \
	+strongswan-mod-ldap \
	+strongswan-mod-led \
	+strongswan-mod-load-tester \
	+strongswan-mod-nonce \
	+strongswan-mod-md4 \
	+strongswan-mod-md5 \
	+strongswan-mod-mysql \
	+strongswan-mod-openssl \
	+strongswan-mod-pem \
	+strongswan-mod-pgp \
	+strongswan-mod-pkcs1 \
	+strongswan-mod-pkcs7 \
	+strongswan-mod-pkcs8 \
	+strongswan-mod-pkcs11 \
	+strongswan-mod-pkcs12 \
	+strongswan-mod-pubkey \
	+strongswan-mod-random \
	+strongswan-mod-rc2 \
	+strongswan-mod-resolve \
	+strongswan-mod-revocation \
	+strongswan-mod-sha1 \
	+strongswan-mod-sha2 \
	+strongswan-mod-smp \
	+strongswan-mod-socket-default \
	+strongswan-mod-sql \
	+strongswan-mod-sqlite \
	+strongswan-mod-sshkey \
	+strongswan-mod-stroke \
	+strongswan-mod-test-vectors \
	+strongswan-mod-uci \
	+strongswan-mod-unity \
	+strongswan-mod-updown \
	+strongswan-mod-whitelist \
	+strongswan-mod-x509 \
	+strongswan-mod-xauth-eap \
	+strongswan-mod-xauth-generic \
	+strongswan-mod-xcbc \
	+strongswan-utils \
	@DEVEL
endef

define Package/strongswan-full/description
$(call Package/strongswan/description/Default)
 This meta-package contains dependencies for all of the strongswan plugins
 except kernel-libipsec,
 socket-dynamic and which are ommitted in favor of the kernel-netlink and
 socket-default plugins.
endef


define Package/strongswan-default
$(call Package/strongswan/Default)
  TITLE+= (default)
  DEPENDS:= +strongswan \
	+strongswan-charon \
	+strongswan-mod-aes \
	+strongswan-mod-attr \
	+strongswan-mod-constraints \
	+strongswan-mod-des \
	+strongswan-mod-dnskey \
	+strongswan-mod-fips-prf \
	+strongswan-mod-gmp \
	+strongswan-mod-hmac \
	+strongswan-mod-kernel-netlink \
	+strongswan-mod-md5 \
	+strongswan-mod-nonce \
	+strongswan-mod-pem \
	+strongswan-mod-pgp \
	+strongswan-mod-pkcs1 \
	+strongswan-mod-pubkey \
	+strongswan-mod-random \
	+strongswan-mod-rc2 \
	+strongswan-mod-resolve \
	+strongswan-mod-revocation \
	+strongswan-mod-sha1 \
	+strongswan-mod-sha2 \
	+strongswan-mod-socket-default \
	+strongswan-mod-sshkey \
	+strongswan-mod-stroke \
	+strongswan-mod-updown \
	+strongswan-mod-x509 \
	+strongswan-mod-xauth-generic \
	+strongswan-mod-xcbc \
	+strongswan-utils
endef

define Package/strongswan-default/description
$(call Package/strongswan/description/Default)
 This meta-package contains only dependencies to match upstream defaults.
endef

define Package/strongswan-minimal
$(call Package/strongswan/Default)
  TITLE+= (minimal)
  DEPENDS:= +strongswan \
	+strongswan-charon \
	+strongswan-mod-aes \
	+strongswan-mod-gmp \
	+strongswan-mod-hmac \
	+strongswan-mod-kernel-netlink \
	+strongswan-mod-nonce \
	+strongswan-mod-pubkey \
	+strongswan-mod-random \
	+strongswan-mod-sha1 \
	+strongswan-mod-socket-default \
	+strongswan-mod-stroke \
	+strongswan-mod-updown \
	+strongswan-mod-x509 \
	+strongswan-mod-xcbc
endef

define Package/strongswan-minimal/description
$(call Package/strongswan/description/Default)
 This meta-package contains only dependencies for a minimal IKEv2 setup.
endef

define Package/strongswan-charon
$(call Package/strongswan/Default)
  TITLE+= IKEv1/IKEv2 keying daemon
  DEPENDS:= +strongswan
endef

define Package/strongswan-charon/description
$(call Package/strongswan/description/Default)
 This package contains charon, an IKEv2 keying daemon.
endef

define Package/strongswan-utils
$(call Package/strongswan/Default)
  TITLE+= utilities
  DEPENDS:= +strongswan
endef

define Package/strongswan-utils/description
$(call Package/strongswan/description/Default)
 This package contains the pki & scepclient utilities.
endef

define Package/strongswan-libtls
$(call Package/strongswan/Default)
  TITLE+= libtls
  DEPENDS:= +strongswan
endef

define Package/strongswan-libtls/description
$(call Package/strongswan/description/Default)
 This package contains libtls for strongSwan plugins eap-tls, eap-ttls,
 eap-peap, tnc-tnccs
endef

define BuildPlugin
  define Package/strongswan-mod-$(1)
    $$(call Package/strongswan/Default)
    TITLE:= StrongSwan $(2) plugin
    DEPENDS:= +strongswan $(3)
  endef

  define Package/strongswan-mod-$(1)/install
	$(INSTALL_DIR) $$(1)/etc/strongswan.d/charon
	if [ -f $(PKG_INSTALL_DIR)/etc/strongswan.d/charon/$(1).conf ]; then \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/strongswan.d/charon/$(1).conf $$(1)/etc/strongswan.d/charon/; fi
	$(INSTALL_DIR) $$(1)/usr/lib/ipsec/plugins
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/plugins/libstrongswan-$(1).so \
		$$(1)/usr/lib/ipsec/plugins/
	$(call Plugin/$(1)/install,$$(1))
  endef

  $$(eval $$(call BuildPackage,strongswan-mod-$(1)))
endef

CONFIGURE_ARGS+= \
	--disable-scripts \
	--disable-static \
	--disable-fast \
	--with-systemdsystemunitdir=no \
	$(if $(CONFIG_PACKAGE_strongswan-utils),--enable-pki --enable-scepclient,--disable-pki --disable-scepclient) \
	--with-random-device=/dev/random \
	--with-urandom-device=/dev/urandom \
	--with-routing-table="$(call qstrip,$(CONFIG_STRONGSWAN_ROUTING_TABLE))" \
	--with-routing-table-prio="$(call qstrip,$(CONFIG_STRONGSWAN_ROUTING_TABLE_PRIO))" \
	$(foreach m,$(PKG_MOD_AVAILABLE), \
	  $(if $(CONFIG_PACKAGE_strongswan-mod-$(m)),--enable-$(m),--disable-$(m)) \
	)

EXTRA_LDFLAGS+= -Wl,-rpath-link,$(STAGING_DIR)/usr/lib

define Package/strongswan/conffiles
/etc/ipsec.conf
/etc/ipsec.secrets
/etc/ipsec.user
/etc/strongswan.conf
endef

define Package/strongswan/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/ipsec.conf $(1)/etc/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/strongswan.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/lib/ipsec
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/{libstrongswan.so.*,libhydra.so.*} $(1)/usr/lib/ipsec/
	$(INSTALL_CONF) ./files/ipsec.secrets $(1)/etc/
	$(INSTALL_CONF) ./files/ipsec.user $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ipsec.init $(1)/etc/init.d/ipsec
endef

define Package/strongswan-default/install
	true
endef

define Package/strongswan-full/install
	true
endef

define Package/strongswan-minimal/install
	true
endef

define Package/strongswan-charon/install
	$(INSTALL_DIR) $(1)/usr/lib/ipsec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/ipsec/charon $(1)/usr/lib/ipsec/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/libcharon.so.* $(1)/usr/lib/ipsec/
endef

define Package/strongswan-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipsec $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pki $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ipsec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/ipsec/scepclient $(1)/usr/lib/ipsec/
endef

define Package/strongswan-libtls/install
	$(INSTALL_DIR) $(1)/usr/lib/ipsec
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/libtls.so.* $(1)/usr/lib/ipsec/
endef

define Plugin/duplicheck/install
	$(INSTALL_DIR) $(1)/usr/lib/ipsec/plugins
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/duplicheck $(1)/usr/lib/ipsec/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/plugins/libstrongswan-duplicheck.so $(1)/usr/lib/ipsec/plugins/
endef

define Plugin/eap-radius/install
	$(INSTALL_DIR) $(1)/usr/lib/ipsec/plugins
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/libradius.so.* $(1)/usr/lib/ipsec/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/plugins/libstrongswan-eap-radius.so $(1)/usr/lib/ipsec/plugins/
endef

define Plugin/attr-sql/install
	$(INSTALL_DIR) $(1)/usr/lib/ipsec
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/pool $(1)/usr/lib/ipsec/
endef

define Plugin/stroke/install
	$(INSTALL_DIR) $(1)/etc/ipsec.d/aacerts
	$(INSTALL_DIR) $(1)/etc/ipsec.d/acerts
	$(INSTALL_DIR) $(1)/etc/ipsec.d/cacerts
	$(INSTALL_DIR) $(1)/etc/ipsec.d/certs
	$(INSTALL_DIR) $(1)/etc/ipsec.d/crls
	$(INSTALL_DIR) $(1)/etc/ipsec.d/ocspcerts
	$(INSTALL_DIR) $(1)/etc/ipsec.d/private
	$(INSTALL_DIR) $(1)/etc/ipsec.d/reqs

	$(INSTALL_DIR) $(1)/usr/lib/ipsec/plugins
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/ipsec/{starter,stroke} $(1)/usr/lib/ipsec/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/plugins/libstrongswan-stroke.so $(1)/usr/lib/ipsec/plugins/
endef

define Plugin/updown/install
	$(INSTALL_DIR) $(1)/usr/lib/ipsec/plugins
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/_updown $(1)/usr/lib/ipsec/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/plugins/libstrongswan-updown.so $(1)/usr/lib/ipsec/plugins/
	$(INSTALL_DIR) $(1)/etc
endef

define Plugin/whitelist/install
	$(INSTALL_DIR) $(1)/usr/lib/ipsec/plugins
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/whitelist $(1)/usr/lib/ipsec/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/plugins/libstrongswan-whitelist.so $(1)/usr/lib/ipsec/plugins/
endef

define Plugin/kernel-libipsec/install
	$(INSTALL_DIR) $(1)/usr/lib/ipsec
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ipsec/libipsec.so.* $(1)/usr/lib/ipsec/
endef

$(eval $(call BuildPackage,strongswan))
$(eval $(call BuildPackage,strongswan-default))
$(eval $(call BuildPackage,strongswan-full))
$(eval $(call BuildPackage,strongswan-minimal))
$(eval $(call BuildPackage,strongswan-charon))
$(eval $(call BuildPackage,strongswan-utils))
$(eval $(call BuildPackage,strongswan-libtls))
$(eval $(call BuildPlugin,addrblock,RFC 3779 address block constraint support,))
$(eval $(call BuildPlugin,aes,AES crypto,))
$(eval $(call BuildPlugin,af-alg,AF_ALG crypto interface to Linux Crypto API,+kmod-crypto-user))
$(eval $(call BuildPlugin,agent,SSH agent signing,))
$(eval $(call BuildPlugin,attr,file based config,))
$(eval $(call BuildPlugin,attr-sql,SQL based config,+strongswan-charon))
$(eval $(call BuildPlugin,blowfish,Blowfish crypto,))
$(eval $(call BuildPlugin,ccm,CCM AEAD wrapper crypto,))
$(eval $(call BuildPlugin,cmac,CMAC crypto,))
$(eval $(call BuildPlugin,constraints,advanced X509 constraint checking,))
$(eval $(call BuildPlugin,coupling,IKEv2 plugin to couple peer certificates permanently to authentication,))
$(eval $(call BuildPlugin,ctr,Counter Mode wrapper crypto,))
$(eval $(call BuildPlugin,curl,cURL fetcher plugin,+PACKAGE_strongswan-mod-curl:libcurl))
$(eval $(call BuildPlugin,des,DES crypto,))
$(eval $(call BuildPlugin,dhcp,DHCP based attribute provider,))
$(eval $(call BuildPlugin,dnskey,DNS RR key decoding,))
$(eval $(call BuildPlugin,duplicheck,advanced duplicate checking,))
$(eval $(call BuildPlugin,eap-identity,EAP identity helper,))
$(eval $(call BuildPlugin,eap-md5,EAP MD5 (CHAP) EAP auth,))
$(eval $(call BuildPlugin,eap-mschapv2,EAP MS-CHAPv2 EAP auth,+strongswan-mod-md4 +strongswan-mod-des))
$(eval $(call BuildPlugin,eap-radius,EAP RADIUS auth,))
$(eval $(call BuildPlugin,eap-tls,EAP TLS auth,+strongswan-libtls))
$(eval $(call BuildPlugin,farp,fake arp respsonses,))
$(eval $(call BuildPlugin,fips-prf,FIPS PRF crypto,+strongswan-mod-sha1))
$(eval $(call BuildPlugin,gcm,GCM AEAD wrapper crypto,))
$(eval $(call BuildPlugin,gcrypt,libgcrypt,+PACKAGE_strongswan-mod-gcrypt:libgcrypt))
$(eval $(call BuildPlugin,gmp,libgmp,+PACKAGE_strongswan-mod-gmp:libgmp))
$(eval $(call BuildPlugin,ha,high availability cluster,))
$(eval $(call BuildPlugin,hmac,HMAC crypto,))
$(eval $(call BuildPlugin,kernel-libipsec,libipsec kernel interface,))
$(eval $(call BuildPlugin,kernel-netlink,netlink kernel interface,))
$(eval $(call BuildPlugin,ldap,LDAP,+PACKAGE_strongswan-mod-ldap:libopenldap))
$(eval $(call BuildPlugin,led,LED blink on IKE activity,))
$(eval $(call BuildPlugin,load-tester,load testing,))
$(eval $(call BuildPlugin,nonce,nonce genereation,))
$(eval $(call BuildPlugin,md4,MD4 crypto,))
$(eval $(call BuildPlugin,md5,MD5 crypto,))
$(eval $(call BuildPlugin,mysql,MySQL database interface,+strongswan-mod-sql +PACKAGE_strongswan-mod-mysql:libmysqlclient-r))
$(eval $(call BuildPlugin,openssl,OpenSSL crypto,+PACKAGE_strongswan-mod-openssl:libopenssl))
$(eval $(call BuildPlugin,pem,PEM decoding,))
$(eval $(call BuildPlugin,pgp,PGP key decoding,))
$(eval $(call BuildPlugin,pkcs1,PKCS1 key decoding,))
$(eval $(call BuildPlugin,pkcs7,PKCS7 key decoding,))
$(eval $(call BuildPlugin,pkcs8,PKCS8 key decoding,))
$(eval $(call BuildPlugin,pkcs11,PKCS11 key decoding,))
$(eval $(call BuildPlugin,pkcs12,PKCS12 key decoding,))
$(eval $(call BuildPlugin,pubkey,raw public key,))
$(eval $(call BuildPlugin,random,RNG,))
$(eval $(call BuildPlugin,rc2,RC2 crypto,))
$(eval $(call BuildPlugin,resolve,DNS resolver,))
$(eval $(call BuildPlugin,revocation,X509 CRL/OCSP revocation,))
$(eval $(call BuildPlugin,sha1,SHA1 crypto,))
$(eval $(call BuildPlugin,sha2,SHA2 crypto,))
$(eval $(call BuildPlugin,smp,SMP configuration and control interface,+PACKAGE_strongswan-mod-smp:libxml2))
$(eval $(call BuildPlugin,socket-default,default socket implementation for charon,))
$(eval $(call BuildPlugin,socket-dynamic,dynamic socket implementation for charon,))
$(eval $(call BuildPlugin,sql,SQL database interface,))
$(eval $(call BuildPlugin,sqlite,SQLite database interface,+strongswan-mod-sql +PACKAGE_strongswan-mod-sqlite:libsqlite3))
$(eval $(call BuildPlugin,sshkey,SSH key decoding,))
$(eval $(call BuildPlugin,stroke,Stroke,+strongswan-utils))
$(eval $(call BuildPlugin,test-vectors,crypto test vectors,))
$(eval $(call BuildPlugin,uci,UCI config interface,+PACKAGE_strongswan-mod-uci:libuci))
$(eval $(call BuildPlugin,unity,Cisco Unity extension,))
$(eval $(call BuildPlugin,updown,updown firewall,))
$(eval $(call BuildPlugin,whitelist,peer identity whitelisting,))
$(eval $(call BuildPlugin,x509,x509 certificate,))
$(eval $(call BuildPlugin,xauth-eap,EAP XAuth backend,))
$(eval $(call BuildPlugin,xauth-generic,generic XAuth backend,))
$(eval $(call BuildPlugin,xcbc,xcbc crypto,))
