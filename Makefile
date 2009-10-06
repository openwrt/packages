#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=quagga
PKG_VERSION:=0.98.6
PKG_RELEASE:=3
PKG_MD5SUM:=b0d4132039953a0214256873b7d23d68

PKG_SOURCE_URL:=http://www.quagga.net/download/ \
                http://www.de.quagga.net/download/ \
                http://www.uk.quagga.net/download/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/quagga/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=quagga
  TITLE:=The Quagga Software Routing Suite
  URL:=http://www.quagga.net
endef

define Package/quagga
  $(call Package/quagga/Default)
  DEPENDS:=
  MENU:=1
endef

define Package/quagga/description
	A routing software package that provides TCP/IP based routing services
	with routing protocols support such as RIPv1, RIPv2, RIPng, OSPFv2,
	OSPFv3, BGP-4, and BGP-4+
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
  DEPENDS += quagga-libzebra
  TITLE:=BGPv4, BGPv4+, BGPv4- routing engine
endef

define Package/quagga-isisd
  $(call Package/quagga/Default)
  TITLE:=IS-IS routing engine
endef

define Package/quagga-ospfd
  $(call Package/quagga/Default)
  DEPENDS += quagga-libospf quagga-libzebra
  TITLE:=OSPFv2 routing engine
endef

define Package/quagga-ospf6d
  $(call Package/quagga/Default)
  DEPENDS += quagga-libospf quagga-libzebra @IPV6
  TITLE:=OSPFv3 routing engine
endef

define Package/quagga-ripd
  $(call Package/quagga/Default)
  DEPENDS += quagga-libzebra
  TITLE:=RIP routing engine
endef

define Package/quagga-ripngd
  $(call Package/quagga/Default)
  DEPENDS += quagga-libzebra @BROKEN
  TITLE:=RIPNG routing engine
endef

define Package/quagga-vtysh
  $(call Package/quagga/Default)
  DEPENDS += quagga-libzebra +libreadline +libncurses
  TITLE:=integrated shell for Quagga routing software
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--localstatedir=/var/run/quagga \
		--sysconfdir=/etc/quagga/ \
		--enable-shared \
		--disable-static \
		--enable-vtysh \
		--enable-user=quagga \
		--enable-group=quagga \
		--enable-multipath=8 \
		--enable-isisd \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR=$(PKG_INSTALL_DIR) \
		all install
endef

define Package/quagga/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/zebra $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/watchquagga $(1)/usr/sbin/
	# avoid /etc being set to 0750
	$(INSTALL_DIR) $(1)/etc/quagga/
	chmod 0750 $(1)/etc/quagga/
	$(INSTALL_DATA) ./files/quagga.conf $(1)/etc/quagga/zebra.conf
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/quagga $(1)/usr/sbin/quagga.init
	$(INSTALL_BIN) ./files/quagga.init $(1)/etc/init.d/quagga
endef

define Package/quagga/postinst
#!/bin/sh
  
name=quagga
id=51
  
# do not change below
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	# create copies of passwd and group, if we use squashfs
	rootfs=`mount |awk '/root/ { print $$5 }'`
	if [ "$$rootfs" = "squashfs" ]; then
		if [ -h /etc/group ]; then
			rm /etc/group
			cp /rom/etc/group /etc/group
		fi
		if [ -h /etc/passwd ]; then
			rm /etc/passwd
			cp /rom/etc/passwd /etc/passwd
		fi
	fi
fi

echo ""
if [ -z "$$(grep ^\\$${name}: $${IPKG_INSTROOT}/etc/group)" ]; then 
	echo "adding group $$name to /etc/group"
	echo "$${name}:x:$${id}:" >> $${IPKG_INSTROOT}/etc/group  
fi

if [ -z "$$(grep ^\\$${name}: $${IPKG_INSTROOT}/etc/passwd)" ]; then 
	echo "adding user $$name to /etc/passwd"
	echo "$${name}:x:$${id}:$${id}:$${name}:/tmp/.$${name}:/bin/false" >> $${IPKG_INSTROOT}/etc/passwd
fi

grep -q '^zebra[[:space:]]*2601/tcp' $${IPKG_INSTROOT}/etc/services 2>/dev/null
if [ $$? -ne 0 ]; then  
echo "zebrasrv      2600/tcp" >>$${IPKG_INSTROOT}/etc/services
echo "zebra         2601/tcp" >>$${IPKG_INSTROOT}/etc/services
echo "ripd          2602/tcp" >>$${IPKG_INSTROOT}/etc/services
echo "ripngd        2603/tcp" >>$${IPKG_INSTROOT}/etc/services
echo "ospfd         2604/tcp" >>$${IPKG_INSTROOT}/etc/services
echo "bgpd          2605/tcp" >>$${IPKG_INSTROOT}/etc/services
echo "ospf6d        2606/tcp" >>$${IPKG_INSTROOT}/etc/services
echo "ospfapi       2607/tcp" >>$${IPKG_INSTROOT}/etc/services
echo "isisd         2608/tcp" >>$${IPKG_INSTROOT}/etc/services
fi
endef

define Package/quagga-bgpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bgpd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga/
	chmod 0750 $(1)/etc/quagga/
	$(INSTALL_DATA) ./files/quagga.conf $(1)/etc/quagga/bgpd.conf
endef

define Package/quagga-isisd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/isisd $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/quagga/
	chmod 0750 $(1)/etc/quagga/
	$(INSTALL_DATA) ./files/quagga.conf $(1)/etc/quagga/isisd.conf
endef

define Package/quagga-ospfd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ospfd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga/
	chmod 0750 $(1)/etc/quagga/
	$(INSTALL_DATA) ./files/quagga.conf $(1)/etc/quagga/ospfd.conf
endef

define Package/quagga-ospf6d/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ospf6d $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga/
	chmod 0750 $(1)/etc/quagga/
	$(INSTALL_DATA) ./files/quagga.conf $(1)/etc/quagga/ospf6d.conf
endef

define Package/quagga-ripd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga/
	chmod 0750 $(1)/etc/quagga/
	$(INSTALL_DATA) ./files/quagga.conf $(1)/etc/quagga/ripd.conf
endef

define Package/quagga-ripngd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ripngd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/quagga/
	chmod 0750 $(1)/etc/quagga/
	$(INSTALL_DATA) ./files/quagga.conf $(1)/etc/quagga/ripngd.conf
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
