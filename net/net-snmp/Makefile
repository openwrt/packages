#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=net-snmp
PKG_VERSION:=5.9.4
PKG_RELEASE:=6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/net-snmp
PKG_HASH:=8b4de01391e74e3c7014beb43961a2d6d6fa03acc34280b9585f4930745b0544
PKG_MAINTAINER:=Stijn Tintel <stijn@linux-ipv6.be>
PKG_LICENSE:=MIT BSD-3-Clause-Clear
PKG_CPE_ID:=cpe:/a:net-snmp:net-snmp

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/net-snmp/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=http://www.net-snmp.org/
endef

define Package/net-snmp/Default/description
 Simple Network Management Protocol (SNMP) is a widely used protocol for
 monitoring the health and welfare of network equipment (eg. routers),
 computer equipment and even devices like UPSs. Net-SNMP is a suite of
 applications used to implement SNMP v1, SNMP v2c and SNMP v3 using both
 IPv4 and IPv6.
endef


define Package/libnetsnmp/default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  DEPENDS:=+libnl-tiny +libpci +libpcre2
  TITLE:=net-snmp - client library
endef


define Package/libnetsnmp-nossl
  $(call Package/libnetsnmp/default)
  TITLE+= (without SSL Support)
  VARIANT:=nossl
  PROVIDES:=libnetsnmp
  DEFAULT_VARIANT:=1
  CONFLICTS:=libnetsnmp-ssl
endef

define Package/libnetsnmp-nossl/description
  This package contains shared libraries, needed by other programs (nossl).
endef

define Package/snmp-utils-nossl
  $(call Package/net-snmp/Default)
  TITLE:=net-snmp - utilities (without SSL support)
  DEPENDS:=+libnetsnmp-nossl
  PROVIDES:=snmp-utils
  VARIANT:=nossl
endef

define Package/snmp-utils-nossl/description
  $(call Package/net-snmp/Default/description)
  This package contains SNMP client utilities (without SSL Support):
    - snmpget
    - snmpset
    - snmpstatus
    - snmptest
    - snmptrap
    - snmpwalk
endef

define Package/snmpd-nossl
  $(call Package/net-snmp/Default)
  TITLE:=net-snmp - daemon (without SSL Support)
  DEPENDS:=+libnetsnmp-nossl
  PROVIDES:=snmpd
  VARIANT:=nossl
endef

define Package/snmpd-nossl/description
  $(call Package/net-snmp/Default/description)
  This package contains the snmpd daemon (without SSL Support)
endef

define Package/snmptrapd-nossl
  $(call Package/net-snmp/Default)
  TITLE:=net-snmp - notification daemon (without SSL Support)
  DEPENDS:=+libnetsnmp-nossl
  PROVIDES:=snmptrapd
  VARIANT:=nossl
endef

define Package/snmptrapd-nossl/description
  $(call Package/net-snmp/Default/description)
  This package contains the notification receiver daemon (without SSL Support)
endef


define Package/libnetsnmp-ssl
  $(call Package/libnetsnmp/default)
  TITLE+= (with SSL Support)
  VARIANT:=ssl
  DEPENDS+= +libopenssl
endef

define Package/libnetsnmp-ssl/description
  This package contains shared libraries (with SSL Support)
endef

define Package/snmp-utils-ssl
  $(call Package/net-snmp/Default)
  TITLE:=net-snmp - utilities (with SSL support)
  DEPENDS:=+libnetsnmp-ssl
  PROVIDES:=snmp-utils
  VARIANT:=ssl
endef

define Package/snmp-utils-ssl/description
  $(call Package/net-snmp/Default/description)
  This package contains SNMP client utilities (with SSL Support):
    - snmpget
    - snmpset
    - snmpstatus
    - snmptest
    - snmptrap
    - snmpwalk
endef

define Package/snmpd-ssl
  $(call Package/net-snmp/Default)
  TITLE:=net-snmp - daemon (with SSL Support)
  DEPENDS:=+libnetsnmp-ssl
  PROVIDES:=snmpd
  VARIANT:=ssl
endef

define Package/snmpd-ssl/description
  $(call Package/net-snmp/Default/description)
  This package contains the snmpd daemon (with SSL Support)
endef

define Package/snmptrapd-ssl
  $(call Package/net-snmp/Default)
  TITLE:=net-snmp - notification daemon (with SSL Support)
  DEPENDS:=+libnetsnmp-ssl
  PROVIDES:=snmptrapd
  VARIANT:=ssl
endef

define Package/snmptrapd-ssl/description
  $(call Package/net-snmp/Default/description)
  This package contains the notification receiver daemon (with SSL Support)
endef


define Package/snmp-mibs
  $(call Package/net-snmp/Default)
  TITLE:=Open source SNMP implementation (MIB-files)
endef

define Package/snmp-mibs/description
  $(call Package/net-snmp/Default/description)
  This package contains SNMP MIB-Files.
endef


