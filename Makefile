#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=quagga
PKG_VERSION:=0.98.5
PKG_RELEASE:=1
PKG_MD5SUM:=ec09c1ec624aea98e18aa19282666784

PKG_SOURCE_URL:=http://www.quagga.net/download/ \
                http://www.de.quagga.net/download/ \
                http://www.uk.quagga.net/download/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk

define Package/quagga
  SECTION:=net
  CATEGORY:=Network
  TITLE:=The Quagga Software Routing Suite
  DESCRIPTION:=A routing software package that provides TCP/IP based routing services\\\
	with routing protocols support such as RIPv1, RIPv2, RIPng, OSPFv2,\\\
	OSPFv3, BGP-4, and BGP-4+\\\
  URL:=http://www.quagga.net
  MENU:=1
endef

define Package/quagga-libzebra
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga
  TITLE:=zebra library
endef

define Package/quagga-libospf
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga
  TITLE:=OSPF library
endef

define Package/quagga-bgpd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga
  TITLE:=BGPv4, BGPv4+, BGPv4- routing engine
endef

define Package/quagga-isisd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga
  TITLE:=IS-IS routing engine
endef

define Package/quagga-ospfd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga quagga-libospf
  TITLE:=OSPFv2 routing engine
endef

define Package/quagga-ospf6d
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga quagga-libospf
  TITLE:=OSPFv3 routing engine
endef

define Package/quagga-ripd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga
  TITLE:=RIP routing engine
endef

define Package/quagga-ripngd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga
  TITLE:=RIPNG routing engine
endef

define Package/quagga-vtysh
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga +libreadline +libncurses
  TITLE:=integrated shell for Quagga routing software
endef

define Build/Configure
$(call Build/Configure/Default, --enable-shared \
		--disable-static \
		--enable-ipv6 \
		--enable-vtysh \
		--enable-user=quagga \
		--enable-group=quagga \
		--enable-multipath=8 \
		--enable-isisd)
endef

define Build/Compile	
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR=$(PKG_INSTALL_DIR) \
		all install
endef

define Package/quagga/install	
	install -d -m0755 $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/zebra $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/watchquagga $(1)/usr/sbin/
	# avoid /etc being set to 0750
	install -d -m0755 $(1)/etc/quagga/
	chmod 0750 $(1)/etc/quagga/
	install -d -m0755 $(1)/etc/init.d/
	install -m0755 ./files/quagga.init $(1)/etc/init.d/quagga
	ln -sf quagga $(1)/etc/init.d/S49quagga
	install -d -m0755 $(1)/var/run/quagga
endef

define Package/quagga-bgpd/install	
	install -d -m0755 $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/bgpd $(1)/usr/sbin/
endef

define Package/quagga-isisd/install
	install -d -m0755 $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/isisd $(1)/usr/sbin
endef

define Package/quagga-ospfd/install	
	install -d -m0755 $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libospf.so.* $(1)/usr/lib/
	install -d -m0755 $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/ospfd $(1)/usr/sbin/
endef

define Package/quagga-ospf6d/install	
	install -d -m0755 $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/ospf6d $(1)/usr/sbin/
endef

define Package/quagga-ripd/install	
	install -d -m0755 $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/ripd $(1)/usr/sbin/
endef

define Package/quagga-ripngd/install	
	install -d -m0755 $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/ripngd $(1)/usr/sbin/
endef

define Package/quagga-vtysh/install	
	install -d -m0755 $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/vtysh $(1)/usr/bin/
endef

define Package/quagga-libospf/install
	install -d -m0755 $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libospf.so.* $(1)/usr/lib/
endef

define Package/quagga-libzebra/install
	install -d -m0755 $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzebra.so.* $(1)/usr/lib
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
