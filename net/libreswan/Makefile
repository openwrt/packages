#
# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libreswan
PKG_VERSION:=3.29
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.libreswan.org/
PKG_HASH:=d60e4160f43272b6307b697a13f79f56b5ec2bca61d83097ddadd8586a58ab3e

PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING LICENSE
PKG_CPE_ID:=cpe:/a:libreswan:libreswan

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
  DEPENDS:= +IPV6:kmod-ip6-vti +IPV6:kmod-ipsec6 +ip-full +iptables-mod-ipsec \
	+kmod-crypto-aead +kmod-crypto-authenc +kmod-crypto-gcm \
	+kmod-crypto-hash +kmod-crypto-rng +kmod-ip-vti +kmod-ipsec \
	+kmod-ipsec4 +kmod-ipt-ipsec +libevent2 +libevent2-pthreads \
	+libldns +librt +libunbound-heavy +nss-utils +nspr
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

MAKE_FLAGS+= \
    WERROR_CFLAGS=" " \
    USE_LINUX_AUDIT=false \
    USE_LABELED_IPSEC=false \
    USE_NM=false \
    USE_LIBCURL=false \
    USE_GLIBC_KERN_FLIP_HEADERS=true \
    USE_XAUTHPAM=false \
    USE_FIPSCHECK=false \
    USE_LIBCAP_NG=false \
    USE_SYSTEMD_WATCHDOG=false \
    USE_SECCOMP=false\
    INC_USRLOCAL="/usr" \
    FINALRUNDIR="/var/run/pluto" \
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