SNMP_MIB_MODULES_INCLUDED = \
	agent/extend \
	agentx \
	host/hr_device \
	host/hr_disk \
	host/hr_filesys \
	host/hr_network \
	host/hr_partition \
	host/hr_proc \
	host/hr_storage \
	host/hr_system \
	ieee802dot11 \
	if-mib/ifXTable \
	ip-mib/ipAddressTable \
	ip-mib/inetNetToMediaTable \
	ip-forward-mib/inetCidrRouteTable \
	ip-forward-mib/ipCidrRouteTable \
	mibII/at \
	mibII/icmp \
	mibII/ifTable \
	mibII/ip \
	mibII/snmp_mib \
	mibII/sysORTable \
	mibII/system_mib \
	mibII/tcp \
	mibII/udp \
	mibII/vacm_context \
	mibII/vacm_vars \
	snmpv3/snmpEngine \
	snmpv3/snmpMPDStats \
	snmpv3/usmConf \
	snmpv3/usmStats \
	snmpv3/usmUser \
	tunnel \
	ucd-snmp/disk_hw \
	ucd-snmp/dlmod \
	ucd-snmp/extensible \
	ucd-snmp/loadave \
	ucd-snmp/memory \
	ucd-snmp/pass \
	ucd-snmp/pass_persist \
	ucd-snmp/proc \
	ucd-snmp/vmstat \
	util_funcs \
	utilities/execute \

SNMP_MIB_MODULES_EXCLUDED = \
	agent_mibs \
	disman/event \
	disman/schedule \
	hardware \
	host \
	if-mib \
	ip-mib \
	mibII \
	notification \
	notification-log-mib \
	snmpv3mibs \
	target \
	tcp-mib \
	ucd_snmp \
	udp-mib \
	utilities \

SNMP_TRANSPORTS_INCLUDED = Callback UDP Unix

SNMP_TRANSPORTS_EXCLUDED = TCP TCPIPv6

TARGET_CFLAGS += $(FPIC)
TARGET_CPPFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny

CONFIGURE_ARGS += \
	--enable-mfd-rewrites \
	--enable-shared \
	--with-endianness=$(if $(CONFIG_BIG_ENDIAN),big,little) \
	--with-logfile=/var/log/snmpd.log \
	--with-persistent-directory=/usr/lib/snmp/ \
	--with-default-snmp-version=1 \
	--with-sys-contact=root@localhost \
	--with-sys-location=Unknown \
	--enable-applications \
	--disable-debugging \
	--disable-manuals \
	--disable-scripts \
	--with-out-mib-modules="$(SNMP_MIB_MODULES_EXCLUDED)" \
	--with-mib-modules="$(SNMP_MIB_MODULES_INCLUDED)" \
	--with-out-transports="$(SNMP_TRANSPORTS_EXCLUDED)" \
	--with-transports="$(SNMP_TRANSPORTS_INCLUDED)" \
	--without-libwrap \
	--without-mysql \
	--without-rpm \
	--without-zlib \
	--with-pcre2-8 \
	--with-nl \
	 $(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-perl-cc-checks \
	--disable-embedded-perl \
	--without-perl-modules

CONFIGURE_VARS += \
	ac_cv_header_netlink_netlink_h=yes \
	netsnmp_cv_func_nl_connect_LIBS=-lnl-tiny \

ifeq ($(CONFIG_IPV6),y)
SNMP_TRANSPORTS_INCLUDED+= UDPIPv6
endif

ifeq ($(BUILD_VARIANT),ssl)
CONFIGURE_ARGS+= --with-openssl="$(STAGING_DIR)/usr"
else
CONFIGURE_ARGS+= --without-openssl
endif

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lm -lc" \
		all install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/net-snmp-config $(2)/bin/
	$(SED) 's,=/usr,=$(STAGING_DIR)/usr,g' $(2)/bin/net-snmp-config
	$(INSTALL_DIR) $(STAGING_DIR)/usr/bin
	$(LN) $(STAGING_DIR)/host/bin/net-snmp-config $(STAGING_DIR)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/net-snmp $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetsnmp{,agent,helpers,mibs}.{a,so*} $(1)/usr/lib/
endef

define Package/snmpd-nossl/conffiles
/etc/config/snmpd
endef
Package/snmpd-ssl/conffiles = $(Package/snmpd-nossl/conffiles)

define Package/libnetsnmp-nossl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetsnmp{,agent,helpers,mibs}.so.* $(1)/usr/lib/
endef
Package/libnetsnmp-ssl/install = $(Package/libnetsnmp-nossl/install)

define Package/snmp-utils-nossl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/snmp{get,set,status,test,trap,walk} $(1)/usr/bin/
endef
Package/snmp-utils-ssl/install = $(Package/snmp-utils-nossl/install)

define Package/snmpd-nossl/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/snmpd.conf $(1)/etc/config/snmpd
	$(INSTALL_DIR) $(1)/etc/snmp
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snmpd.init $(1)/etc/init.d/snmpd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/snmpd $(1)/usr/sbin/snmpd
endef
Package/snmpd-ssl/install = $(Package/snmpd-nossl/install)

define Package/snmptrapd-nossl/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snmptrapd.init $(1)/etc/init.d/snmptrapd
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetsnmptrapd.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/snmptrapd $(1)/usr/sbin/
endef
Package/snmptrapd-ssl/install = $(Package/snmptrapd-nossl/install)


define Package/snmp-mibs/install
	$(INSTALL_DIR) $(1)/usr/share/snmp/mibs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/snmp/mibs/* $(1)/usr/share/snmp/mibs/
endef

$(eval $(call BuildPackage,libnetsnmp-nossl))
$(eval $(call BuildPackage,snmp-utils-nossl))
$(eval $(call BuildPackage,snmpd-nossl))
$(eval $(call BuildPackage,snmptrapd-nossl))

$(eval $(call BuildPackage,libnetsnmp-ssl))
$(eval $(call BuildPackage,snmp-utils-ssl))
$(eval $(call BuildPackage,snmpd-ssl))
$(eval $(call BuildPackage,snmptrapd-ssl))

$(eval $(call BuildPackage,snmp-mibs))
