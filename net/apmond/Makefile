#
# Copyright (C) 2026 Rob White <rob@blue-wave.net>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=apmond
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/openNDS/apmond/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=97046caa93c75ce0bebba1952f925bc3ad2801cd9c39daac2934a0eb96a30fbc

PKG_MAINTAINER:=Rob White <rob@blue-wave.net>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/apmond/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Access point monitoring daemon (protocol 2, C)
  URL:=https://github.com/openNDS/apmond
  USERID:=apmond=468:apmond=468
  DEPENDS:=+libubox +libubus +libuci +libblobmsg-json +libmicrohttpd-no-ssl
endef

# Two variants of one daemon, wire compatible, differing only in the crypto library.
# apmond (mbedTLS) is the default: "apk add apmond" and anything depending on apmond
# (luci-app-apmond) get it unless apmond-openssl is already installed.
define Package/apmond
  $(Package/apmond/default)
  TITLE+= (mbedTLS)
  DEPENDS+= +libmbedtls
  VARIANT:=mbedtls
  DEFAULT_VARIANT:=1
  CONFLICTS:=apmond-openssl
endef

define Package/apmond-openssl
  $(Package/apmond/default)
  TITLE+= (OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
  PROVIDES:=apmond
endef

define Package/apmond/default/description
  apmond collects access point, Wi-Fi client and wired client data from every
  node of a network and reports it, encrypted with AES-256-GCM, to a collector
  node, where it is available on ubus (ubus call apmond nodes / clients).
  Version 2 is a rewrite in C with a new protocol; all nodes must run 2.x.
endef

define Package/apmond/description
  $(Package/apmond/default/description)
  This variant uses mbedTLS. It interoperates with apmond-openssl.
endef

define Package/apmond-openssl/description
  $(Package/apmond/default/description)
  This variant uses OpenSSL (libcrypto), for images that already carry
  OpenSSL. It interoperates with apmond (mbedTLS).
endef

define Package/apmond/conffiles
/etc/config/apmond
endef

Package/apmond-openssl/conffiles = $(Package/apmond/conffiles)

CMAKE_OPTIONS += -DBUILD_DAEMON=ON -DBUILD_TESTS=OFF -DCRYPTO_BACKEND=$(BUILD_VARIANT)
CMAKE_OPTIONS += -DAPMOND_PACKAGE_VERSION=$(PKG_VERSION)-r$(PKG_RELEASE)
# build_commit: CMakeLists.txt reads .build_commit, filled in by the release tarball (export-subst)

define Package/apmond/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/apmond $(1)/usr/sbin/apmond
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/apmond.config $(1)/etc/config/apmond
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/apmond.init $(1)/etc/init.d/apmond
	$(INSTALL_DIR) $(1)/etc/capabilities
	$(INSTALL_DATA) ./files/apmond.capabilities $(1)/etc/capabilities/apmond.json
	$(INSTALL_DIR) $(1)/usr/share/acl.d
	$(INSTALL_DATA) ./files/apmond_acl.json $(1)/usr/share/acl.d/apmond.json
endef

define Package/apmond/postinst
#!/bin/sh
# Appended after default_postinst, which has already run "/etc/init.d/apmond start".
# On an upgrade procd ignores that start (same command line), so the old code keeps running: restart it.
# Fresh install: PKG_UPGRADE is unset, default_postinst started it once. Image build: IPKG_INSTROOT is set.
# ubusd reads /usr/share/acl.d only at start: reload it so user apmond may publish its object.
if [ -z "$${IPKG_INSTROOT}" ]; then
	ubusd_pid=$$(pidof ubusd)
	if [ -n "$$ubusd_pid" ]; then
		kill -HUP $$ubusd_pid
	fi
	if [ "$${PKG_UPGRADE}" = "1" ] && /etc/init.d/apmond running; then
		/etc/init.d/apmond restart
	fi
fi
endef

Package/apmond-openssl/install = $(Package/apmond/install)
Package/apmond-openssl/postinst = $(Package/apmond/postinst)

$(eval $(call BuildPackage,apmond))
$(eval $(call BuildPackage,apmond-openssl))
