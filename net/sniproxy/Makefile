include $(TOPDIR)/rules.mk

PKG_NAME:=sniproxy
PKG_VERSION:=0.6.0
PKG_RELEASE:=1
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/dlundquist/sniproxy/tar.gz/${PKG_VERSION}?
PKG_HASH:=d73c77a9fa8199ae7ac551c0332d3e0a3ff234623f53d65369a8fa560d9880e2
PKG_SOURCE_VERSION:=425e105d5a03fabd737a126ad93d62a9eeede87f

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/sniproxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=SNI Proxy
  URL:=https://github.com/dlundquist/sniproxy
  DEPENDS:=+libev +libpcre +libudns
endef

define Package/sniproxy/description
Proxies incoming HTTP and TLS connections based on the hostname contained in the initial request of the TCP session.
This enables HTTPS name-based virtual hosting to separate backend servers without installing the private key on the proxy machine.
endef

define Package/sniproxy/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/sniproxy $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sniproxy.init $(1)/etc/init.d/sniproxy

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/sniproxy.conf $(1)/etc/config/sniproxy
endef

$(eval $(call BuildPackage,sniproxy))
