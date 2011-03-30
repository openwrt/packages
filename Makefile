#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=quagga
ifneq ($(CONFIG_QUAGGA_OLD),)
  PKG_VERSION:=0.98.6
  PKG_RELEASE:=9
  PKG_MD5SUM:=b0d4132039953a0214256873b7d23d68
  PATCH_DIR:=./patches-old
else
  PKG_VERSION:=0.99.18
  PKG_RELEASE:=1
  PKG_MD5SUM:=59e306e93a4a1ce16760f20e9075d473
endif

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.quagga.net/download/ \
                http://www.de.quagga.net/download/ \
                http://www.uk.quagga.net/download/
PKG_CONFIG_DEPENDS:= \
	CONFIG_QUAGGA_OLD \
	CONFIG_IPV6 \
	CONFIG_PACKAGE_quagga-libzebra \
	CONFIG_PACKAGE_quagga-libospf \
	CONFIG_PACKAGE_quagga-bgpd \
	CONFIG_PACKAGE_quagga-isisd \
	CONFIG_PACKAGE_quagga-ospf6d \
	CONFIG_PACKAGE_quagga-ripd \
	CONFIG_PACKAGE_quagga-ripngd \
	CONFIG_PACKAGE_quagga-vtysh
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=libtool
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/quagga/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga
  TITLE:=The Quagga Software Routing Suite
  URL:=http://www.quagga.net
  MAINTAINER:=Vasilis Tsiligiannis <b_tsiligiannis@silverton.gr>
endef

define Package/quagga
  $(call Package/quagga/Default)
  DEPENDS:=+!QUAGGA_OLD:librt
  MENU:=1
endef

define Package/quagga/description
  A routing software package that provides TCP/IP based routing services
  with routing protocols support such as RIPv1, RIPv2, RIPng, OSPFv2,
  OSPFv3, BGP-4, and BGP-4+
endef

define Package/quagga/config
config QUAGGA_OLD
	depends on (PACKAGE_quagga && BROKEN)
	default n
	bool "Use the old release version 0.98.6"
	help
	  This option allows you to select the old version of Quagga to be built.
endef

define Package/quagga-libzebra
  $(call Package/quagga/Default)
  TITLE:=zebra library
endef

define Package/quagga-libospf
  $(call Package/quagga/Default)
  TITLE:=OSPF library
endef

define Package/quagga-bgpd
  $(call Package/quagga/Default)
  DEPENDS+=+quagga-libzebra
  TITLE:=BGPv4, BGPv4+, BGPv4- routing engine
endef

define Package/quagga-isisd
  $(call Package/quagga/Default)
  TITLE:=IS-IS routing engine
endef

define Package/quagga-ospfd
  $(call Package/quagga/Default)
  DEPENDS+=+quagga-libospf +quagga-libzebra
  TITLE:=OSPFv2 routing engine
endef

define Package/quagga-ospf6d
  $(call Package/quagga/Default)
  DEPENDS+=+quagga-libospf +quagga-libzebra @IPV6
  TITLE:=OSPFv3 routing engine
endef

define Package/quagga-ripd
  $(call Package/quagga/Default)
  DEPENDS+=+quagga-libzebra
  TITLE:=RIP routing engine
endef

define Package/quagga-ripngd
  $(call Package/quagga/Default)
  DEPENDS+=+quagga-libzebra @IPV6
  TITLE:=RIPNG routing engine
endef

define Package/quagga-vtysh
  $(call Package/quagga/Default)
  DEPENDS+=quagga-libzebra +libreadline +libncurses
  TITLE:=integrated shell for Quagga routing software
endef

define Package/quagga/conffiles
/etc/quagga/zebra.conf
endef

define Package/quagga-bgpd/conffiles
/etc/quagga/bgpd.conf
endef

define Package/quagga-isisd/conffiles
/etc/quagga/isisd.conf
endef

define Package/quagga-ospfd/conffiles
/etc/quagga/ospfd.conf
endef

define Package/quagga-ospf6d/conffiles
/etc/quagga/ospf6d.conf
endef

define Package/quagga-ripd/conffiles
/etc/quagga/ripd.conf
endef

define Package/quagga-ripngd/conffiles
/etc/quagga/ripngd.conf
endef

ifneq ($(SDK),)
CONFIG_PACKAGE_quagga-libzebra:=m
CONFIG_PACKAGE_quagga-libospf:=m
CONFIG_PACKAGE_quagga-bgpd:=m
CONFIG_PACKAGE_quagga-isisd:=m
CONFIG_PACKAGE_quagga-ospf6d:=m
CONFIG_PACKAGE_quagga-ripd:=m
CONFIG_PACKAGE_quagga-ripngd:=m
CONFIG_PACKAGE_quagga-vtysh:=m
endif

CONFIGURE_ARGS+= \
	--localstatedir=/var/run/quagga \
	--sysconfdir=/etc/quagga/ \
	--enable-shared \
	--disable-static \
	--enable-user=network \
	--enable-group=network \
	--enable-pie=no \
	--enable-multipath=8 \
	$(call autoconf_bool,CONFIG_PACKAGE_quagga-libzebra,zebra) \
	$(call autoconf_bool,CONFIG_PACKAGE_quagga-libospf,ospfd) \
	$(call autoconf_bool,CONFIG_PACKAGE_quagga-bgpd,bgpd) \
	$(call autoconf_bool,CONFIG_PACKAGE_quagga-isisd,isisd) \
	$(call autoconf_bool,CONFIG_PACKAGE_quagga-ospf6d,ospf6d) \
	$(call autoconf_bool,CONFIG_PACKAGE_quagga-ripd,ripd) \
	$(call autoconf_bool,CONFIG_PACKAGE_quagga-ripngd,ripngd) \
	$(call autoconf_bool,CONFIG_PACKAGE_quagga-vtysh,vtysh) \

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -std=gnu99"

define Build/Configure
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status}; \
		autoconf \
	);
	$(call Build/Configure/Default)
endef

define Package/quagga/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/zebra $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/watchquagga $(1)/usr/sbin/
	# avoid /etc being set to 0750
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/zebra.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/quagga $(1)/usr/sbin/quagga.init
	$(INSTALL_BIN) ./files/quagga.init $(1)/etc/init.d/quagga
endef

define Package/quagga-bgpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bgpd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/bgpd.conf
endef

define Package/quagga-isisd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/isisd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/isisd.conf
endef

define Package/quagga-ospfd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ospfd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/ospfd.conf
endef

define Package/quagga-ospf6d/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ospf6d $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/ospf6d.conf
endef

define Package/quagga-ripd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/ripd.conf
endef

define Package/quagga-ripngd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripngd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/ripngd.conf
endef

define Package/quagga-vtysh/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vtysh $(1)/usr/bin/
endef

define Package/quagga-libospf/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libospf.so.* $(1)/usr/lib/
endef

define Package/quagga-libzebra/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzebra.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,quagga))
$(eval $(call BuildPackage,quagga-libzebra))
$(eval $(call BuildPackage,quagga-libospf))
$(eval $(call BuildPackage,quagga-bgpd))
$(eval $(call BuildPackage,quagga-isisd))
$(eval $(call BuildPackage,quagga-ospfd))
$(eval $(call BuildPackage,quagga-ospf6d))
$(eval $(call BuildPackage,quagga-ripd))
$(eval $(call BuildPackage,quagga-ripngd))
$(eval $(call BuildPackage,quagga-vtysh))
