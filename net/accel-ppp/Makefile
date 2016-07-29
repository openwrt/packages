#
# Copyright (C) 2006-2016 OpenWrt.org, the original and the best
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
PKG_NAME:=accel-ppp
PKG_VERSION:=1.11.0
PKG_RELEASE:=1

PKG_REV:=6fb04941ca41312909208938bfac4f753d3c277c
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Luke McKee <hojuruku@gmail.com>
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://git.code.sf.net/p/$(PKG_NAME)/code
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_REV)
# libnl (netlink) is not required stripped down static library now included in userspace
# but it can't hurt to have it's headers around as other distros mark this is a dependency
PKG_BUILD_DEPENDS:=libnl-tiny libmnl
ACCEL_PPP_MODULES=\
	ctrl-pppoe \
	ctrl-ipoe \
	ctrl-pptp \
	ctrl-vlan-mon \
	auth-pap \
	auth-chap \
	auth-mschap \
	mod-radius \
	log-file \
	log-tcp \
	log-syslog \
	log-pgsql \
	log-wtmp \
	mod-shaper \
	mod-ippool \
	mod-ipv6 \
	mod-connlimit \
	mod-pppd_compat \
	mod-chap-secrets
PKG_CONFIG_DEPENDS:= CONFIG_ACCEL_PPP_LUA \
	$(patsubst %,CONFIG_PACKAGE_accel-ppp-%,$(subst _,-,$(ACCEL_PPP_MODULES))) \

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/kernel.mk


define Package/accel-ppp/Default
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=VPN
	DEPENDS:=@IPV6 +libopenssl +libpcre +libpthread +librt +kmod-ppp
	TITLE:=accel-ppp VPN server
	URL:=http://accel-ppp.org

endef

define Package/accel-ppp/Default/description
 ACCEL-PPP is high performance carrier-grade PPTP/L2TP/PPPoE/IPOE server for Linux. 
 The Userspace daemon has its own PPP implementation, so it does not uses pppd
 and one process (multi-threaded) can manage thousands of simulatanous connections 
 on sufficent hardware.

endef

define Package/accel-ppp
	$(call Package/accel-ppp/Default)
	MENU:=1
endef

define Package/accel-ppp/description
	$(call Package/accel-ppp/Default/description)
endef

CMAKE_SOURCE_DIR:=$(PKG_BUILD_DIR)
CMAKE_BINARY_DIR:=$(PKG_BUILD_DIR)/build
# Used to build kernel modules only -DBUILD_DRIVER=FALSE \
# Not Used unless MEMDEBUG defined -DVALGRIND=FALSE 

CMAKE_OPTIONS += \
	-DKDIR=$(LINUX_DIR) \
	-DCRYPTO=OPENSSL \
	-DMEMDEBUG=FALSE \
	-DBUILD_PPTP_DRIVER=FALSE \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DNETSNMP=FALSE \
	-DLIB_SUFFIX='' \

# OPENWRT net-snmpd package doesn't support agentx,agent_mibs, so subagent & libnetsnmp functionality is broken
# http://net-snmp.sourceforge.net/docs/README.agentx.html https://github.com/openwrt/packages/blob/master/net/net-snmp/Makefile
# so -DNETSNMP=FALSE
#$(eval $(call BuildPlugin,mod-snmp,SNMP master or snmpd subagent,libnet-snmp,,+PACKAGE_accel-ppp-mod-snmpd:libnetsnmp))
#define Package/accel-ppp-mod-snmp/install
#	$$(call Package/accel-ppp-mod-snmpd/install)
# 	$(INSTALL_DIR) /usr/share/snmpd/mibs
# 	$(INSTALL_DATA) $(PKG_BUILD_DIR)/accel-pppd/extra/net-snmp/ACCEL-PPP-MIB.txt $(1)/usr/share/snmpd/mibs/
#endef

TARGET_CFLAGS += \
	-D_GNU_SOURCE \
	-I$(STAGING_DIR)/include \
	-I$(STAGING_DIR)/usr/include \


TARGET_LDFLAGS += \
	-Wl,-z,lazy \
	-Wl,-rpath,/usr/lib/accel-ppp

define Package/accel-ppp-ctrl-ipoe/config
menu "Configuration"
        depends on PACKAGE_accel-ppp-ctrl-ipoe

config ACCEL_PPP_LUA
        bool
        default n
        prompt "Build IPOE ctrl module with LUA scripting support"
endmenu
endef

ifneq ($(CONFIG_PACKAGE_accel-ppp-log-pgsql),)
	CMAKE_OPTIONS += -DLOG_PGSQL=TRUE
endif
ifeq ($(CONFIG_PACKAGE_accel-ppp-mod-radius),)
	CMAKE_OPTIONS += -DRADIUS=FALSE
endif
ifeq ($(CONFIG_PACKAGE_accel-ppp-log-file),)
	CMAKE_OPTIONS += -DLOG_FILE=FALSE
