#
# Copyright (C) 2006-2012 OpenWrt.org
#               2014-2024 Noah Meyerhans <frodo@morgul.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bind
PKG_VERSION:=9.20.11
PKG_RELEASE:=3
USERID:=bind=57:bind=57

PKG_MAINTAINER:=Noah Meyerhans <frodo@morgul.net>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:isc:bind

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= \
	https://www.mirrorservice.org/sites/ftp.isc.org/isc/bind9/$(PKG_VERSION) \
	https://ftp.isc.org/isc/bind9/$(PKG_VERSION)
PKG_HASH:=4da2d532e668bc21e883f6e6d9d3d81794d9ec60b181530385649a56f46ee17a

PKG_INSTALL:=1
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS := \
	CONFIG_BIND_LIBJSON \
	CONFIG_BIND_LIBXML2 \
	CONFIG_BIND_JEMALLOC \
	CONFIG_BIND_ENABLE_DOH \
	CONFIG_BIND_ENABLE_GSSAPI

PKG_BUILD_DEPENDS += \
	BIND_LIBXML2:libxml2 \
	BIND_LIBJSON:libjson-c \
	BIND_JEMALLOC:libjemalloc

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

DISABLE_NLS:=

define Package/bind/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+bind-libs +@OPENSSL_WITH_EC
  TITLE:=bind
  URL:=https://www.isc.org/software/bind
  SUBMENU:=IP Addresses and Names
endef

define Package/bind-libs
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libopenssl \
	+zlib \
	+libpthread \
	+libatomic \
	+libuv \
	+liburcu \
	+BIND_ENABLE_DOH:libnghttp2 \
	+BIND_ENABLE_GSSAPI:krb5-libs \
	+BIND_ENABLE_GSSAPI:libcomerr \
	+BIND_LIBXML2:libxml2 \
	+BIND_LIBJSON:libjson-c \
	+BIND_JEMALLOC:libjemalloc
  TITLE:=bind shared libraries
  URL:=https://www.isc.org/software/bind
endef

define Package/bind-server
  $(call Package/bind/Default)
  TITLE+= DNS server
  DEPENDS+= +libcap \
	+bind-rndc
endef

define Package/bind-server/config
	source "$(SOURCE)/Config.in"
endef

define Package/bind-server-filter-aaaa
  $(call Package/bind-server)
  DEPENDS:=bind-server
  TITLE+= filter AAAA plugin
endef

define Package/bind-client
  $(call Package/bind/Default)
  TITLE+= dynamic DNS client
endef

define Package/bind-tools
  $(call Package/bind/Default)
  TITLE+= administration tools (all)
	DEPENDS:= \
	+bind-check \
	+bind-dig \
	+bind-nslookup \
	+bind-dnssec \
	+bind-host \
	+bind-rndc \
	+bind-ddns-confgen
endef

define Package/bind-rndc
  $(call Package/bind/Default)
  TITLE+= administration tools (rndc and rndc-confgen only)
endef

define Package/bind-check
  $(call Package/bind/Default)
  TITLE+= administration tools (named-checkconf and named-checkzone only)
endef

define Package/bind-dnssec
  $(call Package/bind/Default)
  TITLE+= administration tools (dnssec-keygen, dnssec-settime and dnssec-signzone only)
endef

define Package/bind-host
  $(call Package/bind/Default)
  TITLE+= simple DNS client
endef

define Package/bind-dig
  $(call Package/bind/Default)
  TITLE+= DNS excavation tool
endef

define Package/bind-nslookup
  $(call Package/bind/Default)
  TITLE+= nslookup utility
  ALTERNATIVES:= \
	  200:/usr/bin/nslookup:/usr/libexec/nslookup-bind
endef

define Package/bind-ddns-confgen
  $(call Package/bind/Default)
  TITLE+= administration tools (ddns-confgen and tsig-keygen only)
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed \
	-Wl,-rpath-link,$(PKG_BUILD_DIR)/lib/ns/.libs

CONFIGURE_ARGS += \
	--disable-geoip \
	--with-openssl="$(STAGING_DIR)/usr" \
	--without-lmdb \
	--without-readline \
	--sysconfdir=/etc/bind

ifdef CONFIG_BIND_LIBJSON
	TARGET_CFLAGS += -DHAVE_JSON_C -UHAVE_JSON
	CONFIGURE_ARGS += \
		--with-json-c=yes
else
	CONFIGURE_ARGS += \
		--with-json-c=no
endif

ifdef CONFIG_BIND_LIBXML2
	CONFIGURE_ARGS += \
		--with-libxml2=yes
else
	CONFIGURE_ARGS += \
		--with-libxml2=no
endif

ifdef CONFIG_BIND_JEMALLOC
	CONFIGURE_ARGS += \
		--with-jemalloc=yes
else
	CONFIGURE_ARGS += \
		--without-jemalloc
endif

ifdef CONFIG_BIND_ENABLE_DOH
	CONFIGURE_ARGS += \
		--enable-doh
else
	CONFIGURE_ARGS += \
		--disable-doh
endif

ifdef CONFIG_BIND_ENABLE_GSSAPI
	CONFIGURE_ARGS += \
		--with-gssapi
else
	CONFIGURE_ARGS += \
		--without-gssapi
endif

define Package/bind-libs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
endef

define Package/bind-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/named $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/bind
	$(INSTALL_DATA) ./files/bind/db.root $(1)/etc/bind
	$(INSTALL_DATA) ./files/bind/named.conf $(1)/etc/bind
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/named.init $(1)/etc/init.d/named
endef

define Package/bind-server/conffiles
/etc/bind
endef

define Package/bind-server-filter-aaaa/install
	$(INSTALL_DIR) $(1)/usr/lib/bind
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/bind/filter-aaaa.so $(1)/usr/lib/bind
endef

define Package/bind-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nsupdate $(1)/usr/bin/
endef

define Package/bind-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/delv $(1)/usr/bin/
endef

define Package/bind-rndc/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/rndc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/rndc-confgen $(1)/usr/sbin/
endef

define Package/bind-check/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/named-checkconf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/named-checkzone $(1)/usr/bin/
endef

define Package/bind-dnssec/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dnssec-keygen $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dnssec-settime $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dnssec-signzone $(1)/usr/bin/
endef

define Package/bind-host/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/host $(1)/usr/bin/
endef

define Package/bind-dig/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dig $(1)/usr/bin/
endef

define Package/bind-nslookup/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nslookup $(1)/usr/libexec/nslookup-bind
endef

define Package/bind-ddns-confgen/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ddns-confgen $(1)/usr/sbin/ddns-confgen
	$(LN) -s ddns-confgen $(1)/usr/sbin/tsig-keygen
endef

$(eval $(call BuildPackage,bind-libs))
$(eval $(call BuildPackage,bind-server))
$(eval $(call BuildPackage,bind-server-filter-aaaa))
$(eval $(call BuildPackage,bind-client))
$(eval $(call BuildPackage,bind-tools))
$(eval $(call BuildPackage,bind-rndc))
$(eval $(call BuildPackage,bind-check))
$(eval $(call BuildPackage,bind-dnssec))
$(eval $(call BuildPackage,bind-host))
$(eval $(call BuildPackage,bind-dig))
$(eval $(call BuildPackage,bind-nslookup))
$(eval $(call BuildPackage,bind-ddns-confgen))
