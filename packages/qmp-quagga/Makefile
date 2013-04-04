#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Contributors:
#	Simó Albert i Beltran
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qmp-quagga
PKG_VERSION:=0.99.21
PKG_RELEASE:=2
PKG_MD5SUM:=99840adbe57047c90dfba6b6ed9aec7f

PKG_SOURCE:=quagga-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.quagga.net/download/ \
                http://www.de.quagga.net/download/ \
                http://www.uk.quagga.net/download/

PKG_BUILD_DIR:=$(BUILD_DIR)/quagga-$(PKG_VERSION)

PKG_CONFIG_DEPENDS:= \
	CONFIG_IPV6 \
	CONFIG_PACKAGE_qmp-quagga-watchquagga \
	CONFIG_PACKAGE_qmp-quagga-zebra \
	CONFIG_PACKAGE_qmp-quagga-libzebra \
	CONFIG_PACKAGE_qmp-quagga-libospf \
	CONFIG_PACKAGE_qmp-quagga-bgpd \
	CONFIG_PACKAGE_qmp-quagga-isisd \
	CONFIG_PACKAGE_qmp-quagga-ospf6d \
	CONFIG_PACKAGE_qmp-quagga-ripd \
	CONFIG_PACKAGE_qmp-quagga-ripngd \
	CONFIG_PACKAGE_qmp-quagga-babeld \
	CONFIG_PACKAGE_qmp-quagga-vtysh
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/qmp-quagga/Default
  SECTION:=qMp
  CATEGORY:=qMp
  SUBMENU:=Routing and Redirection
  DEPENDS:=qmp-quagga
  TITLE:=The Quagga Software Routing Suite
  URL:=http://www.quagga.net
  MAINTAINER:=Vasilis Tsiligiannis <b_tsiligiannis@silverton.gr>
endef

define Package/qmp-quagga
  $(call Package/qmp-quagga/Default)
  DEPENDS:=+qmp-quagga-vtysh +qmp-quagga-bgpd
  MENU:=1
endef

define Package/qmp-quagga/description
  A routing software package that provides TCP/IP based routing services
  with routing protocols support such as RIPv1, RIPv2, RIPng, OSPFv2,
  OSPFv3, BGP-4, and BGP-4+
endef

define Package/qmp-quagga-watchquagga
  $(call Package/qmp-quagga/Default)
  TITLE:=Quagga watchdog
  DEPENDS+=+qmp-quagga-libzebra
  DEFAULT:=y if PACKAGE_qmp-quagga
endef

define Package/qmp-quagga-zebra
  $(call Package/qmp-quagga/Default)
  TITLE:=Zebra daemon
  DEPENDS+=+qmp-quagga-libzebra
  DEFAULT:=y if PACKAGE_qmp-quagga
endef

define Package/qmp-quagga-libzebra
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+librt
  TITLE:=zebra library
endef

define Package/qmp-quagga-libospf
  $(call Package/qmp-quagga/Default)
  TITLE:=OSPF library
endef

define Package/qmp-quagga-bgpd
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+qmp-quagga-libzebra
  TITLE:=BGPv4, BGPv4+, BGPv4- routing engine
endef

define Package/qmp-quagga-isisd
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+qmp-quagga-libzebra
  TITLE:=IS-IS routing engine
endef

define Package/qmp-quagga-ospfd
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+qmp-quagga-libospf +qmp-quagga-libzebra
  TITLE:=OSPFv2 routing engine
endef

define Package/qmp-quagga-ospf6d
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+qmp-quagga-libospf +qmp-quagga-libzebra @IPV6
  TITLE:=OSPFv3 routing engine
endef

define Package/qmp-quagga-ripd
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+qmp-quagga-libzebra
  TITLE:=RIP routing engine
endef

define Package/qmp-quagga-ripngd
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+qmp-quagga-libzebra @IPV6
  TITLE:=RIPNG routing engine
endef

define Package/qmp-quagga-babeld
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+qmp-quagga-libzebra
  TITLE:=Babel routing engine
endef

define Package/qmp-quagga-vtysh
  $(call Package/qmp-quagga/Default)
  DEPENDS+=+qmp-quagga-libzebra +libreadline +libncurses
  TITLE:=integrated shell for Quagga routing software
endef

