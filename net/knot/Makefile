#
# Copyright (C) 2014-2015 CZ.NIC, z.s.p.o. <knot-dns@labs.nic.cz>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=knot
PKG_VERSION:=1.6.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://secure.nic.cz/files/knot-dns/
PKG_MD5SUM:=934b6feaeefd0df7b3be6709e39b19ce

PKG_MAINTAINER:=Daniel Salzman <daniel.salzman@nic.cz>
PKG_LICENSE:=GPL-2.0+

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/knot/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Knot DNS
	URL:=https://www.knot-dns.cz
	SUBMENU:=IP Addresses and Names
	DEPENDS:=+libopenssl +liburcu
endef

define Package/knot-libknot
	$(call Package/knot/Default)
	TITLE+= (library)
endef

define Package/knot
	$(call Package/knot/Default)
	TITLE+= (server)
	DEPENDS+=+knot-libknot
endef

define Package/knot-dig
	$(call Package/knot/Default)
	TITLE+= lookup utility
	DEPENDS+=+knot-libknot
endef

define Package/knot-host
	$(call Package/knot/Default)
	TITLE+= simple DNS lookup utility
	DEPENDS+=+knot-libknot
endef

define Package/knot-nsec3hash
	$(call Package/knot/Default)
	TITLE+= simple NSEC3 hash utility
	DEPENDS+=+knot-libknot
endef

define Package/knot-nsupdate
	$(call Package/knot/Default)
	TITLE+= dynamic DNS update utility
	DEPENDS+=+knot-libknot
endef

define Package/knot-tests
	$(call Package/knot/Default)
	TITLE+= (tests)
	DEPENDS+=+knot-libknot
endef

define Package/knot-libknot/description
	Knot DNS library.
endef

define Package/knot/description
	High-performance authoritative-only DNS server.
endef

define Package/knot-dig/description
	Knot DNS lookup utility.
endef

define Package/knot-host/description
	Knot DNS simple DNS lookup utility.
endef

define Package/knot-nsec3hash/description
	Knot DNS simple utility to compute NSEC3 hash.
endef

define Package/knot-nsupdate/description
	Knot DNS dynamic DNS update utility.
endef

define Package/knot-tests/description
	Unit tests for Knot DNS server.
	Usage: /usr/share/knot/runtests.sh
endef

define Package/knot/conffiles
/etc/knot/knot.conf
endef

CONFIGURE_ARGS += 			\
	--enable-recvmmsg=no		\
	--disable-fastparser		\
	--without-libidn		\
	--with-rundir=/var/run		\
	--with-storage=/etc/knot

TARGET_CFLAGS += -std=gnu99 -DPSELECT_COMPAT

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR)/libtap check
	$(MAKE) -C $(PKG_BUILD_DIR)/tests check-compile-only
	$(MAKE) -C $(PKG_BUILD_DIR)/src/zscanner check-compile-only
endef

define Package/knot-libknot/install
	$(INSTALL_DIR) 						$(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libknot.so.*		$(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzscanner.so.*	$(1)/usr/lib/
endef

define Package/knot/install
	$(INSTALL_DIR) 						$(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/knotc	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/knotd	$(1)/usr/sbin/

	$(INSTALL_DIR) 							$(1)/etc/knot
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/knot/knot.sample.conf	$(1)/etc/knot/knot.conf
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/knot/example.com.zone	$(1)/etc/knot/

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

define Package/knot-nsec3hash/install
	$(INSTALL_DIR)						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/knsec3hash	$(1)/usr/bin/
endef

define Package/knot-nsupdate/install
	$(INSTALL_DIR)						$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/knsupdate	$(1)/usr/bin/
endef

define Package/knot-tests/install
	$(INSTALL_DIR) 						$(1)/usr/share/knot
	$(INSTALL_BIN) ./files/runtests.sh			$(1)/usr/share/knot/

	$(INSTALL_DIR) 						$(1)/usr/share/knot/tap
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libtap/runtests		$(1)/usr/share/knot/tap/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libtap/tap/libtap.sh	$(1)/usr/share/knot/tap/

	$(INSTALL_DIR)								$(1)/usr/share/knot/tests
	find $(PKG_BUILD_DIR)/tests/.libs -maxdepth 1 -executable -type f | \
		xargs -I{} basename {} | \
		xargs -I{} $(INSTALL_BIN) -T $(PKG_BUILD_DIR)/tests/.libs/{}	$(1)/usr/share/knot/tests/test_{}

	$(INSTALL_DIR)						$(1)/usr/share/knot/tests/data
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tests/data/sample_conf	$(1)/usr/share/knot/tests/data/

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/zscanner/tests/.libs/zscanner-tool	$(1)/usr/share/knot/tests/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/zscanner/tests/unittests		$(1)/usr/share/knot/tests/test_zscanner
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/zscanner/tests/TESTS		$(1)/usr/share/knot/tests/
	cp -a $(PKG_BUILD_DIR)/src/zscanner/tests/data				$(1)/usr/share/knot/tests/
endef

$(eval $(call BuildPackage,knot-libknot))
$(eval $(call BuildPackage,knot))
$(eval $(call BuildPackage,knot-dig))
$(eval $(call BuildPackage,knot-host))
$(eval $(call BuildPackage,knot-nsec3hash))
$(eval $(call BuildPackage,knot-nsupdate))
$(eval $(call BuildPackage,knot-tests))
