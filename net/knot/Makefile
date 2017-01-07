#
# Copyright (C) 2014-2016 CZ.NIC, z.s.p.o. <knot-dns@labs.nic.cz>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=knot
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://secure.nic.cz/files/knot-dns/
PKG_MD5SUM:=7ca754f972fb07faa4f30e50d8a4385b

PKG_MAINTAINER:=Daniel Salzman <daniel.salzman@nic.cz>
PKG_LICENSE:=GPL-3.0 LGPL-2.0 0BSD MIT OLDAP-2.8

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/knot-lib/Default
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Knot DNS
	URL:=https://www.knot-dns.cz
endef

define Package/knot/Default
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=IP Addresses and Names
	TITLE:=Knot DNS
	URL:=https://www.knot-dns.cz
	USERID:=knot=5353:knot=5353
endef

define Package/knot-libdnssec
	$(call Package/knot-lib/Default)
	TITLE+= DNSSEC library
	DEPENDS=+libpthread +libgnutls +jansson
endef

define Package/knot-libknot
	$(call Package/knot-lib/Default)
	TITLE+= library
	DEPENDS=+libpthread +knot-libdnssec
endef

define Package/knot-libzscanner
	$(call Package/knot-lib/Default)
	TITLE+= zone parser library
	DEPENDS=+libpthread
endef

define Package/knot
	$(call Package/knot/Default)
	TITLE+= server
	DEPENDS=+liburcu +libedit +knot-libdnssec +knot-libknot +knot-libzscanner
endef

define Package/knot-dig
	$(call Package/knot/Default)
	TITLE+= advanced DNS lookup utility
	DEPENDS=+knot-libdnssec +knot-libknot
endef

define Package/knot-host
	$(call Package/knot/Default)
	TITLE+= simple DNS lookup utility
	DEPENDS=+knot-libdnssec +knot-libknot
endef

define Package/knot-nsupdate
	$(call Package/knot/Default)
	TITLE+= dynamic DNS update utility
	DEPENDS=+knot-libdnssec +knot-libknot +knot-libzscanner
endef

define Package/knot-nsec3hash
	$(call Package/knot/Default)
	TITLE+= simple NSEC3 hash utility
	DEPENDS=+knot-libdnssec
endef

define Package/knot-zonecheck
	$(call Package/knot/Default)
	TITLE+= zonefile check utility
	DEPENDS=+liburcu +knot-libdnssec +knot-libknot +knot-libzscanner
endef

define Package/knot-keymgr
	$(call Package/knot/Default)
	TITLE+= DNSSEC key management utility
	DEPENDS=+liburcu +knot-libdnssec +knot-libknot +knot-libzscanner
endef

define Package/knot-tests
	$(call Package/knot/Default)
	TITLE+= tests
	DEPENDS=+liburcu +libedit +knot-libdnssec +knot-libknot +knot-libzscanner
endef

define Package/knot-libdnssec/description
	Knot DNS DNSSEC library.
endef

define Package/knot-libknot/description
	Knot DNS library.
endef

define Package/knot-libdnssec/description
	Knot DNS zone parser library.
endef

define Package/knot/description
	High-performance authoritative-only DNS server.
endef

define Package/knot-dig/description
	Knot DNS advanced DNS lookup utility.
endef

define Package/knot-host/description
	Knot DNS simple DNS lookup utility.
endef

define Package/knot-nsupdate/description
	Knot DNS dynamic DNS update utility.
endef

define Package/knot-nsec3hash/description
	Knot DNS simple NSEC3 hash utility.
endef

define Package/knot-zonecheck/description
	Knot DNS zonefile check utility.
endef

define Package/knot-keymgr/description
	Knot DNS DNSSEC key management utility.
endef

define Package/knot-tests/description
	Unit tests for the Knot DNS server and libraries.
	Usage: /usr/share/knot/runtests.sh
endef

CONFIGURE_ARGS += 			\
	--enable-recvmmsg=no		\
	--disable-fastparser		\
	--without-libidn		\
	--with-rundir=/var/run/knot	\
	--with-storage=/var/lib/knot	\
	--with-configdir=/etc/knot	\
	--with-timer-mapsize=50		\
	--with-conf-mapsize=50

TARGET_CFLAGS += -DPSELECT_COMPAT -DNDEBUG

define Package/knot/conffiles
/etc/knot/knot.conf
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR)/libtap check
	$(MAKE) -C $(PKG_BUILD_DIR)/src/dnssec/tests check-compile
	$(MAKE) -C $(PKG_BUILD_DIR)/tests check-compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src/zscanner check-compile
endef

