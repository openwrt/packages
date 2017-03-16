#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ulogd
PKG_VERSION:=2.0.5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=ftp://ftp.netfilter.org/pub/ulogd/ \
	ftp://ftp.be.netfilter.org/pub/netfilter/ulogd/ \
	ftp://ftp.de.netfilter.org/pub/netfilter/ulogd/ \
	ftp://ftp.no.netfilter.org/pub/netfilter/ulogd/
PKG_MD5SUM:=f0f8fe1371fa28b5e06cb16aaa0111dd

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ulogd/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=http://www.netfilter.org/projects/ulogd/index.html
endef

define Package/ulogd
  $(call Package/ulogd/Default)
  DEPENDS:=+libmnl +libnfnetlink +libpthread
  TITLE:=Netfilter userspace logging daemon
  MENU:=1
endef

define Package/ulogd/conffiles
/etc/ulogd.conf
endef

define Package/ulogd-mod-dbi
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libdbi
  TITLE:=Output plugin for logging to a database using libdbi
endef

define Package/ulogd-mod-json
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +jansson
  TITLE:=JSON output plugin
endef

define Package/ulogd-mod-mysql
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libmysqlclient
  TITLE:=Output plugin for logging to a MySQL database
endef

define Package/ulogd-mod-nfacct
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libnetfilter-acct
  TITLE:=Input plugin for flow-based logging (accounting)
endef

define Package/ulogd-mod-nfct
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libnetfilter-conntrack
  TITLE:=Input plugin for flow-based logging (conntracking)
endef

define Package/ulogd-mod-nflog
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libnetfilter-log
  TITLE:=Input plugin using NFLOG
endef

define Package/ulogd-mod-pcap
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libpcap
  TITLE:=Output plugin for logging in pcap format
endef

define Package/ulogd-mod-pgsql
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libpq
  TITLE:=Output plugin for logging to a PostgreSQL database
endef

define Package/ulogd-mod-sqlite
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libsqlite3
  TITLE:=Output plugin for logging to an SQLite database
endef

define Package/ulogd-mod-syslog
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd
  TITLE:=Syslog output plugin
endef

define Package/ulogd-mod-xml
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd +libnetfilter-acct +libnetfilter-conntrack +libnetfilter-log
  TITLE:=XML output plugin
endef

define Package/ulogd-mod-extra
  $(call Package/ulogd/Default)
  DEPENDS:=ulogd
  TITLE:=Extra plugins
endef

PKG_BUILD_DEPENDS:=libnetfilter-acct libnetfilter-conntrack libnetfilter-log

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_ulogd-mod-dbi \
	CONFIG_PACKAGE_ulogd-mod-mysql \
	CONFIG_PACKAGE_ulogd-mod-pgsql \
	CONFIG_PACKAGE_ulogd-mod-sqlite \

TARGET_CFLAGS += \
	-D_GNU_SOURCE \

CONFIGURE_ARGS += \
	--enable-nfacct \
	--enable-nfct \
	--enable-nflog \

ifneq ($(DEVELOPER)$(SDK)$(CONFIG_PACKAGE_ulogd-mod-dbi),)
	CONFIGURE_ARGS += --with-dbi \
		--with-dbi-inc=$(STAGING_DIR)/usr/include/dbi \
		--with-dbi-lib=$(STAGING_DIR)/usr/lib
else
	CONFIGURE_ARGS += --without-dbi
endif

ifneq ($(DEVELOPER)$(SDK)$(CONFIG_PACKAGE_ulogd-mod-mysql),)
	CONFIGURE_ARGS += --with-mysql="$(STAGING_DIR)/usr"
else
	CONFIGURE_ARGS += --without-mysql
endif

ifneq ($(DEVELOPER)$(SDK)$(CONFIG_PACKAGE_ulogd-mod-pgsql),)
	CONFIGURE_ARGS += --with-pgsql="$(STAGING_DIR)/usr"
else
	CONFIGURE_ARGS += --without-pgsql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_ulogd-mod-sqlite),)
	CONFIGURE_ARGS += --with-sqlite="$(STAGING_DIR)/usr"
else
	CONFIGURE_ARGS += --without-sqlite
endif

define Package/ulogd/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_BUILD_DIR)/ulogd.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/ulogd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib/ulogd
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ulogd/ulogd_raw2packet_BASE.so $(1)/usr/lib/ulogd/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ulogd.init $(1)/etc/init.d/ulogd
endef

define BuildPlugin
  define Package/ulogd-mod-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/ulogd
	for m in $(2); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/ulogd/ulogd_$$$$$$$${m}.so $$(1)/usr/lib/ulogd/ ; \
	done
  endef
  $$(eval $$(call BuildPackage,ulogd-mod-$(1)))
endef

ULOGD_EXTRA_PLUGINS:= \
	filter_HWHDR \
	filter_IFINDEX \
	filter_IP2BIN \
	filter_IP2HBIN \
	filter_IP2STR \
	filter_MARK \
	filter_PRINTFLOW \
	filter_PRINTPKT \
	filter_PWSNIFF \
	inppkt_UNIXSOCK \
	output_GPRINT \
	output_GRAPHITE \
	output_LOGEMU \
	output_OPRINT \

$(eval $(call BuildPackage,ulogd))
$(eval $(call BuildPlugin,dbi,output_DBI))
$(eval $(call BuildPlugin,json,output_JSON))
$(eval $(call BuildPlugin,mysql,output_MYSQL))
$(eval $(call BuildPlugin,nfacct,inpflow_NFACCT))
$(eval $(call BuildPlugin,nfct,inpflow_NFCT))
$(eval $(call BuildPlugin,nflog,inppkt_NFLOG))
$(eval $(call BuildPlugin,pcap,output_PCAP))
$(eval $(call BuildPlugin,pgsql,output_PGSQL))
$(eval $(call BuildPlugin,sqlite,output_SQLITE3))
$(eval $(call BuildPlugin,syslog,output_SYSLOG))
$(eval $(call BuildPlugin,xml,output_XML))
$(eval $(call BuildPlugin,extra,$(ULOGD_EXTRA_PLUGINS)))