endif
ifeq ($(CONFIG_PACKAGE_accel-ppp-log-tcp),)
	CMAKE_OPTIONS += -DLOG_TCP=FALSE
endif
ifeq ($(CONFIG_PACKAGE_accel-ppp-log-syslog),)
	CMAKE_OPTIONS += -DLOG_SYSLOG=FALSE
endif
ifneq ($(CONFIG_PACKAGE_accel-ppp-mod-shaper),)
	CMAKE_OPTIONS += -DSHAPER=TRUE
endif
ifeq ($(CONFIG_ACCEL_PPP_LUA),y)
	CMAKE_OPTIONS += -DLUA=TRUE  
endif
ifdef CONFIG_PACKAGE_kmod-ipoe
	CMAKE_OPTIONS += -DBUILD_IPOE_DRIVER=TRUE
endif
ifdef CONFIG_PACKAGE_kmod-vlan_mon
	CMAKE_OPTIONS += -DBUILD_VLAN_MON_DRIVER=TRUE
endif

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/build
	cd $(PKG_BUILD_DIR)/build
	$(Build/Configure/Default)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/build \
	PATH="$(TARGET_PATH)" \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	TOOLPREFIX="$(KERNEL_CROSS)" \
	TOOLPATH="$(KERNEL_CROSS)" \
	KERNEL_DIR="$(LINUX_DIR)" \
	LDOPTS=" " \
	DOMULTI=1
endef

define Package/accel-ppp/conffiles
/etc/accel-ppp.conf
endef

define Build/Install
	$(MAKE_VARS) \
        $(MAKE) -C $(PKG_BUILD_DIR)/build \
	$(MAKE_INSTALL_FLAGS) install
endef

define Build/InstallDev
	true
endef

define Package/accel-ppp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/accel-cmd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/accel-pppd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib/accel-ppp
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/accel-ppp/libtriton.so $(1)/usr/lib/accel-ppp/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/accel-ppp/libsigchld.so $(1)/usr/lib/accel-ppp/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/accel-pppd/accel-ppp.conf $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/accel-ppp.init $(1)/etc/init.d/accel-ppp
endef
# From before modularized version
#accel-pppd/extra/net-snmp/ACCEL-PPP-MIB.txt
#	$(INSTALL_BIN) \
#		$(PKG_INSTALL_DIR)/usr/lib/accel-ppp/lib*.so \
#		$(1)/usr/lib/accel-ppp
#	$(INSTALL_DIR) $(1)/usr/share/accel-ppp/l2tp
#	$(INSTALL_DATA) \
#		$(PKG_INSTALL_DIR)/usr/share/accel-ppp/l2tp/dictionary* \
#		$(1)/usr/share/accel-ppp/l2tp
#	$(INSTALL_DIR) $(1)/usr/share/accel-ppp/radius
#	$(INSTALL_DATA) \
#		$(PKG_INSTALL_DIR)/usr/share/accel-ppp/radius/dictionary* \
#		$(1)/usr/share/accel-ppp/radius

define KernelPackage/ipoe
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	TITLE:=ipoe kernel module (managed by accel-pppd)
	MAINTAINER:=$(PKG_MAINTAINER)
	VERSION:=$(LINUX_VERSION)+$(PKG_VERSION)-$(BOARD)-$(PKG_RELEASE)
	DEPENDS:=@IPV6 +kmod-ipt-ipset +accel-pppd
	FILES:= $(PKG_BUILD_DIR)/build/drivers/ipoe/driver/ipoe.$(LINUX_KMOD_SUFFIX)
	AUTOLOAD:=$(call AutoLoad,32,ipoe)
endef

define KernelPackage/vlan_mon
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	TITLE:=vlan_mon kernel module (managed by accel-pppd)
	MAINTAINER:=$(PKG_MAINTAINER)
	VERSION:=$(LINUX_VERSION)+$(PKG_VERSION)-$(BOARD)-$(PKG_RELEASE)
	DEPENDS:=@IPV6 +accel-pppd
	FILES:= $(PKG_BUILD_DIR)/build/drivers/vlan_mon/driver/vlan_mon.$(LINUX_KMOD_SUFFIX)
	AUTOLOAD:=$(call AutoLoad,31,vlan_mon,autoclean=1)
endef

define KernelPackage/ipoe/description
	$(call Package/accel-ppp/Default/description)
    
	This package provides the kernel module for accel_ppp's ipoe functionality.
endef

define KernelPackage/vlan_mon/description
	$(call Package/accel-ppp/Default/description)
    
	This package provides the kernel module for ipoe vlan monitoring
	and PPPOE TR-101 functionality.
endef

define KernelPackage/ipoe/install
	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_CONF) ./files/ipoe.sysctl $(1)/etc/sysctl.d/ipoe.conf
endef

define KernelPackage/ipoe/conffiles
/etc/sysctl.d/ipoe.conf
endef

