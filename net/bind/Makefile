#
# Copyright (C) 2006-2012 OpenWrt.org
#               2014-2024 Noah Meyerhans <frodo@morgul.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bind
PKG_VERSION:=9.20.18
PKG_RELEASE:=2
USERID:=bind=57:bind=57

PKG_MAINTAINER:=Noah Meyerhans <frodo@morgul.net>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:isc:bind

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= \
	https://www.mirrorservice.org/sites/ftp.isc.org/isc/bind9/$(PKG_VERSION) \
	https://ftp.isc.org/isc/bind9/$(PKG_VERSION)
PKG_HASH:=dfc546c990ac4515529cd45c4dd995862b18ae8a2d0cb29208e8896a5d325331

PKG_INSTALL:=1
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS := \
	CONFIG_BIND_LIBJSON \
	CONFIG_BIND_LIBXML2 \
	CONFIG_BIND_JEMALLOC \
	CONFIG_BIND_ENABLE_DOH

PKG_BUILD_DEPENDS += \
	BIND_LIBXML2:libxml2 \
	BIND_LIBJSON:libjson-c \
	BIND_JEMALLOC:libjemalloc

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

DISABLE_NLS:=

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
	+BIND_LIBXML2:libxml2 \
	+BIND_LIBJSON:libjson-c \
	+BIND_JEMALLOC:libjemalloc
  TITLE:=bind shared libraries
  URL:=https://www.isc.org/software/bind
  VARIANT:=without-gssapi
  CONFLICTS:=bind-libs-gssapi
endef

define Package/bind-libs-gssapi
  $(Package/bind-libs)
  DEPENDS+=+krb5-libs +libcomerr
  TITLE+= with GSSAPI
  VARIANT:=with-gssapi
  CONFLICTS:=
endef

define Package/bind/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=BIND
  TITLE:=bind
  URL:=https://www.isc.org/software/bind
  VARIANT:=without-gssapi
  DEPENDS:=+bind-libs +@OPENSSL_WITH_EC
endef

define Package/bind-gssapi/Default
  $(Package/bind/Default)
  VARIANT:=with-gssapi
  DEPENDS:=+bind-libs-gssapi +@OPENSSL_WITH_EC
endef

define Package/bind-check
  $(Package/bind/Default)
  TITLE+= tools (named-checkconf, named-checkzone)
  CONFLICTS:=bind-check-gssapi
endef

define Package/bind-check-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (named-checkconf, named-checkzone) with GSSAPI
  PROVIDES:=bind-check
endef

define Package/bind-client
  $(Package/bind/Default)
  TITLE+= tools (nsupdate)
  CONFLICTS:=bind-client-gssapi
endef

define Package/bind-client-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (nsupdate) with GSSAPI
  PROVIDES:=bind-client
endef

define Package/bind-ddns-confgen
  $(Package/bind/Default)
  TITLE+= tools (ddns-confgen, tsig-keygen)
  CONFLICTS:=bind-ddns-confgen-gssapi
endef

define Package/bind-ddns-confgen-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (ddns-confgen, tsig-keygen) with GSSAPI
  PROVIDES:=bind-ddns-confgen
endef

define Package/bind-delv
  $(Package/bind/Default)
  TITLE+= tools (delv)
  CONFLICTS:=bind-delv-gssapi
endef

define Package/bind-delv-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (delv) with GSSAPI
  PROVIDES:=bind-delv
endef

define Package/bind-dig
  $(Package/bind/Default)
  TITLE+= tools (dig)
  CONFLICTS:=bind-dig-gssapi
endef

define Package/bind-dig-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (dig) with GSSAPI
  PROVIDES:=bind-dig
endef

define Package/bind-dnssec
  $(Package/bind/Default)
  TITLE+= tools (dnssec-keygen, dnssec-settime, dnssec-signzone)
  CONFLICTS:=bind-dnssec-gssapi
endef

define Package/bind-dnssec-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (dnssec-keygen, dnssec-settime, dnssec-signzone) with GSSAPI
  PROVIDES:=bind-dnssec
endef

define Package/bind-host
  $(Package/bind/Default)
  TITLE+= tools (host)
  CONFLICTS:=bind-host-gssapi
endef

define Package/bind-host-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (host) with GSSAPI
  PROVIDES:=bind-host
endef

define Package/bind-nslookup
  $(Package/bind/Default)
  TITLE+= tools (nslookup)
  ALTERNATIVES:= \
	  200:/usr/bin/nslookup:/usr/libexec/nslookup-bind
  CONFLICTS:=bind-nslookup-gssapi
endef

define Package/bind-nslookup-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (nslookup) with GSSAPI
  ALTERNATIVES:= \
	  200:/usr/bin/nslookup:/usr/libexec/nslookup-bind
  PROVIDES:=bind-nslookup
endef

define Package/bind-rndc
  $(Package/bind/Default)
  TITLE+= tools (rndc, rndc-confgen)
  CONFLICTS:=bind-rndc-gssapi
