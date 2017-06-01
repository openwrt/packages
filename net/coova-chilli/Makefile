#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=coova-chilli
PKG_VERSION:=1.3.1.4+20160523
PKG_MAINTAINER:=Imre Kaloz <kaloz@openwrt.org>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/coova/coova-chilli
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=428a0504e1e0153a969d4f9209aba4f3d4df98a3
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=1a378cf2742fa3df6f98dc10be1d509b

PKG_INSTALL:=1

PKG_CONFIG_DEPENDS := \
  COOVACHILLI_CHILLIQUERY \
  COOVACHILLI_LEAKYBUCKET \
  COOVACHILLI_UAMANYIP \
  COOVACHILLI_UAMUIPORT \
  COOVACHILLI_ACCOUNTING_ONOFF \
  COOVACHILLI_TAP \
  COOVACHILLI_TCPRESET \
  COOVACHILLI_RADPROXY \
  COOVACHILLI_NO_DEBUG \
  COOVACHILLI_DEBUG \
  COOVACHILLI_DEBUG2 \
  COOVACHILLI_WPAD \
  COOVACHILLI_CHILLIPROXY \
  COOVACHILLI_CURL \
  COOVACHILLI_IPWHITELIST \
  COOVACHILLI_GARDENEXT \
  COOVACHILLI_DHCPRADIUS \
  COOVACHILLI_SESSGARDEN \
  COOVACHILLI_SESSPROXY \
  COOVACHILLI_SESSDHCP \
  COOVACHILLI_SESSDNS \
  COOVACHILLI_CHILLIXML \
  COOVACHILLI_PROXYVSA \
  COOVACHILLI_INSPECT \
  COOVACHILLI_COA \
  COOVACHILLI_DHCPOPT \
  COOVACHILLI_MINIPORTAL \
  COOVACHILLI_CHILLIREDIR \
  COOVACHILLI_CHILLISCRIPT \
  COOVACHILLI_CLUSTER \
  COOVACHILLI_SESSIONSTATE \
  COOVACHILLI_SESSIONID \
  COOVACHILLI_APSESSIONID \
  COOVACHILLI_COOVACHILLICONFIG \
  COOVACHILLI_MDNS \
  COOVACHILLI_NETBIOS \
  COOVACHILLI_IEEE8023 \
  COOVACHILLI_PPPOE \
  COOVACHILLI_L2TPPPP \
  COOVACHILLI_EAPOL \
  COOVACHILLI_USERAGENT \
  COOVACHILLI_ACCEPTLANGUAGE \
  COOVACHILLI_LOCATION \
  COOVACHILLI_FORCEDNS \
  COOVACHILLI_DNSLOG \
  COOVACHILLI_UAMDOMAINFILE \
  COOVACHILLI_REDIRDNSREQ \
  COOVACHILLI_IEEE8021Q \
  COOVACHILLI_LARGELIMITS \
  COOVACHILLI_MMAP \
  COOVACHILLI_NOSSL \
  COOVACHILLI_MATRIXSSL \
  COOVACHILLI_MATRIXSSL_CLI \
  COOVACHILLI_CYASSL \
  COOVACHILLI_OPENSSL \
  COOVACHILLI_IPV6 \
  COOVACHILLI_PCAP \
  COOVACHILLI_POLL \
  COOVACHILLI_IPC_MSG \
  COOVACHILLI_SFHASH \
  COOVACHILLI_LOOKUP3 \
  COOVACHILLI_PATRICIA \
  COOVACHILLI_REDIRINJECT \
  COOVACHILLI_SSDP \
  COOVACHILLI_LAYER3 \
  COOVACHILLI_MODULES \
  COOVACHILLI_EXTADMVSA \
  COOVACHILLI_BINSTATUSFILE \
  COOVACHILLI_STATUSFILE \
  COOVACHILLI_MULTIROUTE \
  COOVACHILLI_MULTILAN \
  COOVACHILLI_EWTAPI \
  COOVACHILLI_CHILLIRADSEC \
  COOVACHILLI_MINICONFIG \
  COOVACHILLI_NFQUEUE \
  COOVACHILLI_AUTHEDALLOWED

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/coova-chilli
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-tun +librt +COOVACHILLI_NFQUEUE:libnetfilter-queue +COOVACHILLI_NFQUEUE:libnfnetlink +COOVACHILLI_PCAP:libpcap +COOVACHILLI_CURL:libcurl +COOVACHILLI_CURL:libcares +COOVACHILLI_MATRIXSSL:libmatrixssl +COOVACHILLI_CYASSL:libcyassl +COOVACHILLI_OPENSSL:libopenssl
  TITLE:=Wireless LAN HotSpot controller (Coova Chilli Version)
  URL:=http://www.coova.org/CoovaChilli
  MENU:=1
