#
# Copyright (C) 2007-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

ifeq ($(BUILD_VARIANT),dbus)
PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)/dbus/$(PKG_NAME)-$(PKG_VERSION)
PKG_ALT_DIR=$(BUILD_DIR)/$(PKG_NAME)/nodbus/$(PKG_NAME)-$(PKG_VERSION)
else
PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)/nodbus/$(PKG_NAME)-$(PKG_VERSION)
PKG_ALT_DIR=$(BUILD_DIR)/$(PKG_NAME)/dbus/$(PKG_NAME)-$(PKG_VERSION)
endif


PKG_NAME:=avahi
PKG_VERSION:=0.6.31
PKG_RELEASE:=5


PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://avahi.org/download/
PKG_MD5SUM:=2f22745b8f7368ad5a0a3fddac343f2d

PKG_BUILD_DEPENDS:=libexpat libdaemon libgdbm intltool/host libpthread dbus

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1



include $(INCLUDE_DIR)/package.mk

define Package/avahi/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=An mDNS/DNS-SD implementation
  URL:=http://www.avahi.org/
endef

define Package/avahi/Default/description
 Avahi is an mDNS/DNS-SD (aka RendezVous/Bonjour/ZeroConf)
 implementation (library). It facilitates
 service discovery on a local network -- this means that
 you can plug your laptop or computer into a network and
 instantly be able to view other people who you can chat with,
 find printers to print to or find files being shared.
 This kind of technology is already found in MacOS X
 (branded 'Rendezvous', 'Bonjour' and sometimes 'ZeroConf')
 and is very convenient.
endef