endef

define Package/bind-rndc-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= tools (rndc, rndc-confgen) with GSSAPI
  PROVIDES:=bind-rndc
endef

define Package/bind-server
  $(Package/bind/Default)
  TITLE+= DNS server
  DEPENDS+= +libcap +bind-rndc
  CONFLICTS:=bind-server-gssapi
endef

define Package/bind-server-gssapi
  $(Package/bind-gssapi/Default)
  TITLE+= DNS server with GSSAPI
  DEPENDS+=+libcap +bind-rndc-gssapi
  PROVIDES:=bind-server
endef

define Package/bind-tools
  $(Package/bind/Default)
  TITLE+= administration tools (all)
  DEPENDS:= \
	+bind-check \
	+bind-delv \
	+bind-dig \
	+bind-nslookup \
	+bind-dnssec \
	+bind-host \
	+bind-rndc \
	+bind-ddns-confgen
endef

define Package/bind-tools/config
	# These options don't actually relate to bind-tools, they are generic.
	# Putting them here makes sure they end up at the end of the menu.
	source "$(SOURCE)/Config.in"
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

ifeq ($(BUILD_VARIANT),with-gssapi)
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
Package/bind-libs-gssapi/install=$(Package/bind-libs/install)

define Package/bind-check/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/named-checkconf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/named-checkzone $(1)/usr/bin/
endef
Package/bind-check-gssapi/install=$(Package/bind-check/install)

define Package/bind-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nsupdate $(1)/usr/bin/
endef
Package/bind-client-gssapi/install=$(Package/bind-client/install)

define Package/bind-ddns-confgen/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ddns-confgen $(1)/usr/sbin/ddns-confgen
	$(LN) -s ddns-confgen $(1)/usr/sbin/tsig-keygen
endef
Package/bind-ddns-confgen-gssapi/install=$(Package/bind-ddns-confgen/install)

define Package/bind-delv/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/delv $(1)/usr/bin/
endef
Package/bind-delv-gssapi/install=$(Package/bind-delv/install)

define Package/bind-dig/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dig $(1)/usr/bin/
endef
Package/bind-dig-gssapi/install=$(Package/bind-dig/install)

define Package/bind-dnssec/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dnssec-keygen $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dnssec-settime $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dnssec-signzone $(1)/usr/bin/
endef
Package/bind-dnssec-gssapi/install=$(Package/bind-dnssec/install)

define Package/bind-host/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/host $(1)/usr/bin/
endef
Package/bind-host-gssapi/install=$(Package/bind-host/install)

define Package/bind-nslookup/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nslookup $(1)/usr/libexec/nslookup-bind
endef
Package/bind-nslookup-gssapi/install=$(Package/bind-nslookup/install)

define Package/bind-rndc/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/rndc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/rndc-confgen $(1)/usr/sbin/
endef
Package/bind-rndc-gssapi/install=$(Package/bind-rndc/install)

define Package/bind-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/named $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/bind
	$(INSTALL_DATA) ./files/bind/db.root $(1)/etc/bind
	$(INSTALL_DATA) ./files/bind/named.conf $(1)/etc/bind
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/named.init $(1)/etc/init.d/named
	$(INSTALL_DIR) $(1)/usr/lib/bind
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/bind/filter-a.so $(1)/usr/lib/bind
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/bind/filter-aaaa.so $(1)/usr/lib/bind
endef
Package/bind-server-gssapi/install=$(Package/bind-server/install)

define Package/bind-server/conffiles
/etc/bind
endef
Package/bind-server-gssapi/conffiles=$(Package/bind-server/conffiles)

$(eval $(call BuildPackage,bind-libs))
$(eval $(call BuildPackage,bind-libs-gssapi))
$(eval $(call BuildPackage,bind-check))
$(eval $(call BuildPackage,bind-check-gssapi))
$(eval $(call BuildPackage,bind-client))
$(eval $(call BuildPackage,bind-client-gssapi))
$(eval $(call BuildPackage,bind-ddns-confgen))
$(eval $(call BuildPackage,bind-ddns-confgen-gssapi))
$(eval $(call BuildPackage,bind-delv))
$(eval $(call BuildPackage,bind-delv-gssapi))
$(eval $(call BuildPackage,bind-dig))
$(eval $(call BuildPackage,bind-dig-gssapi))
$(eval $(call BuildPackage,bind-dnssec))
$(eval $(call BuildPackage,bind-dnssec-gssapi))
$(eval $(call BuildPackage,bind-host))
$(eval $(call BuildPackage,bind-host-gssapi))
$(eval $(call BuildPackage,bind-nslookup))
$(eval $(call BuildPackage,bind-nslookup-gssapi))
$(eval $(call BuildPackage,bind-rndc))
$(eval $(call BuildPackage,bind-rndc-gssapi))
$(eval $(call BuildPackage,bind-server))
$(eval $(call BuildPackage,bind-server-gssapi))
$(eval $(call BuildPackage,bind-tools))