endef

define Package/coova-chilli/description
	CoovaChilli is a feature rich software access controller that provides
	a captive portal / walled-garden environment and uses RADIUS or a
	HTTP protocol for access provisioning and accounting.
	It is used for authenticating users of a wireless (or wired) LAN.
	It supports web based login (UAM) which is today's standard for public
	HotSpots and it supports Wireless Protected Access (WPA) which is
	the standard of the future.
	Authentication, authorization and accounting (AAA) is handled by your
	favorite RADIUS server.
endef

define Package/coova-chilli/config
  source "$(SOURCE)/Config.in"
endef

define KernelPackage/ipt-coova
  URL:=http://www.coova.org/CoovaChilli
  SUBMENU:=Netfilter Extensions
  DEPENDS:=coova-chilli +kmod-ipt-core +libxtables
  TITLE:=Coova netfilter module
  FILES:=$(PKG_BUILD_DIR)/src/linux/xt_*.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoProbe,xt_coova)
endef

define KernelPackage/ipt-coova/description
	Netfilter kernel module for CoovaChilli
	Includes:
	- coova
endef

DISABLE_NLS=

TARGET_CFLAGS += $(FPIC)

CONFIGURE_VARS += \
       ARCH="$(LINUX_KARCH)" \
       KERNEL_DIR="$(LINUX_DIR)"

MAKE_FLAGS += \
       ARCH="$(LINUX_KARCH)" \
       KERNEL_DIR="$(LINUX_DIR)"

MAKE_INSTALL_FLAGS += \
       ARCH="$(LINUX_KARCH)" \
       KERNEL_DIR="$(LINUX_DIR)" \
       INSTALL_MOD_PATH="$(PKG_INSTALL_DIR)"

define Build/Prepare
$(call Build/Prepare/Default)
	( cd $(PKG_BUILD_DIR) ; \
		[ -f ./configure ] || { \
			./bootstrap ; \
		} \
	)
endef