# 1: plugin name
# 2: plugin title/description
# 3: module files
# 4: install data directories
# 5: extra dependency
# 6: conflicts
define BuildPlugin

  PKG_CONFIG_DEPENDS+= CONFIG_PACKAGE_accel-ppp-$(1)

  define Package/accel-ppp-$(1)
    $$(call Package/accel-ppp/Default)
    TITLE:=$(2) module
    DEPENDS:= accel-ppp $(5)
    ifdef $(6)
    CONFLICTS:= $(6)
    endif
  endef
  
  define Package/accel-ppp-$(1)/description
    $(PKG_NAME) $(1) module
    $$(call Package/accel-ppp/Default/description)
    $(2) module
  endef

  define Package/accel-ppp-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/accel-ppp
	for m in $(3); do \
		$(CP) \
			$(PKG_INSTALL_DIR)/usr/lib/accel-ppp/$$$$$$$${m}.so \
			$$(1)/usr/lib/accel-ppp/ ; \
	done
	for d in $(4); do \
		$(INSTALL_DIR) $$(1)/$$$$$$$${d} ; \
		$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/$$$$$$$${d}/* \
		$$(1)/$$$$$$$${d}/ ; \
	done
  endef

  $$(eval $$(call BuildPackage,accel-ppp-$(1)))
endef

$(eval $(call BuildPackage,accel-ppp))
$(eval $(call KernelPackage,ipoe))
$(eval $(call KernelPackage,vlan_mon))
$(eval $(call BuildPlugin,ctrl-pppoe,PPPOE access concentrator control,libpppoe,,+PACKAGE_accel-ppp-ctrl-pppoe:accel-ppp-ctrl-vlan-mon +PACKAGE_accel-ppp-ctrl-pppoe:kmod-pppoe,))
$(eval $(call BuildPlugin,ctrl-ipoe,IPOE access concentrator control,libipoe,,+PACKAGE_accel-ppp-ctrl-ipoe:kmod-ipoe +PACKAGE_accel-ppp-ctrl-ipoe:accel-ppp-ctrl-vlan-mon +PACKAGE_accel-ppp-ctrl-ipoe:kmod-ipt-ipset +ACCEL_PPP_LUA:liblua,))
$(eval $(call BuildPlugin,ctrl-l2tp,L2TP access concentrator control,libl2tp,usr/share/accel-ppp/l2tp,+PACKAGE_accel-ppp-ctrl-l2tp:kmod-pppol2tp,xl2tpd))
$(eval $(call BuildPlugin,ctrl-pptp,PPTP access concentrator control,libpptp,,+PACKAGE_accel-ppp-ctrl-pptp:kmod-pptp,pptpd))
$(eval $(call BuildPlugin,ctrl-vlan-mon,IPOE/PPTP TR-101 VLAN management,libvlan-mon,,+PACKAGE_accel-ppp-ctrl-vlan-mon:kmod-vlan_mon,))
$(eval $(call BuildPlugin,auth-pap,PAP client authentication,libauth_pap,,,))
$(eval $(call BuildPlugin,auth-chap,CHAP-MD5 client authentication,libauth_chap_md5,,,))
$(eval $(call BuildPlugin,auth-mschap,MSCHAP v1&v2 client authentication,libauth_mschap_v1 libauth_mschap_v2,,,))
$(eval $(call BuildPlugin,mod-radius,RADIUS AAA & dynamic auth extensions,libradius,usr/share/accel-ppp/radius,,accel-ppp-mod-chap-secrets))
$(eval $(call BuildPlugin,log-file,Log to files and directories,liblog_file,,,))
$(eval $(call BuildPlugin,log-tcp,Log over tcp,liblog_tcp,,,))
$(eval $(call BuildPlugin,log-syslog,Log over udp syslog,liblog_syslog,,,))
$(eval $(call BuildPlugin,log-pgsql,Log to postgresql,liblog_pgsql,,+PACKAGE_accel-ppp-log-pgsql:libpq,))
$(eval $(call BuildPlugin,log-wtmp,Log user sessions in wtmp/utmp,liblogwtmp,,,))
$(eval $(call BuildPlugin,mod-shaper,tbf/htb based traffic shaper,libshaper,,,))
$(eval $(call BuildPlugin,mod-ippool,IPv4/v6 address assign from static pool,libippool libipv6pool,,,))
$(eval $(call BuildPlugin,mod-ipv6,IPv6 DHCP/RA dynamic address assignment,libipv6_nd libipv6_dhcp,,,))
$(eval $(call BuildPlugin,mod-connlimit,Per source connection rate limiting,libconnlimit,,,))
$(eval $(call BuildPlugin,mod-pppd_compat,EXEC if-up/down.d CoA if-change.d,libpppd_compat,,,))
$(eval $(call BuildPlugin,mod-chap-secrets,chap-secrets for user/ip/shaper conf,libchap-secrets,,,accel-ppp-mod-radius))