define Package/libavahi
  $(call Package/avahi/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpthread +SSP_SUPPORT:libssp
  TITLE+= (library)
endef

define Package/libavahi/description
$(call Package/avahi/Default/description)
 .
 The libavahi package contains the mDNS/DNS-SD shared libraries,
 used by other programs. Specifically, it provides
 libavahi-core and libavahi-common libraries.
 By default, it is built without D-Bus support,
 i.e. the --disable-dbus configuration flag is set.
 To enable D-Bus support, select the package
 libavahi-dbus-support.
endef

define Package/avahi-autoipd
  $(call Package/avahi/Default)
  SUBMENU:=IP Addresses and Names
  DEPENDS:=+libdaemon
  TITLE:=IPv4LL network address configuration daemon
endef

define Package/avahi-autoipd/description
$(call Package/avahi/Default/description)
 .
 This package implements IPv4LL, "Dynamic Configuration of IPv4 Link-Local
 Addresses" (IETF RFC3927), a protocol for automatic IP address configuration
 from the link-local 169.254.0.0/16 range without the need for a central
 server. It is primarily intended to be used in ad-hoc networks which lack a
 DHCP server.
endef

define Package/avahi-daemon
  $(call Package/avahi/Default)
  SUBMENU:=IP Addresses and Names
  ifeq ($(BUILD_VARIANT),dbus)
  DEPENDS:=+libavahi +libexpat +librt +libdaemon +libdbus
  else
  DEPENDS:=+libavahi +libexpat +librt +libdaemon
  endif
  TITLE+= (daemon)
endef

define Package/avahi-daemon/description
$(call Package/avahi/Default/description)
 .
 This package contains an mDNS/DNS-SD daemon.
endef

define Package/avahi-daemon/conffiles
/etc/avahi/avahi-daemon.conf
/etc/avahi/services/http.service
/etc/avahi/services/ssh.service
endef

define Package/avahi-dnsconfd
  $(call Package/avahi/Default)
  SUBMENU:=IP Addresses and Names
  DEPENDS:=+libavahi +libdaemon
  TITLE:=A Unicast DNS server from mDNS/DNS-SD configuration daemon
endef

define Package/avahi-dnsconfd/description
$(call Package/avahi/Default/description)
 .
 This package contains a Unicast DNS server from mDNS/DNS-SD configuration
 daemon, which may be used to configure conventional DNS servers using mDNS
 in a DHCP-like fashion. Especially useful on IPv6.
endef

define Package/libavahi-dbus-support
  $(call Package/avahi/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  VARIANT:=dbus
  DEPENDS:=+dbus +libavahi
  TITLE+= (D-Bus support)
endef

define Package/libavahi-dbus-support/description
$(call Package/libavahi/description)
 .
 The libavahi-dbus-support package enables
 D-Bus support in avahi, needed to support
 the libavahi-client library and avahi-utils.
 Selecting this package modifies the build configuration
 so that avahi packages are built with support for D-BUS enabled;
 it does not generate a separate binary of its own.
 It also automatically adds the D-Bus package to the build.
 libavahi-dbus-support is selected automatically if you select
 libavahi-client or avahi-utils.
endef

define Package/libavahi-client
  $(call Package/avahi/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libavahi-dbus-support +avahi-daemon
  TITLE+= (libavahi-client library)
endef

define Package/libavahi-client/description
$(call Package/avahi/Default/description)
 .
 This packages adds the libavahi-client library.
 It also automatically adds the required
 libavahi-dbus-support and the avahi-daemon packages.
 For more information please see the avahi documentation.
endef

define Package/avahi-utils
  $(call Package/avahi/Default)
  SUBMENU:=IP Addresses and Names
  DEPENDS:=+libavahi-client +libgdbm
  TITLE+= (utilities)
endef

define Package/avahi-utils/description
$(call Package/avahi/Default/description)
 .
 This packages installs the following avahi utility programs:
 avahi-browse, avahi-publish, avahi-resolve, avahi-set-host-name.
 It also automatically adds the required libavahi-client package.
 For more information please see the avahi documentation.
endef

TARGET_CFLAGS += $(FPIC) -DGETTEXT_PACKAGE

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--disable-glib \
	--disable-gobject \
	--disable-qt3 \
	--disable-qt4 \
	--disable-gtk \
	--disable-gtk3 \
	--with-xml=expat \
	--disable-dbm \
	--enable-gdbm \
	--enable-libdaemon \
	--disable-python \
	--disable-pygtk \
	--disable-python-dbus \
	--disable-mono \
	--disable-monodoc \
	--disable-doxygen-doc \
	--disable-doxygen-dot \
	--disable-doxygen-man \
	--disable-doxygen-rtf \
	--disable-doxygen-xml \
	--disable-doxygen-chm \
	--disable-doxygen-chi \
	--disable-doxygen-html \
	--disable-doxygen-ps \
	--disable-doxygen-pdf \
	--disable-xmltoman \
	--with-distro=none \
	--with-avahi-user=nobody \
	--with-avahi-group=nogroup \
	--with-autoipd-user=nobody \
	--with-autoipd-group=nogroup

ifneq ($(CONFIG_SSP_SUPPORT),y)
CONFIGURE_ARGS+= \
	--disable-stack-protector
endif

ifeq ($(BUILD_VARIANT),dbus)
CONFIGURE_ARGS += \
	--enable-dbus
else
CONFIGURE_ARGS += \
	--disable-dbus
endif

CONFIGURE_VARS+= \
	CFLAGS="$$$$CFLAGS -DNDEBUG -DDISABLE_SYSTEMD" \
	ac_cv_header_sys_capability_h=no \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libavahi-* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libavahi-dbus-support/install
	$(INSTALL_DIR) $(1)/etc/dbus-1/system.d
	$(CP) $(PKG_INSTALL_DIR)/etc/dbus-1/system.d/* $(1)/etc/dbus-1/system.d
endef

define Package/libavahi/install
	# The next line removes the ".build" file from the "other" build.
	# The effect is that, if the other build is re-selected in the future,
	# the build system will be forced to replace all the code in the
	# installer packages, removing anything from the current build.
	# "Other" means this: if the current build is "dbus", the other is "nodebus",
	# and if the current build is "nodbus", the other is "dbus".
	$(RM) -f $(PKG_ALT_DIR)/.built
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libavahi-{common,core}.so.* $(1)/usr/lib/
endef

define Package/libavahi-client/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libavahi-client.so.* $(1)/usr/lib/
endef

define Package/avahi-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

define Package/avahi-autoipd/install
	$(INSTALL_DIR) $(1)/etc/avahi
	$(CP) $(PKG_INSTALL_DIR)/etc/avahi/avahi-autoipd.action $(1)/etc/avahi/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/avahi-autoipd $(1)/usr/sbin/
endef

define Package/avahi-daemon/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/avahi-daemon $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/avahi
	$(INSTALL_DATA) ./files/avahi-daemon.conf $(1)/etc/avahi/
	$(INSTALL_DIR) $(1)/etc/avahi/services
	$(INSTALL_DATA) ./files/service-http $(1)/etc/avahi/services/http.service
	$(INSTALL_DATA) ./files/service-ssh $(1)/etc/avahi/services/ssh.service
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/avahi-daemon.init $(1)/etc/init.d/avahi-daemon
endef

define Package/avahi-dnsconfd/install
	$(INSTALL_DIR) $(1)/etc/avahi
	$(CP) $(PKG_INSTALL_DIR)/etc/avahi/avahi-dnsconfd.action $(1)/etc/avahi/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/avahi-dnsconfd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,libavahi-client))
$(eval $(call BuildPackage,avahi-utils))
$(eval $(call BuildPackage,libavahi-dbus-support))
$(eval $(call BuildPackage,libavahi))
$(eval $(call BuildPackage,avahi-autoipd))
$(eval $(call BuildPackage,avahi-daemon))
$(eval $(call BuildPackage,avahi-dnsconfd))
