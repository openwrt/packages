#
# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libreswan
PKG_VERSION:=3.27
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.libreswan.org/
PKG_HASH:=ead07dd701116094b483dc57e54e2a5ee9a06d3982bb142260bcbf3d1faf7b82

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libreswan/Default
  TITLE:=Libreswan
  URL:=https://libreswan.org/
endef

define Package/libreswan/Default/description
 Libreswan is a free software implementation of the most widely supported and
 standardized VPN protocol based on ("IPsec") and the Internet Key Exchange
 ("IKE"). These standards are produced and maintained by the Internet
 Engineering Task Force ("IETF").
endef

define Package/libreswan
$(call Package/libreswan/Default)
  SUBMENU:=VPN
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= +libnss +librt +libevent2 +libevent2-pthreads +kmod-crypto-authenc \
	+kmod-crypto-hash +kmod-ipt-ipsec +iptables-mod-ipsec +ip-full +kmod-ip-vti \
	+kmod-ipsec +kmod-ipsec4 +kmod-crypto-rng +IPV6:kmod-ipsec6 +IPV6:kmod-ip6-vti
  PROVIDES:=openswan
  CONFLICTS:=strongswan
  TITLE+= IPsec Server
endef

define Package/libreswan/description
$(call Package/libreswan/Default/description)
 Libreswan is a free software implementation of the most widely supported and
 standardized VPN protocol based on ("IPsec") and the Internet Key Exchange
 ("IKE"). These standards are produced and maintained by the Internet
 Engineering Task Force ("IETF").
endef

define Package/libreswan/conffiles
/etc/ipsec.d
/etc/ipsec.conf
/etc/ipsec.secrets
endef

TARGET_CFLAGS+= -Wno-error=format-nonliteral
MAKE_FLAGS+= \
    WERROR_CFLAGS=" " \
    USE_DNSSEC=false \
    USE_LINUX_AUDIT=false \
    USE_LABELED_IPSEC=false \
    USE_NM=false \
    USE_LIBCURL=false \
    USE_GLIBC_KERN_FLIP_HEADERS=true \
    USE_XAUTHPAM=false \
    USE_FIPSCHECK=false \
    USE_LIBCAP_NG=false \
    USE_SYSTEMD_WATCHDOG=false \
    INC_USRLOCAL="/usr" \
    FINALRUNDIR="/var/run/pluto" \
    ARCH="$(LINUX_KARCH)" \
    KERNELSRC="$(LINUX_DIR)"

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
	 $(1)/etc/init.d \
	 $(1)/etc/ipsec.d/policies \
	 $(1)/usr/libexec/ipsec \
	 $(1)/usr/sbin

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipsec  \
	    $(1)/usr/sbin/ipsec
	$(INSTALL_BIN) ./files/ipsec.init $(1)/etc/init.d/ipsec
	$(INSTALL_DATA) ./files/ipsec.conf $(1)/etc/ipsec.conf
	$(INSTALL_DATA) ./files/ipsec.secrets $(1)/etc/ipsec.secrets
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/ipsec.d/policies/* \
	     $(1)/etc/ipsec.d/policies/
	$(CP) $(PKG_INSTALL_DIR)/usr/libexec/ipsec/* \
	    $(1)/usr/libexec/ipsec/
endef

$(eval $(call BuildPackage,libreswan))