define Build/InstallDev
	$(INSTALL_DIR)					$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{a,so*}	$(1)/usr/lib/

	$(INSTALL_DIR)						$(1)/usr/include/libknot
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libknot/*		$(1)/usr/include/libknot/

	$(INSTALL_DIR)						$(1)/usr/include/dnssec
	$(CP) $(PKG_INSTALL_DIR)/usr/include/dnssec/*		$(1)/usr/include/dnssec/

	$(INSTALL_DIR)						$(1)/usr/include/zscanner
	$(CP) $(PKG_INSTALL_DIR)/usr/include/zscanner/*		$(1)/usr/include/zscanner/

	$(INSTALL_DIR)							$(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc	$(1)/usr/lib/pkgconfig/
endef

define Package/knot-libdnssec/install
	$(INSTALL_DIR) 						$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdnssec.so.*		$(1)/usr/lib/
endef

define Package/knot-libknot/install
	$(INSTALL_DIR) 						$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libknot.so.*		$(1)/usr/lib/
endef

define Package/knot-libzscanner/install
	$(INSTALL_DIR) 						$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzscanner.so.*	$(1)/usr/lib/
endef

define Package/knot/install
	$(INSTALL_DIR) 						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/knotc	$(1)/usr/bin/
	$(INSTALL_DIR) 						$(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/knotd	$(1)/usr/sbin/

	$(INSTALL_DIR) 							$(1)/etc/knot
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/knot/knot.sample.conf	$(1)/etc/knot/knot.conf

	$(INSTALL_DIR)				$(1)/etc/init.d
	$(INSTALL_BIN) ./files/knotd.init	$(1)/etc/init.d/knotd
endef

define Package/knot-dig/install
	$(INSTALL_DIR)						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/kdig		$(1)/usr/bin/
endef

define Package/knot-host/install
	$(INSTALL_DIR)						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/khost		$(1)/usr/bin/
endef

define Package/knot-nsupdate/install
	$(INSTALL_DIR)						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/knsupdate	$(1)/usr/bin/
endef

define Package/knot-nsec3hash/install
	$(INSTALL_DIR)						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/knsec3hash	$(1)/usr/bin/
endef

define Package/knot-zonecheck/install
	$(INSTALL_DIR)						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kzonecheck	$(1)/usr/bin/
endef

define Package/knot-keymgr/install
	$(INSTALL_DIR)						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/keymgr	$(1)/usr/bin/
endef

define Package/knot-tests/install
	$(INSTALL_DIR) 						$(1)/usr/share/knot
	$(INSTALL_BIN) ./files/runtests.sh			$(1)/usr/share/knot/

	$(INSTALL_DIR) 						$(1)/usr/share/knot/tap
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libtap/runtests		$(1)/usr/share/knot/tap/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libtap/tap/libtap.sh	$(1)/usr/share/knot/tap/

	$(INSTALL_DIR)									$(1)/usr/share/knot/tests
	find $(PKG_BUILD_DIR)/tests/.libs -maxdepth 1 -executable -type f | \
		xargs -I{} basename {} | \
		xargs -I{} $(INSTALL_BIN) -T $(PKG_BUILD_DIR)/tests/.libs/{}		$(1)/usr/share/knot/tests/test_{}

	$(INSTALL_DIR)									$(1)/usr/share/knot/tests/dnssec
	find $(PKG_BUILD_DIR)/src/dnssec/tests -maxdepth 1 -executable -type f | \
		xargs -I{} basename {} | \
		xargs -I{} $(INSTALL_BIN) -T $(PKG_BUILD_DIR)/src/dnssec/tests/{}	$(1)/usr/share/knot/tests/dnssec/test_{}

	$(INSTALL_DIR)									$(1)/usr/share/knot/tests/contrib
	find $(PKG_BUILD_DIR)/tests/contrib/.libs -maxdepth 1 -executable -type f | \
		xargs -I{} basename {} | \
		xargs -I{} $(INSTALL_BIN) -T $(PKG_BUILD_DIR)/tests/contrib/.libs/{}	$(1)/usr/share/knot/tests/contrib/{}

	$(INSTALL_DIR)									$(1)/usr/share/knot/tests/libknot
	find $(PKG_BUILD_DIR)/tests/libknot/.libs -maxdepth 1 -executable -type f | \
		xargs -I{} basename {} | \
		xargs -I{} $(INSTALL_BIN) -T $(PKG_BUILD_DIR)/tests/libknot/.libs/{}	$(1)/usr/share/knot/tests/libknot/{}

	$(INSTALL_DIR)									$(1)/usr/share/knot/tests/modules
	find $(PKG_BUILD_DIR)/tests/modules/.libs -maxdepth 1 -executable -type f | \
		xargs -I{} basename {} | \
		xargs -I{} $(INSTALL_BIN) -T $(PKG_BUILD_DIR)/tests/modules/.libs/{}	$(1)/usr/share/knot/tests/modules/test_{}

	$(INSTALL_DIR)									$(1)/usr/share/knot/tests/utils
	find $(PKG_BUILD_DIR)/tests/utils/.libs -maxdepth 1 -executable -type f | \
		xargs -I{} basename {} | \
		xargs -I{} $(INSTALL_BIN) -T $(PKG_BUILD_DIR)/tests/utils/.libs/{}	$(1)/usr/share/knot/tests/utils/{}

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/zscanner/tests/.libs/zscanner-tool	$(1)/usr/share/knot/tests/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/zscanner/tests/unittests		$(1)/usr/share/knot/tests/test_zscanner
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/zscanner/tests/TESTS		$(1)/usr/share/knot/tests/
	cp -a $(PKG_BUILD_DIR)/src/zscanner/tests/data				$(1)/usr/share/knot/tests/
endef

$(eval $(call BuildPackage,knot-libdnssec))
$(eval $(call BuildPackage,knot-libknot))
$(eval $(call BuildPackage,knot-libzscanner))
$(eval $(call BuildPackage,knot))
$(eval $(call BuildPackage,knot-dig))
$(eval $(call BuildPackage,knot-host))
$(eval $(call BuildPackage,knot-nsupdate))
$(eval $(call BuildPackage,knot-nsec3hash))
$(eval $(call BuildPackage,knot-zonecheck))
$(eval $(call BuildPackage,knot-keymgr))
$(eval $(call BuildPackage,knot-tests))