define Build/Configure
	$(call Build/Configure/Default, \
	$(if $(CONFIG_COOVACHILLI_CHILLIQUERY),--enable,--disable)-chilliquery \
	$(if $(CONFIG_COOVACHILLI_LEAKYBUCKET),--enable,--disable)-leakybucket \
	$(if $(CONFIG_COOVACHILLI_UAMANYIP),--enable,--disable)-uamanyip \
	$(if $(CONFIG_COOVACHILLI_UAMUIPORT),--enable,--disable)-uamuiport \
	$(if $(CONFIG_COOVACHILLI_ACCOUNTING_ONOFF),--enable,--disable)-accounting-onoff \
	$(if $(CONFIG_COOVACHILLI_TAP),--enable,--disable)-tap \
	$(if $(CONFIG_COOVACHILLI_TCPRESET),--enable,--disable)-tcpreset \
	$(if $(CONFIG_COOVACHILLI_RADPROXY),--enable,--disable)-radproxy \
	--enable-json \
	$(if $(CONFIG_COOVACHILLI_DEBUG),--enable,--disable)-debug \
	$(if $(CONFIG_COOVACHILLI_DHCPRADIUS),--enable,--disable)-dhcpradius \
	$(if $(CONFIG_COOVACHILLI_WPAD),--enable,--disable)-wpad \
	--enable-gardenaccounting \
	$(if $(CONFIG_COOVACHILLI_GARDENEXT),--enable,--disable)-gardenext \
	$(if $(CONFIG_COOVACHILLI_INSPECT),--enable,--disable)-inspect \
	$(if $(CONFIG_COOVACHILLI_COA),--enable,--disable)-coa \
	$(if $(CONFIG_COOVACHILLI_DHCPOPT),--enable,--disable)-dhcpopt \
	$(if $(CONFIG_COOVACHILLI_DEBUG2),--enable,--disable)-debug2 \
	$(if $(CONFIG_COOVACHILLI_SESSGARDEN),--enable,--disable)-sessgarden \
	$(if $(CONFIG_COOVACHILLI_SESSPROXY),--enable,--disable)-sessproxy \
	$(if $(CONFIG_COOVACHILLI_SESSDHCP),--enable,--disable)-sessdhcp \
	$(if $(CONFIG_COOVACHILLI_SESSDNS),--enable,--disable)-sessdns \
	$(if $(CONFIG_COOVACHILLI_CHILLIXML),--enable,--disable)-chillixml \
	$(if $(CONFIG_COOVACHILLI_PROXYVSA),--enable,--disable)-proxyvsa \
	$(if $(CONFIG_COOVACHILLI_DNSLOG),--enable,--disable)-dnslog \
	$(if $(CONFIG_COOVACHILLI_IPWHITELIST),--enable,--disable)-ipwhitelist \
	$(if $(CONFIG_COOVACHILLI_UAMDOMAINFILE),--enable,--disable)-uamdomainfile \
	$(if $(CONFIG_COOVACHILLI_REDIRDNSREQ),--enable,--disable)-redirdnsreq \
	$(if $(CONFIG_COOVACHILLI_IEEE8021Q),--enable,--disable)-ieee8021q \
	$(if $(CONFIG_COOVACHILLI_LARGELIMITS),--enable,--disable)-largelimits \
	$(if $(CONFIG_COOVACHILLI_OPENSSL),--with,--without)-openssl \
	$(if $(CONFIG_COOVACHILLI_MATRIXSSL),--with,--without)-matrixssl \
	$(if $(CONFIG_COOVACHILLI_CYASSL),--with,--without)-cyassl \
	$(if $(CONFIG_COOVACHILLI_MATRIXSSL_CLI),--with,--without)-matrixssl-cli \
	$(if $(CONFIG_COOVACHILLI_NFQUEUE),--with,--without)-nfqueue \
	--without-avl \
	$(if $(CONFIG_PACKAGE_kmod-ipt-coova),--with,--without)-nfcoova \
	$(if $(CONFIG_COOVACHILLI_SFHASH),--with,--without)-sfhash \
	$(if $(CONFIG_COOVACHILLI_LOOKUP3),--with,--without)-lookup3 \
	$(if $(CONFIG_COOVACHILLI_PATRICIA),--with,--without)-patricia \
	$(if $(CONFIG_COOVACHILLI_AUTHEDALLOWED),--enable,--disable)-authedallowed \
	$(if $(CONFIG_COOVACHILLI_IPV6),--with,--without)-ipv6 \
	$(if $(CONFIG_COOVACHILLI_PCAP),--with,--without)-pcap \
	$(if $(CONFIG_COOVACHILLI_CURL),--with,--without)-curl \
	$(if $(CONFIG_COOVACHILLI_MMAP),--with,--without)-mmap \
	$(if $(CONFIG_COOVACHILLI_POLL),--with,--without)-poll \
	$(if $(CONFIG_COOVACHILLI_IPC_MSG),--with,--without)-ipc-msg \
	$(if $(CONFIG_COOVACHILLI_BINSTATUSFILE),--enable,--disable)-binstatusfile \
	$(if $(CONFIG_COOVACHILLI_STATUSFILE),--enable,--disable)-statusfile \
	$(if $(CONFIG_COOVACHILLI_CHILLIPROXY),--enable,--disable)-chilliproxy \
	$(if $(CONFIG_COOVACHILLI_MULTIROUTE),--enable,--disable)-multiroute \
	$(if $(CONFIG_COOVACHILLI_MULTILAN),--enable,--disable)-multilan \
	$(if $(CONFIG_COOVACHILLI_CHILLIRADSEC),--enable,--disable)-chilliradsec \
	$(if $(CONFIG_COOVACHILLI_REDIR),--enable,--disable)-chilliredir \
	$(if $(CONFIG_COOVACHILLI_CHILLISCRIPT),--enable,--disable)-chilliscript \
	$(if $(CONFIG_COOVACHILLI_CLUSTER),--enable,--disable)-cluster \
	$(if $(CONFIG_COOVACHILLI_SESSIONSTATE),--enable,--disable)-sessionstate \
	$(if $(CONFIG_COOVACHILLI_SESSIONID),--enable,--disable)-sessionid \
	$(if $(CONFIG_COOVACHILLI_APSESSIONID),--enable,--disable)-apsessionid \
	$(if $(CONFIG_COOVACHILLI_COOVACHILLICONFIG),--enable,--disable)-coovachilliconfig \
	$(if $(CONFIG_COOVACHILLI_MDNS),--enable,--disable)-mdns \
	$(if $(CONFIG_COOVACHILLI_NETBIOS),--enable,--disable)-netbios \
	$(if $(CONFIG_COOVACHILLI_IEEE8023),--enable,--disable)-ieee8023 \
	$(if $(CONFIG_COOVACHILLI_PPPOE),--enable,--disable)-pppoe \
	$(if $(CONFIG_COOVACHILLI_L2TPPPP),--enable,--disable)-l2tpppp \
	$(if $(CONFIG_COOVACHILLI_EAPOL),--enable,--disable)-eapol \
	$(if $(CONFIG_COOVACHILLI_MINIPORTAL),--enable,--disable)-miniportal \
	$(if $(CONFIG_COOVACHILLI_MINICONFIG),--enable,--disable)-miniconfig \
	$(if $(CONFIG_COOVACHILLI_EWTAPI),--enable,--disable)-ewtapi \
	--enable-libjson \
	$(if $(CONFIG_COOVACHILLI_SSDP),--enable,--disable)-ssdp \
	$(if $(CONFIG_COOVACHILLI_LAYER3),--enable,--disable)-layer3 \
	$(if $(CONFIG_COOVACHILLI_MODULES),--enable,--disable)-modules \
	$(if $(CONFIG_COOVACHILLI_EXTADMVSA),--enable,--disable)-extadmvsa \
	$(if $(CONFIG_COOVACHILLI_REDIRINJECT),--enable,--disable)-redirinject \
	--disable-netnat \
	$(if $(CONFIG_COOVACHILLI_USERAGENT),--enable,--disable)-useragent \
	$(if $(CONFIG_COOVACHILLI_ACCEPTLANGUAGE),--enable,--disable)-acceptlanguage \
	$(if $(CONFIG_COOVACHILLI_LOCATION),--enable,--disable)-location \
	$(if $(CONFIG_COOVACHILLI_FORCEDNS),--enable,--disable)-forcedns \
	)
endef

define Package/coova-chilli/conffiles
/etc/config/chilli
endef

define Package/coova-chilli/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/chilli.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/chilli
	$(CP) $(PKG_INSTALL_DIR)/etc/chilli/* $(1)/etc/chilli/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/chilli.hotplug $(1)/etc/hotplug.d/iface/30-chilli
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/chilli* $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so.* $(1)/usr/lib/
	$(if $(CONFIG_PACKAGE_kmod-ipt-coova), \
		$(INSTALL_DIR) $(1)/usr/lib/iptables; \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/iptables/lib*.so $(1)/usr/lib/iptables/ \
	)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/chilli.init $(1)/etc/init.d/chilli
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) files/chilli.config $(1)/etc/config/chilli
	$(INSTALL_DIR) $(1)/lib/firewall
	$(CP) files/chilli.firewall $(1)/lib/firewall/chilli.sh
endef

$(eval $(call BuildPackage,coova-chilli))
$(eval $(call KernelPackage,ipt-coova))