define Package/qmp-quagga-zebra/conffiles
/etc/quagga/zebra.conf
endef

define Package/qmp-quagga-bgpd/conffiles
/etc/quagga/bgpd.conf
endef

define Package/qmp-quagga-isisd/conffiles
/etc/quagga/isisd.conf
endef

define Package/qmp-quagga-ospfd/conffiles
/etc/quagga/ospfd.conf
endef

define Package/qmp-quagga-ospf6d/conffiles
/etc/quagga/ospf6d.conf
endef

define Package/qmp-quagga-ripd/conffiles
/etc/quagga/ripd.conf
endef

define Package/qmp-quagga-ripngd/conffiles
/etc/quagga/ripngd.conf
endef

define Package/qmp-quagga-babeld/conffiles
/etc/quagga/babeld.conf
endef

ifneq ($(SDK),)
CONFIG_PACKAGE_qmp-quagga-libzebra:=m
CONFIG_PACKAGE_qmp-quagga-libospf:=m
CONFIG_PACKAGE_qmp-quagga-watchquagga:=m
CONFIG_PACKAGE_qmp-quagga-zebra:=m
CONFIG_PACKAGE_qmp-quagga-bgpd:=m
CONFIG_PACKAGE_qmp-quagga-isisd:=m
CONFIG_PACKAGE_qmp-quagga-ospf6d:=m
CONFIG_PACKAGE_qmp-quagga-ripd:=m
CONFIG_PACKAGE_qmp-quagga-ripngd:=m
CONFIG_PACKAGE_qmp-quagga-babeld:=m
CONFIG_PACKAGE_qmp-quagga-vtysh:=m
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
	--disable-ospfclient \
	--disable-capabilities \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-libzebra,zebra) \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-libospf,ospfd) \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-bgpd,bgpd) \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-isisd,isisd) \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-ospf6d,ospf6d) \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-ripd,ripd) \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-ripngd,ripngd) \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-babeld,babeld) \
	$(call autoconf_bool,CONFIG_PACKAGE_qmp-quagga-vtysh,vtysh) \

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -std=gnu99"

define Package/qmp-quagga/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/quagga $(1)/usr/sbin/quagga.init
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/quagga.init $(1)/etc/init.d/quagga
endef

define Package/qmp-quagga-watchquagga/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/watchquagga $(1)/usr/sbin/
endef

define Package/qmp-quagga-zebra/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/zebra $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/zebra.conf
endef

define Package/qmp-quagga-bgpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bgpd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/bgpd.conf
endef

define Package/qmp-quagga-isisd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/isisd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/isisd.conf
endef

define Package/qmp-quagga-ospfd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ospfd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/ospfd.conf
endef

define Package/qmp-quagga-ospf6d/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ospf6d $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/ospf6d.conf
endef

define Package/qmp-quagga-ripd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/ripd.conf
endef

define Package/qmp-quagga-ripngd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripngd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/ripngd.conf
endef

define Package/qmp-quagga-babeld/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/babeld $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga
	chmod 0750 $(1)/etc/quagga
	$(INSTALL_CONF) ./files/quagga.conf $(1)/etc/quagga/babeld.conf
endef

define Package/qmp-quagga-vtysh/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vtysh $(1)/usr/bin/
endef

define Package/qmp-quagga-libospf/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libospf.so.* $(1)/usr/lib/
endef

define Package/qmp-quagga-libzebra/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzebra.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,qmp-quagga))
$(eval $(call BuildPackage,qmp-quagga-libzebra))
$(eval $(call BuildPackage,qmp-quagga-libospf))
$(eval $(call BuildPackage,qmp-quagga-watchquagga))
$(eval $(call BuildPackage,qmp-quagga-zebra))
$(eval $(call BuildPackage,qmp-quagga-bgpd))
$(eval $(call BuildPackage,qmp-quagga-isisd))
$(eval $(call BuildPackage,qmp-quagga-ospfd))
$(eval $(call BuildPackage,qmp-quagga-ospf6d))
$(eval $(call BuildPackage,qmp-quagga-ripd))
$(eval $(call BuildPackage,qmp-quagga-ripngd))
$(eval $(call BuildPackage,qmp-quagga-babeld))
$(eval $(call BuildPackage,qmp-quagga-vtysh))
