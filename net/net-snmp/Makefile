#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=net-snmp
PKG_VERSION:=5.9.4
PKG_RELEASE:=4

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


define Package/net-snmp-ssl
$(call Package/net-snmp/Default)
  TITLE:= Open source SNMP package - with Openssl
  DEPENDS:= \
	    +libnetsnmp-ssl \
	    +snmpd-ssl \
	    +snmp-mibs \
	    +snmptrapd-ssl \
	    +snmp-utils-ssl
  VARIANT:=ssl
  CONFLICTS:=net-snmp-nossl
endef


define Package/net-snmp-nossl
$(call Package/net-snmp/Default)
  TITLE:= Open source SNMP package - without Openssl
  DEPENDS:= \
	    +libnetsnmp-nossl \
	    +snmpd-nossl \
	    +snmp-mibs \
	    +snmptrapd-nossl \
	    +snmp-utils-nossl
  VARIANT:=nossl
  PROVIDES:=net-snmp
  CONFLICTS:=net-snmp-ssl
endef

define Package/libnetsnmp-nossl
$(call Package/net-snmp/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libnl-tiny +libpci +libpcre2
  TITLE:=Open source SNMP implementation (libraries)
  PROVIDES:=libnetsnmp
  VARIANT:=nossl
  CONFLICTS:=libnetsnmp-ssl
endef

define Package/libnetsnmp-ssl
$(call Package/libnetsnmp-nossl)
  DEPENDS+=+libopenssl
  TITLE+= - with openssl
  PROVIDES:=libnetsnmp
  VARIANT:=ssl
  CONFLICTS:=libnetsnmp-nossl
endef


define Package/libnetsnmp-nossl/description
$(call Package/net-snmp/Default/description)
 .
 This package contains shared libraries, needed by other programs.
endef

define Package/libnetsnmp-ssl/description
$(call Package/libnetsnmp-nossl/description)
 This package is built with SSL support.
endef


define Package/snmp-mibs
$(call Package/net-snmp/Default)
  TITLE:=Open source SNMP implementation (MIB-files)
endef


define Package/snmp-mibs/description
$(call Package/net-snmp/Default/description)
 .
 This package contains SNMP MIB-Files.
endef


define Package/snmp-utils-nossl/Default
$(call Package/net-snmp/Default)
  TITLE:=Open source SNMP implementation (utilities)
endef


define Package/snmp-utils-ssl
$(call Package/snmp-utils-nossl/Default)
  DEPENDS:=+libnetsnmp-ssl
  VARIANT:=ssl
  TITLE+= - with Openssl
  CONFLICTS:=snmp-utils-nossl
endef


define Package/snmp-utils-nossl
$(call Package/snmp-utils-nossl/Default)
  DEPENDS:=+libnetsnmp-nossl
  VARIANT:=nossl
  TITLE+= - without Openssl
  CONFLICTS:=snmp-utils-ssl
endef


define Package/snmp-utils-nossl/description/Default
$(call Package/net-snmp/Default/description)
 .
 This package contains SNMP client utilities:
   - snmpget
   - snmpset
   - snmpstatus
   - snmptest
   - snmptrap
   - snmpwalk
endef

Package/snmp-utils-ssl/description = $(Package/snmp-utils-nossl/descripition/Default)
Package/snmp-utils-nossl/description = $(Package/snmp-utils-nossl/descripition/Default)


define Package/snmpd-nossl
$(call Package/net-snmp/Default)
  DEPENDS:=+libnetsnmp-nossl
  VARIANT:=nossl
  TITLE:=Open source SNMP implementation (daemon)
  PROVIDES:=snmpd
  CONFLICTS:=snmpd-ssl
endef

define Package/snmpd-nossl/description
$(call Package/net-snmp/Default/description)
 .
 This package contains the SNMP agent, dynamically linked.
endef


define Package/snmpd-ssl
$(call Package/net-snmp/Default)
  DEPENDS:=+libnetsnmp-ssl
  VARIANT:=ssl
  TITLE:=Open source SNMP implementation (daemon) with Openssl encryption
  CONFLICTS:=snmpd-nossl
endef


Package/snmpd-ssl/description = $(Package/snmpd-nossl/description)


define Package/snmpd-static
$(call Package/net-snmp/Default)
  TITLE:=Open source SNMP implementation (daemon)
  BUILDONLY:=1
endef


define Package/snmptrapd-nossl/Default
$(call Package/net-snmp/Default)
  TITLE:=Open source SNMP implementation (notification receiver)
endef

define Package/snmptrapd-ssl
$(call Package/snmptrapd-nossl/Default)
  DEPENDS:=+libnetsnmp-ssl
  VARIANT:=ssl
  TITLE+= - with Openssl
  CONFLICTS:=snmptrapd-nossl
endef

define Package/snmptrapd-nossl
$(call Package/snmptrapd-nossl/Default)
  DEPENDS:=+libnetsnmp-nossl
  VARIANT:=nossl
  TITLE+= - without Openssl
  CONFLICTS:=snmptrapd-ssl
endef


define Package/snmptrapd-nossl/description/Default
$(call Package/net-snmp/Default/description)
 .
 This package contains the SNMP notification receiver.
endef


Package/snmptrapd-ssl/description = $(Package/snmpdtrapd-nossl/description/Default)
Package/snmptrapd-nossl/description = $(Package/snmpdtrapd-nossl/description/Default)


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
	--enable-static \
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

define Package/libnetsnmp-nossl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetsnmp{,agent,helpers,mibs}.so.* $(1)/usr/lib/
endef


define Package/libnetsnmp-ssl/install
$(call Package/libnetsnmp-nossl/install,$(1))
endef

define Package/snmp-mibs/install
	$(INSTALL_DIR) $(1)/usr/share/snmp/mibs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/snmp/mibs/* $(1)/usr/share/snmp/mibs/
endef

define Package/snmp-utils-nossl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/snmp{get,set,status,test,trap,walk} $(1)/usr/bin/
endef

define Package/snmp-utils-ssl/install
$(call Package/snmp-utils-nossl/install,$(1))
endef

define Package/snmpd/conffiles/Default
/etc/config/snmpd
endef

Package/snmpd-ssl/conffiles = $(Package/snmpd/conffiles/Default)
Package/snmpd-nossl/conffiles = $(Package/snmpd/conffiles/Default)

define Package/snmpd-nossl/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/snmpd.conf $(1)/etc/config/snmpd
	$(INSTALL_DIR) $(1)/etc/snmp
	$(LN) /var/run/snmpd.conf $(1)/etc/snmp/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snmpd.init $(1)/etc/init.d/snmpd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/snmpd $(1)/usr/sbin/snmpd
endef


define Package/snmpd-ssl/install
$(call Package/snmpd-nossl/install,$(1))
endef

define Package/snmptrapd-nossl/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/snmptrapd.init $(1)/etc/init.d/snmptrapd
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnetsnmptrapd.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/snmptrapd $(1)/usr/sbin/
endef


define Package/snmptrapd-ssl/install
$(call Package/snmptrapd-nossl/install,$(1))
endef


$(eval $(call BuildPackage,libnetsnmp-nossl))
$(eval $(call BuildPackage,libnetsnmp-ssl))
$(eval $(call BuildPackage,snmp-mibs))
$(eval $(call BuildPackage,snmp-utils-nossl))
$(eval $(call BuildPackage,snmp-utils-ssl))
$(eval $(call BuildPackage,snmpd-nossl))
$(eval $(call BuildPackage,snmpd-ssl))
$(eval $(call BuildPackage,snmpd-static))
$(eval $(call BuildPackage,snmptrapd-nossl))
$(eval $(call BuildPackage,snmptrapd-ssl))
$(eval $(call BuildPackage,net-snmp-nossl))
$(eval $(call BuildPackage,net-snmp-ssl))
