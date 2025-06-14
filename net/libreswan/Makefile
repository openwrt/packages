#
# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libreswan
PKG_VERSION:=4.12
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.libreswan.org/
PKG_HASH:=ae85abe415f7becf4b6a2b9897e1712f27e5aac9c35dfbdddbcce0ad7dfd99f7

PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING LICENSE
PKG_CPE_ID:=cpe:/a:libreswan:libreswan

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk

define Package/libreswan/default
  SUBMENU:=VPN
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Libreswan
  URL:=https://libreswan.org/
  PROVIDES:=openswan
  CONFLICTS:=strongswan
endef

define Package/libreswan
  $(Package/libreswan/default)
  DEPENDS:= \
	  +kmod-ip-vti +IPV6:kmod-ip6-vti \
	  +kmod-ipsec +kmod-ipsec4 +IPV6:kmod-ipsec6 \
	  +ip-full +kmod-xfrm-interface \
	  +libevent2 +libevent2-pthreads \
	  +libldns +librt +libunbound +nss-utils +nspr +libcap-ng \
	  +kmod-crypto-acompress \
	  +kmod-crypto-aead \
	  +kmod-crypto-authenc \
	  +kmod-crypto-arc4 \
	  +kmod-crypto-cbc \
	  +kmod-crypto-ccm \
	  +kmod-crypto-chacha20poly1305 \
	  +kmod-crypto-cmac \
	  +kmod-crypto-ctr \
	  +kmod-crypto-cts \
	  +kmod-crypto-des \
	  +kmod-crypto-ecb \
	  +kmod-crypto-ecdh \
	  +kmod-crypto-gcm \
	  +kmod-crypto-ghash \
	  +kmod-crypto-hash \
	  +kmod-crypto-hmac \
	  +kmod-crypto-md4 \
	  +kmod-crypto-md5 \
	  +kmod-crypto-null \
	  +kmod-crypto-pcbc \
	  +kmod-crypto-sha1 \
	  +kmod-crypto-sha256 \
	  +kmod-crypto-sha512 \
	  +kmod-crypto-xcbc \
	  +kmod-crypto-rng
endef

define Package/libreswan/description
	Libreswan is a free software implementation of the most widely supported and
	standardized VPN protocol based on ("IPsec") and the Internet Key Exchange
	("IKE"). These standards are produced and maintained by the Internet
	Engineering Task Force ("IETF").
endef

define Package/libreswan/conffiles
/etc/ipsec.d
/etc/config/libreswan
/etc/ipsec.user
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

MAKE_FLAGS+= \
    WERROR_CFLAGS=" " \
    NSS_REQ_AVA_COPY=false \
    USE_LINUX_AUDIT=false \
    USE_LABELED_IPSEC=false \
    USE_NM=false \
    USE_NSS_KDF=true \
    USE_LIBCURL=false \
    USE_GLIBC_KERN_FLIP_HEADERS=true \
    USE_AUTHPAM=false \
    USE_LIBCAP_NG=true \
    USE_SYSTEMD_WATCHDOG=false \
    USE_SECCOMP=false\
    USE_XFRM_INTERFACE_IFLA_HEADER=false \
    PREFIX="/usr" \
    FINALRUNDIR="/var/run/pluto" \
    FINALNSSDIR="/etc/ipsec.d" \
    DEFAULT_DNSSEC_ROOTKEY_FILE=/etc/unbound/root.key \
    MODPROBEARGS="-q" \
    OSDEP=linux \
    BUILDENV=linux \
    LINUX_VARIANT="openwrt" \
    ARCH="$(LINUX_KARCH)" \

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) 's,include $$$$(top_srcdir)/mk/manpages.mk,,g' \
            $(PKG_BUILD_DIR)/mk/program.mk
endef

define Build/Compile
	$(call Build/Compile/Default,all)
endef

