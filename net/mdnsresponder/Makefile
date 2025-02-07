#
# Copyright (C) 2009-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mDNSResponder
PKG_VERSION:=2200.100.94.0.2
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/apple-oss-distributions/mDNSResponder
PKG_MIRROR_HASH:=6d019ca318d189233b10e7d4a51ec6952547a87c3b81646c094021490d5990a7

PKG_MAINTAINER:=
PKG_LICENSE:=Apache-2.0
PKG_CPE_ID:=cpe:/a:apple:mdnsresponder

PKG_BUILD_PARALLEL:=0
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

# sys/capability.h is not part of *libc*
PKG_BUILD_DEPENDS:=libcap

define Package/mDNSResponder/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=mDNS
  URL:=http://developer.apple.com/networking/bonjour/
endef

define Package/mDNSResponder/Default/description
  Bonjour, also known as zero-configuration networking, enables
  automatic discovery of computers, devices, and services on
  IP networks.
endef

define Package/mdns-utils
$(call Package/mDNSResponder/Default)
  TITLE+= client utilities
  DEPENDS+= +mdnsd
endef

define Package/mdns-utils/description
$(call Package/mDNSResponder/Default/description)
 .
 This package contains mDNS client utilities:
 - dns-sd
 - mDNSClient
 - mDNSNetMonitor
 - mDNSProxyResponder
 - mDNSResponder
endef

define Package/mdnsd
$(call Package/mDNSResponder/Default)
  TITLE+= server daemon
endef

define Package/mdnsd/description
$(call Package/mDNSResponder/Default/description)
 .
 This package contains the mDNS server daemon.
endef

define Package/mdnsresponder
$(call Package/mDNSResponder/Default)
  TITLE+= suite (meta)
  DEPENDS+= +mdns-utils +mdnsd
endef

define Package/mdnsresponder/description
$(call Package/mDNSResponder/Default/description)
 .
 This meta package contains only dependencies on other packages.
endef

# I have no idea why -lc is required, but without it, C library symbols are
# not found:
MAKE_FLAGS += \
	LD="$(TARGET_CC)"  \
	CFLAGS_DEBUG="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LINKOPTS=-lc \
	LDCONFIG= \
	ETCBASE="$(PKG_INSTALL_DIR)/etc" \
	INSTBASE="$(PKG_INSTALL_DIR)/usr" \
	NSSINSTPATH="$(PKG_INSTALL_DIR)/lib" \
	MANPATH="$(PKG_INSTALL_DIR)/usr/man" \
	STARTUPSCRIPTDIR="$(PKG_INSTALL_DIR)/etc/init.d" \
	RUNLEVELSCRIPTSDIR="$(PKG_INSTALL_DIR)/etc/rc.d" \
	tls=no \
	os=linux-uclibc
MAKE_PATH = mDNSPosix

define Build/Compile
	$(call Build/Compile/Default)
	# XXX: mDNSResponder's "make install" does not seem to create:
	mkdir -p $(PKG_INSTALL_DIR)/lib/
	mkdir -p $(PKG_INSTALL_DIR)/usr/bin/
	mkdir -p $(PKG_INSTALL_DIR)/usr/sbin/
	mkdir -p $(PKG_INSTALL_DIR)/usr/lib/
	mkdir -p $(PKG_INSTALL_DIR)/usr/man/man5/
	mkdir -p $(PKG_INSTALL_DIR)/usr/man/man8/
	mkdir -p $(PKG_INSTALL_DIR)/usr/include/
	mkdir -p $(PKG_INSTALL_DIR)/etc/
	mkdir -p $(PKG_INSTALL_DIR)/etc/init.d/
	mkdir -p $(PKG_INSTALL_DIR)/etc/rc.d/
	mkdir -p $(PKG_INSTALL_DIR)/etc/rc.d/rc2.d/
	mkdir -p $(PKG_INSTALL_DIR)/etc/rc.d/rc3.d/
	mkdir -p $(PKG_INSTALL_DIR)/etc/rc.d/rc4.d/
	mkdir -p $(PKG_INSTALL_DIR)/etc/rc.d/rc5.d/
	mkdir -p $(PKG_INSTALL_DIR)/etc/rc.d/rc0.d/
	mkdir -p $(PKG_INSTALL_DIR)/etc/rc.d/rc6.d/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/dns_sd.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdns_sd.so.1 $(1)/usr/lib/
	$(LN) -s libdns_sd.so.1 $(1)/usr/lib/libdns_sd.so
endef

define Package/mdns-utils/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/dns-sd $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/mDNSPosix/build/prod/mDNSClientPosix $(1)/usr/bin/mDNSClient
	$(CP) $(PKG_BUILD_DIR)/mDNSPosix/build/prod/mDNSNetMonitor $(1)/usr/bin/mDNSNetMonitor
	$(CP) $(PKG_BUILD_DIR)/mDNSPosix/build/prod/mDNSProxyResponderPosix $(1)/usr/bin/mDNSProxyResponder
	$(CP) $(PKG_BUILD_DIR)/mDNSPosix/build/prod/mDNSResponderPosix $(1)/usr/bin/mDNSResponder
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/mDNSResponder.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mDNSResponder.init $(1)/etc/init.d/mDNSResponder
endef

define Package/mdns-utils/conffiles
/etc/mDNSResponder.conf
endef

define Package/mdnsd/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/mdnsd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mdnsd.init $(1)/etc/init.d/mdnsd
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdns_sd.so.1 $(1)/usr/lib/
	$(LN) -s libdns_sd.so.1 $(1)/usr/lib/libdns_sd.so
endef

define Package/mdnsresponder/install
	:
endef

$(eval $(call BuildPackage,mdns-utils))
$(eval $(call BuildPackage,mdnsd))
$(eval $(call BuildPackage,mdnsresponder))