define Package/libreswan/install
	$(INSTALL_DIR) \
	 $(1)/etc/ipsec.d/policies \
	 $(1)/usr/libexec/ipsec \
	 $(1)/usr/sbin \
	 $(1)/etc/config \
	 $(1)/etc/init.d \
	 $(1)/etc/hotplug.d/libreswan \
	 $(1)/etc/hotplug.d/iface \
	 $(1)/usr/libexec/rpcd \

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipsec  \
	    $(1)/usr/sbin/ipsec
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/ipsec.d/policies/* \
	     $(1)/etc/ipsec.d/policies/
	$(CP) $(PKG_INSTALL_DIR)/usr/libexec/ipsec/* \
	    $(1)/usr/libexec/ipsec/

	$(INSTALL_BIN) ./files/usr/libexec/ipsec/_updown.xfrm $(1)/usr/libexec/ipsec/_updown.xfrm
	$(INSTALL_BIN) ./files/etc/init.d/ipsec $(1)/etc/init.d/ipsec
	$(INSTALL_BIN) ./files/usr/libexec/rpcd/libreswan $(1)/usr/libexec/rpcd/libreswan
	$(INSTALL_DATA) ./files/etc/ipsec.conf $(1)/etc/ipsec.conf
	$(INSTALL_DATA) ./files/etc/ipsec.secrets $(1)/etc/ipsec.secrets
	$(INSTALL_DATA) ./files/etc/config/libreswan $(1)/etc/config/libreswan
	$(INSTALL_DATA) ./files/etc/hotplug.d/libreswan/01-user $(1)/etc/hotplug.d/libreswan/01-user
	$(INSTALL_DATA) ./files/etc/hotplug.d/libreswan/02-vti $(1)/etc/hotplug.d/libreswan/02-vti
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/89-libreswan $(1)/etc/hotplug.d/iface/89-libreswan
endef

define Package/libreswan-nftables
	$(Package/libreswan/default)
	TITLE+= nftables plugin)
	DEPENDS+=firewall4 +libreswan +kmod-nft-xfrm +nftables \
			 +kmod-nfnetlink-log
endef

define Package/libreswan-nftables/description
	Provides Libreswan nftables plugin for adding firewall rules
endef

define Package/libreswan-nftables/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/libreswan \
		$(1)/usr/share/nftables.d/ruleset-post

	$(CP) ./files/usr/share/nftables.d/* $(1)/usr/share/nftables.d
	$(CP) ./files/etc/hotplug.d/libreswan/62-nftables $(1)/etc/hotplug.d/libreswan/62-nftables
	$(LN) /tmp/libreswan/firewall.d/libreswan.rules $(1)/usr/share/nftables.d/ruleset-post/10_libreswan.nft
endef

define Package/libreswan-iptables
	$(Package/libreswan/default)
	TITLE+= iptables plugin)
	DEPENDS+=firewall +libreswan +iptables-mod-ipsec +kmod-ipt-ipsec \
			 +iptables-zz-legacy +IPV6:ip6tables-zz-legacy \
			 +kmod-ipt-nflog +iptables-mod-nflog
endef

define Package/libreswan-iptables/description
	Provides Libreswan iptables plugin for adding firewall rules
endef

define Package/libreswan-iptables/install
	$(INSTALL_DIR) $(1)/etc \
		$(1)/etc/uci-defaults \
		$(1)/etc/hotplug.d/libreswan

	$(CP) ./files/etc/hotplug.d/libreswan/61-iptables $(1)/etc/hotplug.d/libreswan/61-iptables
	$(CP) ./files/etc/uci-defaults/091-libreswan $(1)/etc/uci-defaults/091-libreswan
	$(INSTALL_BIN) ./files/etc/libreswan_firewall.sh $(1)/etc/libreswan_firewall.sh
endef

define Package/libreswan-iptables/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/firewall reload
}
endef

$(eval $(call BuildPackage,libreswan))
$(eval $(call BuildPackage,libreswan-nftables))
$(eval $(call BuildPackage,libreswan-iptables))
